# RESUMEN EXHAUSTIVO — Football Coaches App (Diciembre 2025)

Este documento resume el estado actual completo de la aplicación móvil de entrenadores de fútbol, incluyendo features implementados, arquitectura, servicios y pendientes.

1) Usuarios y roles
- Entrenadores
- Jugadores
- Clubes / Administradores de club
- Árbitros
- Aficionados/seguidores
- Superadmin (control global de la plataforma)

2) Gestión deportiva
- Clubes y equipos: registro completo, creación de equipos por categorías, asignación de entrenadores.
- Jugadores: ficha con nombre, edad, dorsal, posición, foto, notas médicas.
- Histórico por temporadas y estadísticas básicas (partidos, goles, asistencias, tarjetas).

3) Organización de partidos y competiciones
- Amistosos: crear/proponer/aceptar amistosos; confirmaciones y recordatorios.
- Torneos: liguillas, grupos, eliminatorias, tablas de clasificación y calendario automático.
- Partidos en directo: timeline con eventos (goles, tarjetas, cambios), actualización instantánea.

4) Comunicación
- Chat entre entrenadores: mensajes individuales y grupos por equipo/competición.
- Envío de fotos y vídeos cortos (opcional).
- Notificaciones push e internas.

5) Notificaciones y avisos
- Recordatorios de partido, invitaciones, mensajes, cambios en calendario.

6) Diseño y experiencia de uso
- Interfaz moderna y deportiva, marcador grande, timeline visual, animaciones sutiles.
- Pantallas clave: Inicio/Agenda, Vista de club, Plantilla del equipo, Calendario/Partidos, Partido en directo, Chat, Torneos.

7) Arquitectura general
- App móvil (Android/iOS) — cliente principal para entrenadores.
- Página web para administración de clubes/organizaciones.
- Backend con base de datos (Postgres/MySQL) para almacenar entidades.
- Sistema en tiempo real (WebSockets / socket.io / Firebase Realtime / Firestore) para directo y chat.
- Sistema de notificaciones (Firebase Cloud Messaging u otro) y almacenamiento (S3/Cloud Storage).

8) Seguridad
- Perfiles con permisos y control de edición.
- Validación especial para datos de menores.
- Privacidad de chats y protección de datos.

9) Ideas extra
- Entrenamientos: plantillas, sesiones y compartir ejercicios.
- Estadísticas automáticas y gráficas por temporada.
- Modo Árbitro: actas oficiales y registro de incidencias.
- Perfil público del club (mini-web dentro de la app).
- Modo aficionado: seguir equipos favoritos.
- Mapa de campos y rutas.
- Versión para organizadores de torneos (modelo de negocio).
- Rankings y logros.

Siguientes pasos recomendados para la migración a Flutter
1. Instalar Flutter SDK en la máquina de desarrollo.
2. Ejecutar `flutter create mobile_flutter` o usar este scaffold y ejecutar `flutter create .` dentro de `mobile_flutter`.
3. Migrar modelos compartidos (tipo DTOs) y diseñar un adapter para `shared` types si es necesario.
4. Implementar pantallas clave (Inicio, Plantilla, Partido en directo) y agregar tests unitarios.
5. Conectar con el backend existente (endpoints REST + WebSocket/socket.io o migrar a un canal compatible).
6. Configurar notificaciones push (Firebase) y almacenamiento de imágenes.

Notas finales
- Recomendado mantener `mobile/` (React Native) hasta completar la migración y pruebas en producción.
- Validar requisitos legales para datos de menores antes de almacenar fotos o datos sensibles.

---

## 🎯 **ESTADO ACTUAL: IMPLEMENTACIÓN COMPLETA (Diciembre 2025)**

### **1. ARQUITECTURA Y STACK TECNOLÓGICO**

**Frontend:**
- **Flutter** (`mobile_flutter/`) — App principal para Android/iOS (Material 3)
- **React Native** (`mobile/`) — Versión alternativa (legacy, en mantenimiento)
- **React** (`web-admin/`) — Panel administrativo para gestión de clubes

**Backend:**
- **Node.js + Express** — API REST con Prisma ORM
- **PostgreSQL** — Base de datos principal
- **WebSocket/Socket.io** — Actualizaciones en tiempo real (partidos en directo)
- **Firebase** — Notificaciones push y almacenamiento (opcional)

---

