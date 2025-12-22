# 🧪 MANUAL TESTING SESSION - Football Coaches App
**Fecha:** Diciembre 6, 2025  
**Tester:** Usuario + GitHub Copilot AI  
**Plataforma:** Chrome (Web)  
**Estado App:** ✅ Running on http://localhost:55679  
**Debug Service:** ws://127.0.0.1:56411

---

## ⚡ STATUS ACTUAL

**App State:** ✅ CARGADA Y CORRIENDO  
**Firebase:** ⚠️ Service Worker error (esperado en web local)  
**Notifications:** ⚠️ Skipped en web (esperado)  
**Compilación:** ✅ Sin errores  
**Hot Reload:** ✅ Disponible (tecla 'r')

---

## 🎯 INSTRUCCIONES PARA EL USUARIO

La app está corriendo en **Chrome**. Sigue este checklist y marca cada item:

1. Abre Chrome en `http://localhost:55679`
2. Abre DevTools (F12) para ver console logs
3. Sigue el checklist abajo marcando ✅ o ❌ según funcione
4. Anota cualquier error que veas en la consola

---

## ✅ CHECKLIST DE TESTING MANUAL

### 1. 🔐 AUTENTICACIÓN Y ROLES

#### 1.1 Login como Coach
- [ ] Navegar a pantalla de login
- [ ] Ingresar credenciales: coach@test.com / password123
- [ ] Verificar login exitoso
- [ ] Confirmar dashboard se carga
- [ ] Verificar tabs visibles: Inicio, Equipo, Amistosos, Torneos, Chat, Perfil

**Resultado:**
**Errores:**
**Screenshots:**

---

#### 1.2 Login como Player
- [ ] Logout de coach
- [ ] Login con: player@test.com / password123
- [ ] Verificar tabs limitados (sin Torneos)
- [ ] Confirmar acceso restringido

**Resultado:**
**Errores:**

---

#### 1.3 Login como Superadmin
- [ ] Login con: admin@test.com / admin123
- [ ] Verificar acceso completo a todas las funcionalidades
- [ ] Confirmar todos los tabs visibles

**Resultado:**
**Errores:**

---

### 2. 🏆 TORNEOS (TOURNAMENTS)

#### 2.1 Ver lista de torneos
- [ ] Click en tab "Torneos"
- [ ] Verificar lista de torneos se carga
- [ ] Confirmar mock data aparece

**Resultado:**
**Torneos visibles:**
**Errores:**

---

#### 2.2 Crear nuevo torneo
- [ ] Click en botón "+" o "Crear Torneo"
- [ ] Llenar formulario:
  - Nombre: "Liga E2E Test"
  - Descripción: "Torneo de prueba manual"
  - Categoría: Sub-14
  - Formato: Liga
  - Fecha inicio: [seleccionar]
- [ ] Click "Guardar"
- [ ] Verificar torneo aparece en lista

**Resultado:**
**Torneo creado:** Sí / No
**ID del torneo:**
**Errores:**

---

#### 2.3 Editar torneo existente
- [ ] Click en torneo creado
- [ ] Click en botón "Editar"
- [ ] Modificar nombre a "Liga E2E Modificada"
- [ ] Guardar cambios
- [ ] Verificar cambios reflejados

**Resultado:**
**Modificación exitosa:** Sí / No
**Errores:**

---

#### 2.4 Eliminar torneo
- [ ] Click en botón "Eliminar" del torneo test
- [ ] Confirmar eliminación en diálogo
- [ ] Verificar torneo ya no aparece

**Resultado:**
**Eliminación exitosa:** Sí / No
**Errores:**

---

### 3. 🤝 AMISTOSOS (FRIENDLY MATCHES)

#### 3.1 Ver lista de amistosos
- [ ] Click en tab "Amistosos"
- [ ] Verificar lista se carga
- [ ] Confirmar mock data visible

**Resultado:**
**Amistosos visibles:**
**Errores:**

---

#### 3.2 Crear nuevo amistoso
- [ ] Click en "+" o "Crear Amistoso"
- [ ] Llenar formulario:
  - Club rival: "Club Test E2E"
  - Contacto: "contacto@test.com"
  - Ubicación: "Campo Municipal"
  - Fecha: [seleccionar]
  - Categoría: Sub-14
  - Notas: "Amistoso de prueba"
- [ ] Guardar
- [ ] Verificar aparece en lista

**Resultado:**
**Amistoso creado:** Sí / No
**Estado inicial:**
**Errores:**

---

