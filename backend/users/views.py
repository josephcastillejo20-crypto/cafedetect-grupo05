from django.contrib.auth import authenticate
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.authtoken.models import Token


@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    """
    Endpoint de Login
    Recibe: { "username": "...", "password": "..." }
    Retorna: { "token": "...", "user": { "id", "username", "email", "first_name", "last_name" } }
    """
    username = request.data.get('username')
    password = request.data.get('password')

    if not username or not password:
        return Response(
            {'error': 'Por favor ingrese usuario y contraseña'},
            status=status.HTTP_400_BAD_REQUEST
        )

    user = authenticate(username=username, password=password)

    if user is None:
        return Response(
            {'error': 'Usuario o contraseña incorrectos'},
            status=status.HTTP_401_UNAUTHORIZED
        )

    if not user.is_active:
        return Response(
            {'error': 'Esta cuenta está desactivada'},
            status=status.HTTP_403_FORBIDDEN
        )

    # Obtener o crear token para el usuario
    token, created = Token.objects.get_or_create(user=user)

    return Response({
        'token': token.key,
        'user': {
            'id': user.id,
            'username': user.username,
            'email': user.email,
            'first_name': user.first_name,
            'last_name': user.last_name,
        }
    }, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout_view(request):
    """
    Endpoint de Logout - elimina el token del usuario
    Requiere: Header Authorization: Token <token>
    """
    request.user.auth_token.delete()
    return Response({'message': 'Sesión cerrada correctamente'}, status=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def profile_view(request):
    """
    Endpoint de perfil del usuario autenticado
    Requiere: Header Authorization: Token <token>
    """
    user = request.user
    return Response({
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'first_name': user.first_name,
        'last_name': user.last_name,
        'date_joined': user.date_joined,
        'last_login': user.last_login,
    })
import numpy as np
import tensorflow as tf
from PIL import Image
import io
from rest_framework.decorators import api_view, permission_classes, parser_classes
from rest_framework.parsers import MultiPartParser
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework import status

# Cargar modelo TFLite
import os
MODEL_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'coffee_disease_model.tflite')

interpreter = tf.lite.Interpreter(model_path=MODEL_PATH)
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

CLASS_NAMES = ['Cercosporiosis', 'Hoja sana', 'Roya del café', 'Minador de hojas', 'Phoma']
CLASS_RECOMMENDATIONS = {
    'Cercosporiosis': 'Aplicar fungicidas con mancozeb. Mejorar nutrición del cultivo.',
    'Hoja sana': 'La hoja está sana. Continúe con el mantenimiento preventivo.',
    'Roya del café': 'Aplicar fungicidas cúpricos o triazoles. Eliminar hojas afectadas.',
    'Minador de hojas': 'Aplicar insecticidas sistémicos. Eliminar hojas muy afectadas.',
    'Phoma': 'Mejorar drenaje del suelo. Aplicar fungicidas preventivos.',
}

def predict_image(img_array):
    img_array = img_array.astype(np.float32) / 255.0
    interpreter.set_tensor(input_details[0]['index'], img_array)
    interpreter.invoke()
    output = interpreter.get_tensor(output_details[0]['index'])
    return output[0]

@api_view(['POST'])
@permission_classes([AllowAny])
@parser_classes([MultiPartParser])
def clasificar_hoja(request):
    """
    Endpoint de clasificación de hojas de café
    Recibe: imagen (multipart/form-data)
    Retorna: predicción, confianza y recomendación
    """
    file = request.FILES.get('image')
    if not file:
        return Response({'error': 'No se envió imagen'}, status=status.HTTP_400_BAD_REQUEST)

    try:
        img = Image.open(io.BytesIO(file.read())).convert('RGB')
        img = img.resize((128, 128))
        img_array = np.expand_dims(np.array(img), axis=0)

        prediction = predict_image(img_array)
        predicted_index = int(np.argmax(prediction))
        predicted_class = CLASS_NAMES[predicted_index]
        confidence = float(prediction[predicted_index])

        probabilities = {
            CLASS_NAMES[i]: round(float(p), 4)
            for i, p in enumerate(prediction)
        }

        return Response({
            'prediccion': predicted_class,
            'confianza': round(confidence * 100, 2),
            'recomendacion': CLASS_RECOMMENDATIONS[predicted_class],
            'probabilidades': probabilities
        })

    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)