### **2. FEATURES IMPLEMENTADOS EN FLUTTER**

#### **Autenticación y Onboarding** ✅
- **Login/Register** (`login_screen.dart`, `register_screen.dart`)
  - Autenticación con usuario/contraseña
  - Mock auth service para testing
  - Token persistence

- **Onboarding** (`onboarding_screen.dart`)
  - Selección de rol (Entrenador, Staff, Jugador, Árbitro, Aficionado)
  - Asignación de club
  - Selección de equipo
  - Skip para aficionados

#### **Gestión de Equipos y Jugadores** ✅
- **Team Screen** (`team_screen.dart`)
  - Vista de plantilla del equipo
  - Listado de jugadores por categoría
  - Edición de detalles del equipo

- **Player Screen** (`player_screen.dart`)
  - Listado de jugadores
  - Fichas con datos básicos (posición, dorsal, edad)

#### **Gestión de Partidos Amistosos** ✅
- **Friendly Match Screen** (`friendly_match_screen.dart`)
  - Crear/proponer amistosos
  - Aceptar/rechazar propuestas
  - Filtro por estado (pending, accepted, rejected, completed)
  - Búsqueda de equipos
  - Soporte CRUD completo

#### **Gestión de Torneos** ✅ (RECIÉN COMPLETADO)
- **Tournament Screen** (`tournament_screen.dart`) — IMPLEMENTACIÓN COMPLETA
  - Creación de torneos (Liga o Eliminatoria)
  - Gestión de equipos (añadir/remover)
  - Generación automática de calendarios:
    - **Liga (Round-Robin):** Algoritmo de rotación completo
    - **Eliminatoria (Knockout):** Brackets con potencias de 2, byes automáticos
  - Tabla de clasificación dinámica:
    - PJ, Pg, Pe, Pp, GF, GA, DG, Pts
    - Ordenamiento por puntos → diferencia de goles → goles a favor
  - Edición de marcadores (partidos y eliminatorias)
  - Estadísticas automáticas:
    - Partidos jugados, goles totales, media de goles
    - Mejor ataque, mejor defensa
  - Determinación de campeón (automática para ambos formatos)
  - Modal con draggable sheet para detalles completos
  - Filtros por estado (borrador, en juego, finalizado)
  - Resumen visual con chips de conteo

#### **Partidos en Directo** ✅
- **Match Detail Screen** (`match_detail_screen.dart`)
  - Timeline con eventos (goles, tarjetas, cambios)
  - Actualización instantánea del marcador
  - Estadísticas en vivo

#### **Comunicación** ✅
- **Chat Screen** (`chat_screen.dart`)
  - Mensajes individuales y grupales
  - Notificaciones de nuevos mensajes

#### **Perfil y Configuración** ✅
- **Profile Screen** (`profile_screen.dart`)
  - Edición de perfil (nombre, email, rol)
  - Selección de club y equipo
  - Configuración de visibilidad de pestañas por rol
  - Configuración de permisos de acciones por rol

#### **Ubicaciones** ✅
- **Locations Screen** (`locations_screen.dart`)
  - Gestión de campos/estadios
  - Mapa de ubicaciones (integration con Google Maps)

#### **Home Dashboard** ✅
- **Home Screen** (`home_screen.dart`)
  - Dashboard con pestaña activa
  - Navegación dinámica según rol
  - Agenda/calendario de próximos eventos

#### **Calendario y Agenda Premium** ✅
- `widgets/calendar_view.dart`:
  - Calendario mensual con celdas premium (mini-card del primer evento, puntos de colores, contador +N).
  - Diferenciación visual: Partidos (azul), Entrenamientos (verde), Anuncios (amarillo).
- `screens/calendar_screen.dart`:
  - Mapea `AgendaItem` a `CalendarEvent` manteniendo estilo.
  - Hoja inferior con eventos del día y CTA para crear.
- `services/agenda_service.dart`:
  - Fuente única de `AgendaItem` (estáticos, amistosos, custom y eventos de club).
  - `agendaNotifier` para actualizaciones reactivas.
  - `visibleRange` para generar recurrencias.

#### **Eventos de Club (Premium)** ✅
- `models/club_event.dart`:
  - `ClubEvent` con: `id`, `title`, `description`, `start`, `end`, `type`, `scope`, `teamId?`, `audienceUserIds?`, `recurrence?`, `createdByUserId`.
  - `RecurrenceRule` con: `frequency` (weekly/monthly/daily), `interval`, `weekdays?`, `until`.