#### 3.3 Aceptar propuesta de amistoso
- [ ] Buscar amistoso en estado "Propuesto"
- [ ] Click en "Aceptar"
- [ ] Verificar estado cambia a "Aceptado"

**Resultado:**
**Cambio de estado:** Sí / No
**Errores:**

---

#### 3.4 Rechazar propuesta
- [ ] Buscar otro amistoso propuesto
- [ ] Click en "Rechazar"
- [ ] Verificar estado cambia a "Rechazado"

**Resultado:**
**Errores:**

---

#### 3.5 Filtrar amistosos por estado
- [ ] Click en filtro "Todos"
- [ ] Seleccionar "Aceptados"
- [ ] Verificar solo muestra aceptados
- [ ] Probar filtro "Propuestos"
- [ ] Probar filtro "Rechazados"

**Resultado:**
**Filtros funcionan:** Sí / No
**Errores:**

---

### 4. 👥 EQUIPOS Y JUGADORES

#### 4.1 Ver equipo actual
- [ ] Click en tab "Equipo"
- [ ] Verificar lista de jugadores se carga
- [ ] Confirmar datos mock visibles

**Resultado:**
**Jugadores visibles:**
**Errores:**

---

#### 4.2 Crear equipo virtual
- [ ] Click en "Crear Equipo" (si disponible)
- [ ] Nombre: "Equipo E2E Test"
- [ ] Categoría: Sub-14
- [ ] Guardar
- [ ] Verificar equipo creado

**Resultado:**
**Equipo creado:** Sí / No
**Errores:**

---

#### 4.3 Agregar jugador
- [ ] Click en "Agregar Jugador"
- [ ] Llenar datos:
  - Nombre: Juan
  - Apellido: Pérez
  - Dorsal: 10
  - Posición: Delantero
  - Edad: 14
- [ ] Guardar
- [ ] Verificar jugador en lista

**Resultado:**
**Jugador agregado:** Sí / No
**Errores:**

---

#### 4.4 Editar información de jugador
- [ ] Click en jugador creado
- [ ] Click "Editar"
- [ ] Cambiar dorsal a "7"
- [ ] Guardar
- [ ] Verificar cambio reflejado

**Resultado:**
**Edición exitosa:** Sí / No
**Errores:**

---

#### 4.5 Eliminar jugador
- [ ] Click en jugador test
- [ ] Click "Eliminar"
- [ ] Confirmar eliminación
- [ ] Verificar ya no aparece

**Resultado:**
**Eliminación exitosa:** Sí / No
**Errores:**

---

### 5. 🔔 NOTIFICACIONES

#### 5.1 Ver indicador de notificaciones
- [ ] Verificar icono de campana en AppBar
- [ ] Confirmar badge con número (si hay notifs)
- [ ] Click en campana
- [ ] Verificar panel/modal se abre

**Resultado:**
**Indicador visible:** Sí / No
**Número de notificaciones:**
**Panel abre:** Sí / No
**Errores:**

---

#### 5.2 Ver lista de notificaciones
- [ ] Abrir panel de notificaciones
- [ ] Verificar lista de notificaciones
- [ ] Confirmar timestamps
- [ ] Verificar iconos/avatares

**Resultado:**
**Notificaciones mostradas:**
**Errores:**

---

#### 5.3 Marcar notificación como leída
- [ ] Click en notificación no leída
- [ ] Verificar cambia a estado "leída"
- [ ] Confirmar contador disminuye

**Resultado:**
**Marca como leída:** Sí / No
**Errores:**

---

#### 5.4 Limpiar todas las notificaciones
- [ ] Click en "Limpiar todo"
- [ ] Confirmar acción
- [ ] Verificar lista vacía
- [ ] Confirmar contador en 0

**Resultado:**
**Limpieza exitosa:** Sí / No
**Errores:**

---

### 6. 💬 CHAT EN TIEMPO REAL

#### 6.1 Abrir pantalla de chat
- [ ] Click en tab "Chat"
- [ ] Verificar interfaz de chat carga
- [ ] Confirmar lista de mensajes visible

**Resultado:**
**Chat carga:** Sí / No
**Mensajes visibles:**
**Errores:**

---

#### 6.2 Enviar mensaje
- [ ] Escribir en input: "Mensaje de prueba E2E"
- [ ] Click en botón enviar
- [ ] Verificar mensaje aparece en lista
- [ ] Confirmar timestamp correcto

**Resultado:**
**Mensaje enviado:** Sí / No
**Timestamp:** 
**Errores:**

---

