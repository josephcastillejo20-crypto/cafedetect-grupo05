import numpy as np
import tensorflow as tf
from PIL import Image
import io
import os

from django.contrib.auth import authenticate
from django.contrib.auth.models import User

from rest_framework import status
from rest_framework.decorators import api_view, permission_classes, parser_classes
from rest_framework.parsers import MultiPartParser
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.authtoken.models import Token

from .models import Analisis

# ─── MODELO IA ────────────────────────────────────────────────────────────────
MODEL_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'coffee_disease_model.tflite')

interpreter = tf.lite.Interpreter(model_path=MODEL_PATH)
interpreter.allocate_tensors()
input_details  = interpreter.get_input_details()
output_details = interpreter.get_output_details()

CLASS_NAMES = ['Cercosporiosis', 'Hoja sana', 'Roya del café', 'Minador de hojas', 'Phoma']

CLASS_RECOMMENDATIONS = {
    'Cercosporiosis':    'Aplicar fungicidas con mancozeb o clorotalonil. Mejorar la nutrición del cultivo, especialmente el aporte de potasio y zinc.',
    'Hoja sana':         'La hoja está sana. Continúe con el programa de fertilización y mantenimiento preventivo del cultivo.',
    'Roya del café':     'Aplicar fungicidas cúpricos o triazoles de forma inmediata. Eliminar y destruir las hojas afectadas. Mejorar la ventilación del cultivo.',
    'Minador de hojas':  'Aplicar insecticidas sistémicos (imidacloprid o clorpirifós). Eliminar hojas muy afectadas y mantener el cultivo libre de malezas.',
    'Phoma':             'Mejorar el drenaje del suelo. Aplicar fungicidas preventivos con base en cobre. Evitar el exceso de humedad y la herida en el tejido vegetal.',
}

def _predict(img_array):
    img_array = img_array.astype(np.float32) / 255.0
    interpreter.set_tensor(input_details[0]['index'], img_array)
    interpreter.invoke()
    return interpreter.get_tensor(output_details[0]['index'])[0]


# ─── AUTH ─────────────────────────────────────────────────────────────────────