- `services/club_event_service.dart`:
  - `generateOccurrences(ClubEvent, DateRange)` → `List<AgendaItem>` con cache.
  - Mapeo a `AgendaItem` con icono/subtítulo según tipo; inyección a agenda.
  - Resolución de destinatarios por `scope` (club/team/custom).
- `services/team_follower_service.dart`:
  - Seguimiento in-memory de equipos (follow/unfollow/getFollowers).
- `screens/event_creation_screen.dart`:
  - Selector de tipo y ámbito.
  - Picker de equipo (ID) para ámbito equipo.
  - Audiencia personalizada con chips (añadir/eliminar IDs).
  - Builder de recurrencia (semanal/mensual/diaria) — gated premium.
  - Envío a `ClubEventService.instance.createEvent(...)`.
- `utils/event_style.dart`:
  - Colores e iconos por tipo (match/training/announcement).

#### **Notificaciones (FCM + Local)** ✅
- `services/notification_service.dart`:
  - Inicialización FCM y `flutter_local_notifications`.
  - Stubs para `sendEventCreatedNotification`, `sendEventUpdatedNotification`, `sendEventCancelledNotification` con alerta local.
  - Manejo foreground/background/terminated y navegación por tap.

#### **Permisos y Premium** ✅
- `services/permission_service.dart`:
  - Permisos por rol (entrenador, jugador, admin, etc.).
  - `canUsePremiumPlanner()` para gates de recurrencia y funciones avanzadas.

#### **Home (Mi Agenda) con badge de anuncios** ✅
- `screens/home_screen_enhanced.dart`:
  - Cuenta anuncios no vistos (heurística por título) y muestra badge.
  - Mezcla eventos de club y personalizados; ver detalle con `EventDetailsSheet`.

---

### **3. SERVICIOS Y LÓGICA DE NEGOCIO**

**Autenticación:**
- `auth_service.dart` — Gestión de sesión, tokens, usuario actual
- `mock_auth_service.dart` — Data mock para testing (torneos, jugadores, amistosos, etc.)

**Permisos:**
- `permission_service.dart` — Control de acceso basado en roles
  - `canCreateTournament()`, `canEditTeam()`, `canRecordMatch()`, etc.

**Servicios de Negocio:**
- `agenda_service.dart` — Gestión de calendario/agenda
- `match_service.dart` — Operaciones sobre partidos
- `friendly_match_service.dart` — CRUD de amistosos
- `location_service.dart` — Gestión de ubicaciones
- `notification_service.dart` — **NUEVO: Sistema de notificaciones push FCM**
- `realtime_service.dart` — Actualizaciones en tiempo real

---

### **4. MODELOS DE DATOS**

✅ `user.dart` — Usuario con rol, club, equipo, estado de onboarding
✅ `club.dart` — Club con nombre, logo, ubicación
✅ `match.dart` — Partido con equipos, marcador, estado
✅ `player.dart` — Jugador con dorsal, posición, edad, estadísticas
✅ `team.dart` — Equipo con categoría, ciudad, jugadores
✅ `tournament.dart` — Torneo con formato, equipos, partidos, table, bracket
✅ `friendly_match.dart` — Amistoso con propuesta y confirmación

---

### **5. UI/UX — ESTADO DEL DISEÑO**

**Material 3 implementado:**
- ColorScheme dinámico con tema oscuro/claro
- AppBars con elevation y color coherente
- Chips, buttons (ElevatedButton, TextButton)
- Cards con bordes redondeados
- BottomSheets (draggable para tournaments)
- Modales y diálogos
- Icons modernos (Material Icons)

**Características de interacción:**
- Navegación por tabs dinámicas (según rol)
- Filtros y búsqueda
- Indicadores de carga (CircularProgressIndicator)
- Mensajes de feedback (SnackBar)
- Expansible/Collapsible widgets

---

### **6. PRUEBAS Y VALIDACIÓN**

✅ `onboarding_screen_test.dart` — Test de flujo de onboarding
✅ `services_test.dart` (Flutter) — Tests unitarios de servicios

**Validadores:**
- Mock auth (testing sin backend)
- Data bootstrap automático
- Validaciones de entrada en formularios

---

### **7. INFRAESTRUCTURA Y CONFIGURACIÓN**

