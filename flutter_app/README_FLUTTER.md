# Flutter App — Login (Grupo 5)

## Estructura del proyecto
```
lib/
├── main.dart                  ← Punto de entrada
├── models/
│   └── user_model.dart        ← Modelo de usuario
├── services/
│   └── auth_service.dart      ← Comunicación con Django API
└── screens/
    ├── login_screen.dart      ← Pantalla de Login
    └── home_screen.dart       ← Pantalla Principal
```

## Instalación y ejecución

1. Asegúrate de tener Flutter instalado (flutter.dev)
2. Instala dependencias:
   ```bash
   flutter pub get
   ```
3. Ajusta la URL del backend en `lib/services/auth_service.dart`:
   - Emulador Android → `http://10.0.2.2:8000/api/auth`
   - Dispositivo físico → `http://<TU-IP-LOCAL>:8000/api/auth`
   - Web → `http://localhost:8000/api/auth`

4. Ejecuta la app:
   ```bash
   flutter run
   ```

## Dependencias (pubspec.yaml)
- `http` → Peticiones HTTP al backend Django
- `shared_preferences` → Guardar token de sesión localmente
