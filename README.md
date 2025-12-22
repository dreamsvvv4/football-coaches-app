# Football Coaches App (Premium) — guía sencilla

Este repositorio contiene una plataforma “premium” para clubes y entrenadores: equipos, jugadores, calendario, notificaciones, búsqueda/creación de amistosos y convocatorias.

Objetivo de esta limpieza: dejar **solo lo útil y funcional** como núcleo, y apartar lo antiguo/experimental.

## Núcleo recomendado (lo que se mantiene)

Estructura (nivel alto):
```
mobile_flutter/  App principal (Flutter) — lo que vas a probar y usar
backend/         API (Node.js/Express) — para modo “real” con servidor
web-admin/       Panel web (React) — administración de club (opcional)
shared/          Tipos/utilidades compartidas (TypeScript)
docs/            Documentación (técnica + testing)
scripts/         Scripts auxiliares
ARCHIVE/         Material legado/archivado (no forma parte del núcleo)
```

`ARCHIVE/` contiene lo que se ha apartado para simplificar (React Native, infraestructura, microservicios, etc.). Si más adelante lo necesitas, sigue ahí.

## Probar la app manualmente (Windows)

### Opción A: App nativa Windows
```powershell
Set-Location c:\Users\vvvfb\Documents\football-coaches-app\mobile_flutter
flutter pub get
flutter run -d windows
```

### Opción B: Web (Chrome)
```powershell
Set-Location c:\Users\vvvfb\Documents\football-coaches-app\mobile_flutter
flutter pub get
flutter run -d chrome
```

Notas:
- La documentación propia de Flutter está en `mobile_flutter/README.md`.
- En `mobile_flutter/lib/main.dart` hay datos demo en debug para poder navegar y probar sin backend.

## Backend (modo “real”)

Si quieres que sea 100% “premium” con servidor y datos persistentes, el backend está en `backend/`.

Importante (para no romper nada):
- El backend actual usa **MongoDB (mongoose)** (`MONGODB_URI`).
- Existe `backend/prisma/schema.prisma`, pero ahora mismo **no parece estar conectado** al backend.
- La infraestructura Docker/K8s/Terraform se movió a `ARCHIVE/` porque no está alineada (había Postgres y el backend usa MongoDB).

Arranque básico (requiere Node.js + MongoDB):
```powershell
Set-Location c:\Users\vvvfb\Documents\football-coaches-app\backend
npm install
npm run dev
```

## Testing (pasos guiados)

Documentos recomendados:
- `docs/testing/START_TESTING_HERE.md`
- `docs/testing/MVP_TESTING_QUICK_START.md`
- `docs/testing/MVP_TESTING_CHECKLIST.md`

## Limpieza segura (lo que se puede borrar localmente)

En `mobile_flutter/` se pueden borrar sin riesgo:
- `build/`
- `.dart_tool/`
- logs/resultados locales (`*.log`, `*.txt`) si son solo reportes

Comando útil:
```powershell
Set-Location c:\Users\vvvfb\Documents\football-coaches-app\mobile_flutter
flutter clean
```