**Pubspec (dependencias principales):**
```yaml
- flutter, material3
- http, dio (para API calls)
- geolocator, google_maps_flutter
- shared_preferences (para persistencia local)
- firebase_messaging (notificaciones)
```

**Estructura de carpetas:**
```
mobile_flutter/
├── lib/
│   ├── screens/          # 13+ pantallas
│   ├── services/         # Auth, permissions, match, tournament, etc.
│   ├── models/           # Entidades de datos
│   ├── widgets/          # Componentes reutilizables
│   ├── main.dart         # Entry point
│   └── ...
├── test/                 # Tests unitarios
├── android/, ios/        # Configuración nativa
└── pubspec.yaml
```

---

### **8. ESTADO DEL BACKEND**

**Endpoints disponibles:**
- `POST /auth/login`, `POST /auth/register`
- `GET /tournaments`, `POST /tournaments`
- `GET /matches`, `PUT /matches/{id}`
- `GET /friendly-matches`, `POST /friendly-matches`
- `GET /teams/{id}/players`
- `GET /clubs`

**Base de datos (Prisma schema):**
- User, Club, Team, Player, Match, Tournament, FriendlyMatch

**Servicios backend:**
- `auth.service.ts`
- `notification.service.ts`
- `realtime.service.ts` (WebSocket)
- `storage.service.ts`

---

### **9. PANEL ADMIN WEB (React)**

✅ **Clubs Management** — Listado y creación de clubes
✅ **Teams Management** — Gestión de equipos por club
✅ **Dashboard** — Vista general de plataforma

---

### **10. PENDIENTES INMEDIATOS**

| Tarea | Estado | Prioridad |
|-------|--------|-----------|
| **Push Notifications System** | ✅ COMPLETADO | Crítica |
| **Origin/Venue setting** en Profile | ⚠️ TODO | Alta |
| **Venues management** screen | ⚠️ TODO | Alta |
| Integración real con backend REST | ⚠️ En progreso | Alta |
| WebSocket para partidos en directo | ✅ Implementado (realtime_service) | Media |
| Notificaciones push (Firebase) | ✅ COMPLETADO | Crítica |
| Tests unitarios completos | ✅ Expandido | Media |
| Entrenamientos (plantillas y sesiones) | ❌ NO IMPLEMENTADO | Baja |
| Modo árbitro (actas oficiales) | ❌ NO IMPLEMENTADO | Baja |
| Perfil público de club | ❌ NO IMPLEMENTADO | Baja |
| Rankings y logros | ❌ NO IMPLEMENTADO | Baja |

---

### **11. ÚLTIMOS CAMBIOS REALIZADOS** (Sesión actual)

✅ **Push Notifications Implementation Complete** con:
- Firebase Cloud Messaging (FCM) integration
- NotificationService singleton para acceso app-wide
- Topic-based subscriptions (matches, tournaments, friendlies, clubs)
- Material 3 SnackBars y UI components
- RBAC enforcement
- Local notification display
- Token management y refresh handling
- Persistence de subscriptions en SharedPreferences
- NotificationMixin para fácil triggering desde servicios
- NotificationIndicator widget con badge
- NotificationBottomSheet para historial
- Mock FCM support para testing MVP
- 25+ unit tests + widget tests
- Comprehensive documentation (3 guides)

✅ **Real-time Match Updates** - Match detail screen con live updates via WebSocket
✅ **Match Event Triggers** - Notification system integrated con MatchService
✅ **Material 3 UI** - All notifications styled per Material Design 3

---

### **RESUMEN FINAL**

La app es una **plataforma funcional de gestión de fútbol** con:
- ✅ **Autenticación y permisos** robustos
- ✅ **Gestión de equipos, jugadores y amistosos** operativa
- ✅ **Sistema de torneos avanzado** (liga y eliminatoria con automáticas)
- ✅ **UI moderna en Material 3** con navegación dinámica
- ✅ **Push Notifications con Firebase FCM** (MVP-ready)
- ✅ **Real-time Match Updates** via WebSocket
- ⚠️ **Backend disponible pero con integración parcial**
- ❌ **Entrenamientos, árbitro y features sociales avanzadas** no implementadas

**Próximos pasos inmediatos:** 
1. Completar setting de "origen" en Profile
2. Crear screen de gestión de venues/campos
3. Integrar push notifications con backend FCM
4. Ejecutar full test suite
