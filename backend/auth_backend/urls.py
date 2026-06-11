from django.contrib import admin
from django.urls import path, include
from django.http import JsonResponse


def api_root(request):
    return JsonResponse({
        "sistema": "CaféDetect API",
        "version": "1.0",
        "grupo": "Grupo 05 — Interacción Hombre-Computador",
        "frontend": "https://pruebaihccafe.netlify.app",
        "endpoints": {
            "registro":         "/api/auth/register/",
            "login":            "/api/auth/login/",
            "logout":           "/api/auth/logout/",
            "clasificar":       "/api/auth/clasificar/",
            "historial":        "/api/auth/historial/",
            "estadisticas":     "/api/auth/stats/",
            "perfil":           "/api/auth/profile/",
            "actualizar_perfil":"/api/auth/update_profile/",
            "cambiar_password": "/api/auth/change_password/",
        },
        "estado": "activo"
    })


urlpatterns = [
    path('',        api_root),
    path('admin/',  admin.site.urls),
    path('api/auth/', include('users.urls')),
]

