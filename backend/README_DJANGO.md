# Backend Django — Auth API (Grupo 5)

## Endpoints disponibles

| Método | URL              | Descripción              | Auth requerida |
|--------|-----------------|--------------------------|----------------|
| POST   | /api/auth/login/ | Autenticar usuario        | No             |
| POST   | /api/auth/logout/| Cerrar sesión            | Sí (Token)     |
| GET    | /api/auth/profile/| Ver perfil del usuario  | Sí (Token)     |

## Instalación

```bash
pip install django djangorestframework django-cors-headers
python manage.py migrate
python manage.py runserver
```

## Usuarios de prueba creados
| Usuario  | Contraseña | Rol          |
|----------|-----------|--------------|
| admin    | admin123  | Administrador|
| usuario  | pass123   | Usuario normal|

## Ejemplo de uso (Login)
```
POST /api/auth/login/
Content-Type: application/json

{ "username": "usuario", "password": "pass123" }

→ 200 OK
{ "token": "abc123...", "user": { "id": 2, "username": "usuario", ... } }
```
