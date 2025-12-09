import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import '../widgets/premium_widgets.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/loading_widgets.dart';
import '../widgets/form_widgets.dart';
import '../widgets/calendar_view.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';

/// 🎨 DEMO SCREEN - Showcase de todos los componentes UI/UX implementados
/// 
/// Esta pantalla demuestra todos los componentes premium creados
/// organizados en categorías para fácil navegación y testing.
class UIShowcaseScreen extends StatefulWidget {
  const UIShowcaseScreen({super.key});

  @override
  State<UIShowcaseScreen> createState() => _UIShowcaseScreenState();
}

class _UIShowcaseScreenState extends State<UIShowcaseScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎨 UI/UX Showcase'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode_outlined,
                ),
                onPressed: () => themeProvider.toggleTheme(),
                tooltip: 'Toggle Dark Mode',
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Widgets', icon: Icon(Icons.widgets)),
            Tab(text: 'Forms', icon: Icon(Icons.edit)),
            Tab(text: 'Dashboard', icon: Icon(Icons.dashboard)),
            Tab(text: 'Calendar', icon: Icon(Icons.calendar_month)),
            Tab(text: 'Loading', icon: Icon(Icons.hourglass_empty)),
            Tab(text: 'Animations', icon: Icon(Icons.animation)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWidgetsTab(),
          _buildFormsTab(),
          _buildDashboardTab(),
          _buildCalendarTab(),
          _buildLoadingTab(),
          _buildAnimationsTab(),
        ],
      ),
    );
  }

  // 📱 TAB 1: PREMIUM WIDGETS
  Widget _buildWidgetsTab() {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      children: [
        _SectionTitle(title: 'StatCard - Métricas con icono'),
        const SizedBox(height: AppTheme.spaceMd),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.sports_soccer,
                label: 'Partidos',
                value: '24',
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: StatCard(
                icon: Icons.emoji_events,
                label: 'Victorias',
                value: '18',
                color: AppTheme.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceXl),

        _SectionTitle(title: 'MatchCard - Información de partidos'),
        const SizedBox(height: AppTheme.spaceMd),
        MatchCard(
          homeTeam: 'FC Barcelona',
          awayTeam: 'Real Madrid',
          homeScore: '2',
          awayScore: '1',
          status: 'Finalizado',
          dateTime: DateTime.now().subtract(const Duration(days: 1)),
          statusColor: AppTheme.success,
          onTap: () {
            NotificationToast.show(
              context,
              title: 'Match Card',
              message: '¡Match card tapped!',
              icon: Icons.sports_soccer,
            );
          },
        ),
        const SizedBox(height: AppTheme.spaceXl),

        _SectionTitle(title: 'ActionButton - Botones CTA'),
        const SizedBox(height: AppTheme.spaceMd),
        ActionButton(
          label: 'Guardar Cambios',
          icon: Icons.save,
          onPressed: () {
            NotificationToast.show(
              context,
              title: 'Éxito',
              message: 'Cambios guardados correctamente',
              icon: Icons.check_circle,
            );
          },
          isFullWidth: true,
        ),
        const SizedBox(height: AppTheme.spaceXl),

        _SectionTitle(title: 'AchievementBadge - Logros'),
        const SizedBox(height: AppTheme.spaceMd),
        Row(
          children: [
            Expanded(
              child: AchievementBadge(
                label: 'Primer Partido',
                icon: Icons.sports_soccer,
                color: AppTheme.primaryGreen,
                isUnlocked: true,
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: AchievementBadge(
                label: 'Campeón',
                icon: Icons.emoji_events,
                color: AppTheme.accentOrange,
                isUnlocked: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceXl),

        _SectionTitle(title: 'AnimatedProgressBar'),
        const SizedBox(height: AppTheme.spaceMd),
        AnimatedProgressBar(
          value: 0.75,
          label: 'Progreso del Torneo',
          color: AppTheme.primaryGreen,
        ),
        const SizedBox(height: AppTheme.spaceMd),
        AnimatedProgressBar(
          value: 0.45,
          label: 'Victorias',
          color: AppTheme.accentOrange,
        ),
        const SizedBox(height: AppTheme.space2xl),
      ],
    );
  }

  // 📝 TAB 2: FORM COMPONENTS
  Widget _buildFormsTab() {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      children: [
        _SectionTitle(title: 'PremiumTextField'),
        const SizedBox(height: AppTheme.spaceMd),
        PremiumTextField(
          label: 'Nombre completo',
          hint: 'Ej: Lionel Messi',
          prefixIcon: Icons.person,
        ),
        const SizedBox(height: AppTheme.spaceXl),

        _SectionTitle(title: 'PremiumDropdown'),
        const SizedBox(height: AppTheme.spaceMd),
        PremiumDropdown<String>(
          label: 'Posición',
          value: 'Delantero',
          items: const [
            DropdownMenuItem(value: 'Portero', child: Text('Portero')),
            DropdownMenuItem(value: 'Defensa', child: Text('Defensa')),
            DropdownMenuItem(value: 'Centrocampista', child: Text('Centrocampista')),
            DropdownMenuItem(value: 'Delantero', child: Text('Delantero')),
          ],
          onChanged: (value) {},
          prefixIcon: Icons.sports_soccer,
        ),
        const SizedBox(height: AppTheme.spaceXl),

        _SectionTitle(title: 'PremiumSwitch'),
        const SizedBox(height: AppTheme.spaceMd),
        PremiumSwitch(
          label: 'Notificaciones Push',
          subtitle: 'Recibe alertas de partidos y eventos',
          value: true,
          onChanged: (value) {},
          icon: Icons.notifications_active,
        ),
        const SizedBox(height: AppTheme.spaceXl),

        _SectionTitle(title: 'PremiumChipSelector'),
        const SizedBox(height: AppTheme.spaceMd),
        PremiumChipSelector<String>(
          label: 'Tipo de torneo',
          options: [
            ChipOption(
              label: 'Liga',
              value: 'Liga',
              icon: Icons.format_list_numbered,
              color: AppTheme.primaryGreen,
            ),
            ChipOption(
              label: 'Copa',
              value: 'Copa',
              icon: Icons.emoji_events,
              color: AppTheme.accentOrange,
            ),
          ],
          selected: 'Liga',
          onSelected: (value) {},
        ),
        const SizedBox(height: AppTheme.spaceXl),

        _SectionTitle(title: 'PremiumDatePicker & TimePicker'),
        const SizedBox(height: AppTheme.spaceMd),
        PremiumDatePicker(
          label: 'Fecha del partido',
          selectedDate: DateTime.now(),
          onDateSelected: (date) {},
          icon: Icons.calendar_today,
        ),
        const SizedBox(height: AppTheme.spaceMd),
        PremiumTimePicker(
          label: 'Hora del partido',
          selectedTime: const TimeOfDay(hour: 18, minute: 0),
          onTimeSelected: (time) {},
          icon: Icons.access_time,
        ),
        const SizedBox(height: AppTheme.space2xl),
      ],
    );
  }

  // 📊 TAB 3: DASHBOARD COMPONENTS
  Widget _buildDashboardTab() {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      children: [
        _SectionTitle(title: 'QuickStatsGrid'),
        const SizedBox(height: AppTheme.spaceMd),
        QuickStatsGrid(
          stats: [
            QuickStat(
              label: 'Partidos',
              value: '24',
              icon: Icons.sports_soccer,
              color: AppTheme.primaryGreen,
            ),
            QuickStat(
              label: 'Victorias',
              value: '18',
              icon: Icons.emoji_events,
              color: AppTheme.success,
            ),
            QuickStat(
              label: 'Goles',
              value: '48',
              icon: Icons.sports,
              color: AppTheme.accentOrange,
            ),
            QuickStat(
              label: 'Jugadores',
              value: '22',
              icon: Icons.people,
              color: AppTheme.info,
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceXl),

        _SectionTitle(title: 'PerformanceChart'),
        const SizedBox(height: AppTheme.spaceMd),
        PerformanceChart(
          title: 'Goles por jornada',
          data: [
            ChartData(label: 'J1', value: 8),
            ChartData(label: 'J2', value: 12),
            ChartData(label: 'J3', value: 6),
            ChartData(label: 'J4', value: 10),
            ChartData(label: 'J5', value: 14),
          ],
          type: ChartType.bar,
        ),
        const SizedBox(height: AppTheme.spaceXl),

        _SectionTitle(title: 'RankingList'),
        const SizedBox(height: AppTheme.spaceMd),
        RankingList(
          title: 'Clasificación',
          items: [
            RankingItem(
              name: 'Barcelona',
              value: '45 pts',
              subtitle: 'PJ: 15 | V: 14 | E: 1 | D: 0',
            ),
            RankingItem(
              name: 'Real Madrid',
              value: '38 pts',
              subtitle: 'PJ: 15 | V: 12 | E: 2 | D: 1',
            ),
            RankingItem(
              name: 'Atlético',
              value: '35 pts',
              subtitle: 'PJ: 15 | V: 11 | E: 2 | D: 2',
            ),
            RankingItem(
              name: 'Valencia',
              value: '28 pts',
              subtitle: 'PJ: 15 | V: 8 | E: 4 | D: 3',
            ),
          ],
        ),
        const SizedBox(height: AppTheme.space2xl),
      ],
    );
  }

  // 🗓️ TAB 4: CALENDAR VIEW
  Widget _buildCalendarTab() {
    final events = [
      CalendarEvent(
        id: '1',
        title: 'Partido vs Real Madrid',
        date: DateTime.now().add(const Duration(days: 2)),
        description: 'Liga Juvenil - Jornada 5',
        color: AppTheme.primaryGreen,
        icon: Icons.sports_soccer,
      ),
      CalendarEvent(
        id: '2',
        title: 'Entrenamiento',
        date: DateTime.now().add(const Duration(days: 3)),
        description: 'Sesión táctica - Campo A',
        color: AppTheme.info,
        icon: Icons.fitness_center,
      ),
      CalendarEvent(
        id: '3',
        title: 'Reunión técnica',
        date: DateTime.now().add(const Duration(days: 5)),
        description: 'Análisis de rivales',
        color: AppTheme.accentOrange,
        icon: Icons.meeting_room,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      children: [
        _SectionTitle(title: 'Calendar View'),
        const SizedBox(height: AppTheme.spaceMd),
        CalendarWithEvents(
          events: events,
          onEventTap: (event) {
            NotificationToast.show(
              context,
              title: 'Evento',
              message: event.title,
              icon: event.icon ?? Icons.event,
            );
          },
        ),
        const SizedBox(height: AppTheme.space2xl),
      ],
    );
  }

  // ⏳ TAB 5: LOADING STATES
  Widget _buildLoadingTab() {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      children: [
        _SectionTitle(title: 'ShimmerMatchCard'),
        const SizedBox(height: AppTheme.spaceMd),
        const ShimmerMatchCard(),
        const SizedBox(height: AppTheme.spaceXl),

        _SectionTitle(title: 'EmptyState'),
        const SizedBox(height: AppTheme.spaceMd),
        EmptyState(
          icon: Icons.inbox_outlined,
          title: 'Sin partidos programados',
          description: 'Crea tu primer partido para comenzar',
          actionLabel: 'Crear Partido',
          onAction: () {
            NotificationToast.show(
              context,
              title: 'Navegación',
              message: 'Navegando a crear partido...',
              icon: Icons.add_circle,
            );
          },
        ),
        const SizedBox(height: AppTheme.spaceXl),

        _SectionTitle(title: 'RatingStars'),
        const SizedBox(height: AppTheme.spaceMd),
        Center(
          child: RatingStars(
            rating: 4.5,
            size: 32,
          ),
        ),
        const SizedBox(height: AppTheme.space2xl),
      ],
    );
  }

  // ✨ TAB 6: ANIMATIONS
  Widget _buildAnimationsTab() {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      children: [
        _SectionTitle(title: 'FadeInSlideUp'),
        const SizedBox(height: AppTheme.spaceMd),
        FadeInSlideUp(
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: const Text(
              'Este contenido apareció con FadeInSlideUp',
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spaceXl),

        _SectionTitle(title: 'PulseAnimation'),
        const SizedBox(height: AppTheme.spaceMd),
        Center(
          child: PulseAnimation(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.heroGradient,
              ),
              child: const Icon(
                Icons.notifications_active,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spaceXl),

        _SectionTitle(title: 'AnimatedScaleTap'),
        const SizedBox(height: AppTheme.spaceMd),
        Center(
          child: AnimatedScaleTap(
            onTap: () {
              NotificationToast.show(
                context,
                title: 'Animación',
                message: '¡Tap con animación de escala!',
                icon: Icons.touch_app,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceXl,
                vertical: AppTheme.spaceLg,
              ),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                boxShadow: AppTheme.shadowMd,
              ),
              child: const Text(
                'Toca aquí para ver la animación',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spaceXl),

        _SectionTitle(title: 'StaggeredList'),
        const SizedBox(height: AppTheme.spaceMd),
        StaggeredList(
          delay: Duration.zero,
          children: List.generate(
            5,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                boxShadow: AppTheme.shadowSm,
              ),
              child: Text(
                'Item ${index + 1} - Animado secuencialmente',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.space2xl),
      ],
    );
  }
}

// Helper Widget para títulos de sección
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          const Icon(Icons.chevron_right, color: AppTheme.primaryGreen),
          const SizedBox(width: AppTheme.spaceSm),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}