#### 6.3 Ver historial de mensajes
- [ ] Scroll hacia arriba
- [ ] Verificar mensajes antiguos cargan
- [ ] Confirmar orden cronológico

**Resultado:**
**Historial funciona:** Sí / No
**Errores:**

---

#### 6.4 Recepción en tiempo real
- [ ] Dejar chat abierto
- [ ] Esperar 30 segundos
- [ ] Verificar si llegan mensajes nuevos automáticamente

**Resultado:**
**Recepción real-time:** Sí / No
**Errores:**

---

### 7. 🧭 NAVEGACIÓN

#### 7.1 Navegación entre tabs
- [ ] Click en cada tab en orden:
  - Inicio → ✅
  - Equipo → ✅
  - Amistosos → ✅
  - Torneos → ✅
  - Chat → ✅
  - Perfil → ✅
- [ ] Volver a Inicio
- [ ] Verificar contenido correcto en cada uno

**Resultado:**
**Navegación fluida:** Sí / No
**Tabs se mantienen visibles:** Sí / No
**Errores:**

---

#### 7.2 Click en agenda (Dashboard)
- [ ] En tab "Inicio", buscar agenda
- [ ] Click en evento de torneo
- [ ] Verificar navega a tab "Torneos" (NO nueva pantalla)
- [ ] Volver a Inicio
- [ ] Click en evento de amistoso
- [ ] Verificar navega a tab "Amistosos"

**Resultado:**
**Navegación desde agenda funciona:** Sí / No
**Tabs permanecen visibles:** Sí / No
**Bug arreglado:** ✅
**Errores:**

---

#### 7.3 Logout
- [ ] Click en botón logout (icono)
- [ ] Verificar regresa a login
- [ ] Confirmar sesión cerrada
- [ ] Verificar no puede acceder a rutas protegidas

**Resultado:**
**Logout funciona:** Sí / No
**Errores:**

---

### 8. 👤 PERFIL Y CONFIGURACIÓN

#### 8.1 Ver información de perfil
- [ ] Click en tab "Perfil"
- [ ] Verificar datos del usuario:
  - Nombre
  - Email
  - Rol
  - Club activo
- [ ] Confirmar datos correctos

**Resultado:**
**Perfil muestra datos:** Sí / No
**Datos correctos:** Sí / No
**Errores:**

---

#### 8.2 Cambiar club activo
- [ ] En perfil, buscar dropdown de clubes
- [ ] Seleccionar club diferente
- [ ] Guardar cambio
- [ ] Verificar club actualizado

**Resultado:**
**Cambio de club funciona:** Sí / No
**Errores:**

---

#### 8.3 Cambiar venue preferido
- [ ] Buscar dropdown de venues
- [ ] Seleccionar venue diferente
- [ ] Verificar cambio se guarda

**Resultado:**
**Cambio de venue funciona:** Sí / No
**Errores:**

---

### 9. 🎨 UI/UX Y PERFORMANCE

#### 9.1 Responsive design
- [ ] Redimensionar ventana de navegador
- [ ] Verificar UI se adapta
- [ ] Probar en diferentes tamaños

**Resultado:**
**Responsive:** Sí / No
**Errores:**

---

#### 9.2 Tiempo de carga
- [ ] Medir tiempo de carga inicial
- [ ] Medir tiempo de navegación entre tabs
- [ ] Verificar loading indicators

**Resultado:**
**Tiempo carga inicial:**
**Navegación fluida:** Sí / No
**Loading indicators:** Sí / No

---

#### 9.3 Manejo de errores
- [ ] Intentar acción sin permisos
- [ ] Verificar mensaje de error
- [ ] Confirmar app no crashea

**Resultado:**
**Errores manejados:** Sí / No

---

## 📊 RESUMEN DE RESULTADOS

### Tests Completados: 0/XX
### Tests Pasados: 0
### Tests Fallidos: 0
### Bugs Encontrados: 0

---

## 🐛 BUGS DETECTADOS

### Bug #1
**Severidad:**
**Descripción:**
**Pasos para reproducir:**
**Comportamiento esperado:**
**Comportamiento actual:**
**Screenshots:**

---

## ✅ FEATURES FUNCIONANDO CORRECTAMENTE

1. 
2. 
3. 

---

## ❌ FEATURES NO FUNCIONANDO

1. 
2. 
3. 

---

## 🎯 CONCLUSIONES

**Estado General:**

**Recomendaciones:**

**Próximos Pasos:**

---

**Testing iniciado:** 
**Testing completado:** 
**Duración total:**
