# 🚀 GUÍA RÁPIDA DE TESTING MANUAL

## ✅ LA APP ESTÁ CORRIENDO

**URL:** http://localhost:55679  
**Presiona F12** para abrir Chrome DevTools

---

## 🎯 PRUEBAS RÁPIDAS (5 minutos)

### 1️⃣ LOGIN (30 seg)
```
✅ ¿Ves la pantalla de login?
✅ ¿Hay campos de email y password?
✅ ¿Hay botón "Iniciar Sesión"?

Credenciales de prueba:
- Coach: coach@test.com / password123
- Player: player@test.com / password123  
- Admin: admin@test.com / admin123
```

### 2️⃣ DASHBOARD (30 seg)
```
Después de login:
✅ ¿Ves el título "Football Coaches"?
✅ ¿Ves 6 tabs en la parte inferior?
   - Inicio
   - Equipo
   - Amistosos
   - Torneos
   - Chat
   - Perfil
✅ ¿Ves la agenda con eventos?
```

### 3️⃣ NAVEGACIÓN (1 min)
```
Clickea cada tab:
✅ Equipo → ¿Muestra jugadores?
✅ Amistosos → ¿Muestra partidos amistosos?
✅ Torneos → ¿Muestra torneos/ligas?
✅ Chat → ¿Muestra interfaz de chat?
✅ Perfil → ¿Muestra tus datos?
✅ Inicio → ¿Vuelve al dashboard?

IMPORTANTE: ¿Los tabs permanecen visibles todo el tiempo? (Sí/No)
```

### 4️⃣ CREAR TORNEO (1 min)
```
En tab "Torneos":
✅ ¿Ves botón "+" o "Crear"?
✅ Click en crear → ¿Abre formulario?
✅ Llena:
   - Nombre: "Liga Test"
   - Categoría: Sub-14
✅ Guardar → ¿Aparece en la lista?
```

### 5️⃣ CREAR AMISTOSO (1 min)
```
En tab "Amistosos":
✅ ¿Ves botón "+"?
✅ Click crear → ¿Abre formulario?
✅ Llena:
   - Club rival: "Club Test"
   - Ubicación: "Campo Municipal"
✅ Guardar → ¿Aparece en lista?
```

### 6️⃣ EQUIPO (1 min)
```
En tab "Equipo":
✅ ¿Ves lista de jugadores?
✅ ¿Hay botón "Agregar Jugador"?
✅ Click agregar → ¿Abre formulario?
✅ Llena datos de jugador
✅ Guardar → ¿Aparece en lista?
```

### 7️⃣ NOTIFICACIONES (30 seg)
```
En el AppBar (arriba):
✅ ¿Ves icono de campana (🔔)?
✅ Click en campana → ¿Abre panel?
✅ ¿Hay notificaciones?
```

### 8️⃣ CHAT (30 seg)
```
En tab "Chat":
✅ ¿Ves campo de texto abajo?
✅ Escribe "Hola" y envía
✅ ¿Aparece tu mensaje?
```

### 9️⃣ PERFIL (30 seg)
```
En tab "Perfil":
✅ ¿Ves tu email?
✅ ¿Hay dropdown de clubes?
✅ ¿Hay dropdown de venues?
✅ Cambia club → ¿Se guarda?
```

### 🔟 LOGOUT (15 seg)
```
✅ Click en icono logout (arriba derecha)
✅ ¿Regresa a pantalla de login?
✅ ¿No puedes acceder sin login?
```

---

## 🐛 REPORTA BUGS AQUÍ

**Si algo no funciona, anota:**
1. ¿Qué hiciste? (pasos)
2. ¿Qué esperabas?
3. ¿Qué pasó en realidad?
4. ¿Qué dice la consola? (F12 → Console)

---

## ⏱️ TIEMPO ESTIMADO

- ✅ Básico (10 pruebas): **5-7 minutos**
- ✅ Completo (40 pruebas): **15-20 minutos**
- ✅ Exhaustivo (con edge cases): **30-40 minutos**

---

## 📊 MARCA TU PROGRESO

```
COMPLETADO: ___ / 10 pruebas básicas

✅ = Funciona perfectamente
⚠️ = Funciona con warnings
❌ = No funciona
🔄 = No probado aún
```

---

**MIENTRAS PRUEBAS MANUALMENTE, YO EJECUTARÉ LOS TESTS AUTOMATIZADOS E2E** 🤖
