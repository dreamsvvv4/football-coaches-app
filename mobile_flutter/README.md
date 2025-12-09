# Football Coaches App - Flutter

Aplicación móvil (web/Android/iOS) para entrenadores de fútbol con gestión de equipos, jugadores, partidos en directo y comunicación.

## Requisitos previos

- **Flutter SDK**: [Instalar Flutter](https://flutter.dev/docs/get-started/install)
- **Node.js** (opcional): Para ejecutar el backend en `http://localhost:3000`

## Instalación rápida

```bash
# 1. Instalar dependencias Dart/Flutter
cd mobile_flutter
flutter pub get

# 2. Ejecutar en Chrome (desarrollo rápido)
flutter run -d chrome

# O en Android (emulador o dispositivo físico)
flutter run -d emulator-5554
```

## Estructura del proyecto

```
lib/
├── main.dart                 # Punto de entrada, configuración de rutas
├── screens/                  # Pantallas principales
│   ├── home_screen.dart      # Menú principal
│   ├── login_screen.dart     # Login
│   ├── register_screen.dart  # Registro
│   ├── club_screen.dart      # Mis clubes
│   ├── player_screen.dart    # Jugadores
│   ├── team_screen.dart      # Plantilla del equipo
│   ├── match_live_screen.dart # Partido en directo
│   ├── tournament_screen.dart # Torneos
│   └── chat_screen.dart      # Chat
├── services/
│   ├── api_service.dart      # Cliente HTTP REST
│   ├── auth_service.dart     # Autenticación y gestión de tokens
│   ├── token_storage.dart    # Almacenamiento seguro de tokens
│   ├── mock_auth_service.dart # Mock data para desarrollo sin backend
│   └── realtime_service.dart # WebSocket/realtime (stub)
└── models/
    ├── user.dart
    ├── club.dart
    ├── team.dart
    ├── player.dart
    ├── match_model.dart
    └── tournament.dart
```

## Funcionalidades

✅ **Autenticación**
- Registro e inicio de sesión
- Persistencia segura de tokens (flutter_secure_storage)
- Logout

✅ **Pantallas principales**
- Inicio/Menú
- Mis clubes y equipos
- Plantilla de jugadores
- Partido en directo (timeline)
- Torneos
- Chat simple

✅ **Características técnicas**
- Hot reload para desarrollo rápido
- Mock data para desarrollo sin backend
- Autorización automática en llamadas HTTP
- Manejo de errores y logs

## Configuración

### Backend real
Si tienes un backend corriendo en `http://localhost:3000`:

1. Abre `lib/main.dart`
2. Cambia: `AuthService.instance.setUseMock(false);`
3. Hot reload (presiona `r` en la terminal)

### URL del backend
Edita `lib/services/api_service.dart`:
```dart
String baseUrl = 'http://localhost:3000';  // Para web/Windows
String baseUrl = 'http://10.0.2.2:3000';   // Para emulador Android
String baseUrl = 'http://192.168.1.100:3000'; // Para dispositivo físico
```

## Comandos útiles

```powershell
# Hot reload (durante desarrollo)
# Presiona 'r' en la terminal donde corre flutter run

# Hot restart (reinicio completo)
# Presiona 'R' en la terminal

# Ver logs
flutter logs

# Generar APK (Android)
flutter build apk --release

# Generar IPA (iOS, solo en macOS)
flutter build ios --release

# Limpiar caché
flutter clean
```

## Notas de desarrollo

- **Mock vs Real**: Actualmente usa `setUseMock(true)`. Cambia a `false` cuando tengas backend corriendo.
- **CORS**: Si hay errores de CORS, configura tu backend para aceptar `http://localhost:58364` (Puerto dinámico de Chrome en Flutter).
- **Seguridad**: Los tokens se almacenan en `flutter_secure_storage` (encriptado en dispositivo).
- **Realtime**: `RealtimeService` es un stub; integra `socket.io-client` cuando sea necesario.

## Próximos pasos recomendados

1. Instalar backend Node.js en `backend/` y cambiar `setUseMock(false)`.
2. Conectar `RealtimeService` con WebSocket para chat y eventos en directo.
3. Implementar notificaciones push (Firebase Cloud Messaging).
4. Compilar y publicar en Google Play / App Store.
5. Mejorar UI con diseño deportivo (colores, animaciones, iconografía).

## Licencia

MIT

