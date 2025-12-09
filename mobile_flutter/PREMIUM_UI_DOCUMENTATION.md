# 🎨 **PREMIUM UI/UX SYSTEM - DOCUMENTACIÓN COMPLETA**

**Football Coaches App - Advanced Design System**  
**Versión:** 2.0  
**Fecha:** Diciembre 6, 2025  
**Inspiración:** OneFootball, FIFA, NBA Apps

---

## 📋 **ÍNDICE**

1. [Sistema de Diseño](#sistema-de-diseño)
2. [Componentes Premium](#componentes-premium)
3. [Animaciones](#animaciones)
4. [Dark/Light Mode](#darklight-mode)
5. [Widgets Especializados](#widgets-especializados)
6. [Guía de Uso](#guía-de-uso)
7. [Ejemplos](#ejemplos)

---

## 🎨 **SISTEMA DE DISEÑO**

### **AppTheme** (`lib/theme/app_theme.dart`)

Sistema completo de design tokens con modo claro y oscuro.

#### **Colores de Marca**
```dart
AppTheme.primaryGreen    // #0E7C61 - Verde principal
AppTheme.secondaryTeal   // #14B8A6 - Teal secundario
AppTheme.accentOrange    // #FF6B00 - Naranja de acento
AppTheme.accentBlue      // #0066CC - Azul de acento
```

#### **Colores Semánticos**
```dart
AppTheme.success   // #2F9F85 - Verde éxito
AppTheme.warning   // #FFA726 - Naranja advertencia
AppTheme.error     // #D64550 - Rojo error
AppTheme.info      // #3B82F6 - Azul información
```

#### **Paleta Neutral**
```dart
AppTheme.surface         // #F2F5F9 - Fondo claro
AppTheme.textPrimary     // #102A43 - Texto principal
AppTheme.textSecondary   // #486581 - Texto secundario
AppTheme.textTertiary    // #829AB1 - Texto terciario
```

#### **Dark Mode Colors**
```dart
AppTheme.darkBackground      // #0F172A
AppTheme.darkSurface         // #1E293B
AppTheme.darkSurfaceVariant  // #334155
AppTheme.darkTextPrimary     // #F8FAFC
AppTheme.darkTextSecondary   // #CBD5E1
```

#### **Gradientes Predefinidos**
```dart
AppTheme.primaryGradient  // Verde → Teal
AppTheme.accentGradient   // Naranja degradado
AppTheme.heroGradient     // Verde → Teal → Azul
AppTheme.darkGradient     // Negro degradado
```

#### **Sistema de Espaciado**
```dart
AppTheme.spaceXs   // 4px
AppTheme.spaceSm   // 8px
AppTheme.spaceMd   // 12px
AppTheme.spaceLg   // 16px
AppTheme.spaceXl   // 24px
AppTheme.space2xl  // 32px
AppTheme.space3xl  // 48px
AppTheme.space4xl  // 64px
```

#### **Bordes Redondeados**
```dart
AppTheme.radiusSm   // 8px
AppTheme.radiusMd   // 12px
AppTheme.radiusLg   // 16px
AppTheme.radiusXl   // 20px
AppTheme.radius2xl  // 24px
AppTheme.radius3xl  // 32px
```

#### **Sombras Premium**
```dart
AppTheme.shadowSm    // Sombra pequeña
AppTheme.shadowMd    // Sombra media
AppTheme.shadowLg    // Sombra grande
AppTheme.shadowXl    // Sombra extra grande
AppTheme.shadowGlow  // Efecto glow
```

### **Tipografía**
Jerarquía completa con 13 estilos:
- **Display:** displayLarge, displayMedium, displaySmall
- **Headline:** headlineLarge, headlineMedium, headlineSmall
- **Title:** titleLarge, titleMedium, titleSmall
- **Body:** bodyLarge, bodyMedium, bodySmall
- **Label:** labelLarge, labelMedium, labelSmall

---

## 🎬 **ANIMACIONES** (`lib/widgets/animations.dart`)

### **Duraciones Estandarizadas**
```dart
AppAnimations.instant    // 100ms
AppAnimations.fast       // 200ms
AppAnimations.normal     // 300ms
AppAnimations.medium     // 400ms
AppAnimations.slow       // 600ms
AppAnimations.verySlow   // 1000ms
```

### **Curvas de Animación**
```dart
AppAnimations.spring         // Efecto rebote
AppAnimations.bounce         // Rebote pronunciado
AppAnimations.smooth         // Suave
AppAnimations.snappy         // Rápido y preciso
AppAnimations.gentle         // Suave y lento
AppAnimations.premiumEase    // Premium
AppAnimations.heroTransition // Para Hero widgets
```

### **Widgets de Animación**

#### **1. AnimatedScaleTap**
Botón con feedback táctil de escala.
```dart
AnimatedScaleTap(
  onTap: () => print('Tap!'),
  scaleDown: 0.95,  // Escala al presionar
  child: YourWidget(),
)
```

#### **2. PulseAnimation**
Animación de pulso continuo.
```dart
PulseAnimation(
  minScale: 1.0,
  maxScale: 1.08,
  child: Icon(Icons.notifications),
)
```

#### **3. FadeInSlideUp**
Entrada con fade y slide.
```dart
FadeInSlideUp(
  duration: AppAnimations.medium,
  delay: Duration(milliseconds: 200),
  offset: 30.0,
  child: YourWidget(),
)
```

#### **4. ShimmerEffect**
Efecto shimmer para loading.
```dart
ShimmerEffect(
  baseColor: Color(0xFFE0E0E0),
  highlightColor: Color(0xFFF5F5F5),
  child: YourPlaceholder(),
)
```

#### **5. StaggeredList**
Lista con animación escalonada.
```dart
StaggeredList(
  delay: Duration(milliseconds: 80),
  direction: Axis.vertical,
  children: [Widget1(), Widget2(), Widget3()],
)
```

#### **6. BounceScale**
Rebote al recibir notificación.
```dart
BounceScale(
  trigger: hasNewNotification,
  child: Badge(child: Icon(Icons.notifications)),
)
```

#### **7. AnimatedGradientContainer**
Contenedor con gradiente animado.
```dart
AnimatedGradientContainer(
  colors: [Colors.purple, Colors.blue],
  duration: Duration(seconds: 3),
  borderRadius: BorderRadius.circular(20),
  child: YourContent(),
)
```

---

## 🎮 **COMPONENTES PREMIUM** (`lib/widgets/premium_widgets.dart`)

### **1. StatCard**
Tarjeta de estadística animada.
```dart
StatCard(
  label: 'Partidos Ganados',
  value: '24',
  icon: Icons.emoji_events,
  color: AppTheme.success,
  onTap: () => navigateToStats(),
)
```

### **2. MatchCard**
Tarjeta de partido premium.
```dart
MatchCard(
  homeTeam: 'Barcelona FC',
  awayTeam: 'Real Madrid',
  homeScore: '2',
  awayScore: '1',
  status: 'LIVE',
  dateTime: DateTime.now(),
  statusColor: AppTheme.error,
  onTap: () => navigateToMatch(),
)
```

### **3. ActionButton**
Botón CTA premium con gradiente.
```dart
ActionButton(
  label: 'Crear Torneo',
  icon: Icons.add,
  onPressed: () => createTournament(),
  isLoading: isCreating,
  isFullWidth: true,
  backgroundColor: AppTheme.primaryGreen,
)
```

### **4. AchievementBadge**
Badge de logro con efecto glow.
```dart
AchievementBadge(
  label: 'MVP',
  icon: Icons.emoji_events,
  color: AppTheme.accentOrange,
  isUnlocked: true,
)
```

### **5. AnimatedProgressBar**
Barra de progreso animada.
```dart
AnimatedProgressBar(
  value: 0.75,  // 0.0 a 1.0
  label: 'Progreso de la temporada',
  color: AppTheme.primaryGreen,
  height: 8,
)
```

### **6. NotificationToast**
Toast premium in-app.
```dart
NotificationToast.show(
  context,
  title: '¡Gol!',
  message: 'Messi marca el primer gol',
  icon: Icons.sports_soccer,
  color: AppTheme.success,
  duration: Duration(seconds: 3),
);
```

### **7. QuickActionFab**
FAB contextual con label.
```dart
QuickActionFab(
  icon: Icons.add,
  label: 'Nuevo Partido',
  onPressed: () => createMatch(),
  backgroundColor: AppTheme.primaryGreen,
)
```

---

## 📦 **LOADING WIDGETS** (`lib/widgets/loading_widgets.dart`)

### **1. ShimmerBox**
Placeholder con shimmer.
```dart
ShimmerBox(
  width: 200,
  height: 100,
  borderRadius: BorderRadius.circular(16),
)
```

### **2. ShimmerMatchCard**
Placeholder para tarjetas de partido.
```dart
ShimmerMatchCard()
```

### **3. ShimmerListTile**
Placeholder para items de lista.
```dart
ListView.builder(
  itemCount: 5,
  itemBuilder: (context, index) => ShimmerListTile(),
)
```

### **4. SwipeToDismiss**
Swipe para editar/eliminar.
```dart
SwipeToDismiss(
  onDelete: () => deleteItem(),
  onEdit: () => editItem(),
  confirmDeleteMessage: '¿Eliminar este jugador?',
  child: PlayerListTile(...),
)
```

### **5. EmptyState**
Estado vacío elegante.
```dart
EmptyState(
  icon: Icons.sports_soccer,
  title: 'No hay partidos',
  description: 'Crea tu primer partido amistoso',
  actionLabel: 'Crear Partido',
  onAction: () => createMatch(),
)
```

### **6. PremiumRefreshIndicator**
Pull to refresh premium.
```dart
PremiumRefreshIndicator(
  onRefresh: () async => await loadData(),
  color: AppTheme.primaryGreen,
  child: YourListView(),
)
```

### **7. RatingStars**
Estrellas de calificación.
```dart
RatingStars(
  rating: 4.5,
  size: 20,
  color: AppTheme.accentOrange,
  interactive: true,
  onRatingChanged: (newRating) => updateRating(newRating),
)
```

### **8. MiniBarChart**
Gráfico de barras simple.
```dart
MiniBarChart(
  values: [10, 25, 15, 30, 20],
  labels: ['L', 'M', 'X', 'J', 'V'],
  height: 100,
  color: AppTheme.primaryGreen,
)
```

### **9. GradientContainer**
Contenedor con gradiente.
```dart
GradientContainer(
  colors: [AppTheme.primaryGreen, AppTheme.secondaryTeal],
  borderRadius: BorderRadius.circular(20),
  padding: EdgeInsets.all(24),
  child: YourContent(),
)
```

---

## 🌓 **DARK/LIGHT MODE** (`lib/providers/theme_provider.dart`)

### **ThemeProvider**
Gestor de tema con animaciones.

#### **Uso en main.dart:**
```dart
final themeProvider = ThemeProvider();
await themeProvider.init();

runApp(
  ChangeNotifierProvider.value(
    value: themeProvider,
    child: MyApp(),
  ),
);
```

#### **En MaterialApp:**
```dart
Consumer<ThemeProvider>(
  builder: (context, themeProvider, child) {
    return MaterialApp(
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeProvider.themeMode,
      // ...
    );
  },
)
```

### **ThemeSwitcher Widget**
Botón animado para cambiar tema.
```dart
AppBar(
  actions: [
    ThemeSwitcher(
      themeProvider: context.read<ThemeProvider>(),
    ),
  ],
)
```

### **Métodos del Provider:**
```dart
// Alternar tema
await themeProvider.toggleTheme();

// Establecer tema específico
await themeProvider.setThemeMode(ThemeMode.dark);

// Verificar modo actual
bool isDark = themeProvider.isDarkMode;
```

---

## 📊 **DASHBOARD WIDGETS** (`lib/widgets/dashboard_widgets.dart`)

### **1. DashboardHeader**
Cabecera hero con stats.
```dart
DashboardHeader(
  title: 'Bienvenido, Coach',
  subtitle: 'Resumen de tu temporada',
  stats: [
    DashboardStat(
      label: 'Partidos',
      value: '24',
      icon: Icons.sports_soccer,
    ),
    DashboardStat(
      label: 'Victorias',
      value: '18',
      icon: Icons.emoji_events,
    ),
  ],
  actionLabel: 'Ver Calendario',
  onActionTap: () => navigate(),
)
```

### **2. PerformanceChart**
Gráfico de rendimiento.
```dart
PerformanceChart(
  title: 'Goles por Mes',
  type: ChartType.bar,
  color: AppTheme.primaryGreen,
  data: [
    ChartData(label: 'Ene', value: 12),
    ChartData(label: 'Feb', value: 18),
    ChartData(label: 'Mar', value: 15),
  ],
)
```

### **3. RankingList**
Lista de ranking/leaderboard.
```dart
RankingList(
  title: 'Top Goleadores',
  items: [
    RankingItem(
      name: 'Lionel Messi',
      subtitle: 'Delantero',
      value: '24',
      onTap: () => viewPlayer(),
    ),
    // ... más items
  ],
)
```

### **4. QuickStatsGrid**
Grid de estadísticas rápidas.
```dart
QuickStatsGrid(
  stats: [
    QuickStat(
      label: 'Goles',
      value: '48',
      icon: Icons.sports_soccer,
      color: AppTheme.success,
      onTap: () => viewGoals(),
    ),
    QuickStat(
      label: 'Asistencias',
      value: '32',
      icon: Icons.call_split,
      color: AppTheme.info,
    ),
    // ... más stats
  ],
)
```

---

## ⚽ **TIMELINE WIDGETS** (`lib/widgets/timeline_widgets.dart`)

### **1. MatchTimeline**
Timeline interactivo de eventos de partido.
```dart
MatchTimeline(
  isLive: true,
  events: [
    TimelineEvent(
      minute: 12,
      type: EventType.goal,
      playerName: 'Lionel Messi',
      teamName: 'Barcelona FC',
      isHomeTeam: true,
      description: 'Asistencia de Pedri',
    ),
    TimelineEvent(
      minute: 23,
      type: EventType.yellowCard,
      playerName: 'Sergio Ramos',
      teamName: 'Real Madrid',
      isHomeTeam: false,
    ),
    // ... más eventos
  ],
)
```

### **Tipos de Eventos:**
```dart
EventType.goal          // Gol
EventType.yellowCard    // Tarjeta amarilla
EventType.redCard       // Tarjeta roja
EventType.substitution  // Cambio
EventType.penalty       // Penalti
EventType.ownGoal       // Autogol
EventType.varCheck      // Revisión VAR
```

### **2. MatchStatsComparison**
Comparación de stats entre equipos.
```dart
MatchStatsComparison(
  homeTeam: 'Barcelona FC',
  awayTeam: 'Real Madrid',
  stats: [
    MatchStat(
      label: 'Posesión',
      homeValue: 65,
      awayValue: 35,
    ),
    MatchStat(
      label: 'Tiros a gol',
      homeValue: 12,
      awayValue: 8,
    ),
    MatchStat(
      label: 'Corners',
      homeValue: 7,
      awayValue: 4,
    ),
  ],
)
```

---

## 🎯 **GUÍA DE USO**

### **Setup Inicial**

1. **Importar el theme en main.dart:**
```dart
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
```

2. **Inicializar ThemeProvider:**
```dart
final themeProvider = ThemeProvider();
await themeProvider.init();
```

3. **Wrap con Provider:**
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider.value(value: themeProvider),
  ],
  child: MyApp(),
)
```

4. **Aplicar temas:**
```dart
MaterialApp(
  theme: AppTheme.lightTheme(),
  darkTheme: AppTheme.darkTheme(),
  themeMode: themeProvider.themeMode,
)
```

### **Uso de Componentes**

#### **En Screens:**
```dart
import 'package:mobile_flutter/widgets/premium_widgets.dart';
import 'package:mobile_flutter/widgets/animations.dart';
import 'package:mobile_flutter/theme/app_theme.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeInSlideUp(
        child: Column(
          children: [
            StatCard(
              label: 'Total Partidos',
              value: '24',
              icon: Icons.sports_soccer,
              color: AppTheme.primaryGreen,
            ),
            ActionButton(
              label: 'Crear Nuevo',
              icon: Icons.add,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 📝 **EJEMPLOS COMPLETOS**

### **Ejemplo 1: Dashboard Screen**
```dart
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppTheme.spaceLg),
          child: Column(
            children: [
              DashboardHeader(
                title: 'Temporada 2024/25',
                subtitle: 'Resumen de actividad',
                stats: [
                  DashboardStat(label: 'Partidos', value: '32', icon: Icons.sports),
                  DashboardStat(label: 'Goles', value: '48', icon: Icons.sports_soccer),
                ],
              ),
              SizedBox(height: AppTheme.spaceXl),
              
              QuickStatsGrid(
                stats: [
                  QuickStat(label: 'Victorias', value: '24', icon: Icons.emoji_events, color: AppTheme.success),
                  QuickStat(label: 'Empates', value: '5', icon: Icons.handshake, color: AppTheme.warning),
                  QuickStat(label: 'Derrotas', value: '3', icon: Icons.close, color: AppTheme.error),
                  QuickStat(label: 'Jugadores', value: '18', icon: Icons.people, color: AppTheme.info),
                ],
              ),
              SizedBox(height: AppTheme.spaceXl),
              
              PerformanceChart(
                title: 'Goles por Mes',
                type: ChartType.bar,
                data: [
                  ChartData(label: 'Sep', value: 12),
                  ChartData(label: 'Oct', value: 18),
                  ChartData(label: 'Nov', value: 15),
                  ChartData(label: 'Dic', value: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### **Ejemplo 2: Match Detail Screen**
```dart
class MatchDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppTheme.spaceLg),
          child: Column(
            children: [
              MatchCard(
                homeTeam: 'Barcelona FC',
                awayTeam: 'Real Madrid',
                homeScore: '3',
                awayScore: '2',
                status: 'FINALIZADO',
                dateTime: DateTime.now(),
              ),
              SizedBox(height: AppTheme.spaceXl),
              
              MatchStatsComparison(
                homeTeam: 'Barcelona',
                awayTeam: 'Madrid',
                stats: [
                  MatchStat(label: 'Posesión', homeValue: 65, awayValue: 35),
                  MatchStat(label: 'Tiros', homeValue: 15, awayValue: 10),
                ],
              ),
              SizedBox(height: AppTheme.spaceXl),
              
              MatchTimeline(
                events: [
                  TimelineEvent(
                    minute: 12,
                    type: EventType.goal,
                    playerName: 'Messi',
                    teamName: 'Barcelona',
                    isHomeTeam: true,
                  ),
                  // ... más eventos
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## ✅ **CHECKLIST DE IMPLEMENTACIÓN**

- [x] Sistema de design tokens (AppTheme)
- [x] Dark/Light mode con animaciones
- [x] Componentes premium (10+ widgets)
- [x] Sistema de animaciones (8+ tipos)
- [x] Loading states con shimmer
- [x] Swipe-to-dismiss actions
- [x] Dashboard widgets avanzados
- [x] Timeline interactivo
- [x] Gráficos y stats comparison
- [x] Gamificación (badges, rankings)
- [x] Microinteracciones
- [x] Hero transitions preparadas
- [x] Notificaciones toast premium

---

## 🚀 **PRÓXIMOS PASOS**

1. **Actualizar screens existentes** con nuevos componentes
2. **Implementar Hero animations** entre pantallas
3. **Añadir más gráficos** (fl_chart si es necesario)
4. **Lottie animations** para celebrations
5. **Haptic feedback** en interacciones
6. **Sonidos** para eventos importantes

---

## 📚 **REFERENCIAS**

- **Material 3 Design:** https://m3.material.io/
- **Flutter Animations:** https://docs.flutter.dev/development/ui/animations
- **OneFootball App:** Inspiración UI/UX
- **FIFA App:** Sistema de colores y stats
- **NBA App:** Timeline y live updates

---

**¡Sistema UI/UX Premium Completado! 🎉**

Todos los componentes están listos para usar. Simplemente importa y aplica donde necesites.