@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    """
    POST /api/auth/login/
    Body: { "username": "...", "password": "..." }
    Retorna: { "token": "...", "user": { id, username, email, first_name, last_name } }
    """
    username = request.data.get('username')
    password = request.data.get('password')

    if not username or not password:
        return Response(
            {'error': 'Por favor ingrese usuario y contraseña'},
            status=status.HTTP_400_BAD_REQUEST,
        )

    user = authenticate(username=username, password=password)
    if user is None:
        return Response(
            {'error': 'Usuario o contraseña incorrectos'},
            status=status.HTTP_401_UNAUTHORIZED,
        )
    if not user.is_active:
        return Response(
            {'error': 'Esta cuenta está desactivada'},
            status=status.HTTP_403_FORBIDDEN,
        )

    token, _ = Token.objects.get_or_create(user=user)
    return Response({
        'token': token.key,
        'user': _user_dict(user),
    }, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout_view(request):
    """POST /api/auth/logout/ — invalida el token activo."""
    request.user.auth_token.delete()
    return Response({'message': 'Sesión cerrada correctamente'}, status=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def profile_view(request):
    """GET /api/auth/profile/ — datos del usuario autenticado."""
    return Response(_user_dict(request.user))


@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def update_profile_view(request):
    """
    PATCH /api/auth/update_profile/
    Body (campos opcionales): { "first_name", "last_name", "email" }
    """
    user = request.user
    user.first_name = request.data.get('first_name', user.first_name)
    user.last_name  = request.data.get('last_name',  user.last_name)
    email = request.data.get('email', user.email)

    # Validar unicidad de email si cambió
    if email != user.email and User.objects.filter(email=email).exclude(pk=user.pk).exists():
        return Response({'error': 'Ese correo ya está en uso'}, status=status.HTTP_400_BAD_REQUEST)

    user.email = email
    user.save()
    return Response(_user_dict(user))


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def change_password_view(request):
    """
    POST /api/auth/change_password/
    Body: { "current_password": "...", "new_password": "..." }
    """
    current = request.data.get('current_password', '')
    new_pw  = request.data.get('new_password', '')

    if not current or not new_pw:
        return Response(
            {'error': 'Debes enviar la contraseña actual y la nueva'},
            status=status.HTTP_400_BAD_REQUEST,
        )
    if not request.user.check_password(current):
        return Response(
            {'error': 'La contraseña actual es incorrecta'},
            status=status.HTTP_400_BAD_REQUEST,
        )
    if len(new_pw) < 4:
        return Response(
            {'error': 'La nueva contraseña debe tener al menos 4 caracteres'},
            status=status.HTTP_400_BAD_REQUEST,
        )

    request.user.set_password(new_pw)
    request.user.save()
    # Regenerar token tras cambio de contraseña
    request.user.auth_token.delete()
    token = Token.objects.create(user=request.user)
    return Response({'message': 'Contraseña actualizada correctamente', 'token': token.key})


# ─── CLASIFICACIÓN ────────────────────────────────────────────────────────────

@api_view(['POST'])
@permission_classes([AllowAny])
@parser_classes([MultiPartParser])
def clasificar_hoja(request):
    """
    POST /api/auth/clasificar/
    Body (multipart): image
    Retorna: { prediccion, confianza, recomendacion, probabilidades }
    """
    file = request.FILES.get('image')
    if not file:
        return Response({'error': 'No se envió imagen'}, status=status.HTTP_400_BAD_REQUEST)

    try:
        img = Image.open(io.BytesIO(file.read())).convert('RGB')
        img = img.resize((128, 128))
        img_array = np.expand_dims(np.array(img), axis=0)

        prediction     = _predict(img_array)
        predicted_idx  = int(np.argmax(prediction))
        predicted_class = CLASS_NAMES[predicted_idx]
        confidence     = float(prediction[predicted_idx])

        probabilities = {
            CLASS_NAMES[i]: round(float(p), 4)
            for i, p in enumerate(prediction)
        }

        # Guardar en historial si el usuario está autenticado
        user = request.user if request.user.is_authenticated else None
        Analisis.objects.create(
            user=user,
            patologia=predicted_class,
            confianza=round(confidence * 100, 2),
            recomendacion=CLASS_RECOMMENDATIONS[predicted_class],
        )

        return Response({
            'prediccion':    predicted_class,
            'confianza':     round(confidence * 100, 2),
            'recomendacion': CLASS_RECOMMENDATIONS[predicted_class],
            'probabilidades': probabilities,
        })

    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# ─── HISTORIAL Y ESTADÍSTICAS ─────────────────────────────────────────────────

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def historial_view(request):
    """
    GET /api/auth/historial/
    Retorna los últimos 50 análisis del usuario autenticado.
    """
    analisis = Analisis.objects.filter(user=request.user)[:50]
    data = [
        {
            'id':          a.id,
            'patologia':   a.patologia,
            'confianza':   a.confianza,
            'recomendacion': a.recomendacion,
            'fecha':       a.fecha.strftime('%d %b %Y'),
            'hora':        a.fecha.strftime('%I:%M %p'),
            'estado':      'Sano' if a.patologia == 'Hoja sana' else 'Enfermo',
        }
        for a in analisis
    ]
    return Response(data)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def stats_view(request):
    """
    GET /api/auth/stats/
    Retorna conteos de análisis del usuario autenticado.
    """
    qs = Analisis.objects.filter(user=request.user)
    total    = qs.count()
    sanos    = qs.filter(patologia='Hoja sana').count()
    enfermos = total - sanos
    return Response({'total': total, 'sanos': sanos, 'enfermos': enfermos})


# ─── HELPER ───────────────────────────────────────────────────────────────────

def _user_dict(user):
    return {
        'id':         user.id,
        'username':   user.username,
        'email':      user.email,
        'first_name': user.first_name,
        'last_name':  user.last_name,
    }
