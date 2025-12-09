import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'match_detail_screen.dart';
import 'upcoming_feature_screen.dart';
import '../widgets/premium_empty_state.dart';
import '../services/permission_service.dart';
import 'event_creation_screen.dart';
import '../services/auth_service.dart';
import '../services/agenda_service.dart';
import '../models/auth.dart';
import '../widgets/notification_indicator.dart';
import '../widgets/animations.dart';
import '../widgets/premium_widgets.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/loading_widgets.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';
import '../utils/event_style.dart';
import '../utils/time_format.dart';
import '../utils/time_range.dart';
import 'team_screen.dart';
import 'tournament_screen.dart';
import 'profile_screen.dart';
import 'friendly_match_screen.dart';
import '../widgets/event_details_sheet.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabController;

  List<_TabItem> get _tabs {
    final role = AuthService.instance.currentUser?.role.displayName ?? 'coach';
    final visible = AuthService.instance.getVisibleTabsForRole(role);
    final items = <_TabItem>[];

    if (visible.contains('home')) {
      items.add(_TabItem(
        label: 'Inicio',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        content: _PremiumHomeDashboard(onAgendaTap: _handleAgendaTap),
      ));
    }
    if (visible.contains('team')) {
      items.add(const _TabItem(
        label: 'Equipos',
        icon: Icons.groups_outlined,
        selectedIcon: Icons.groups,
        content: TeamScreen(),
      ));
    }
    if (visible.contains('friendlies')) {
      items.add(const _TabItem(
        label: 'Amistosos',
        icon: Icons.handshake_outlined,
        selectedIcon: Icons.handshake,
        content: FriendlyMatchScreen(),
      ));
    }
    if (visible.contains('tournaments')) {
      items.add(const _TabItem(
        label: 'Torneos',
        icon: Icons.emoji_events_outlined,
        selectedIcon: Icons.emoji_events,
        content: TournamentScreen(),
      ));
    }
    if (visible.contains('profile')) {
      items.add(const _TabItem(
        label: 'Perfil',
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
        content: ProfileScreen(),
      ));
    }
    return items;
  }

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _handleAgendaTap(AgendaItem item) {
    if (item.matchId != null) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              MatchDetailScreen(matchId: item.matchId!),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
      return;
    }

    // No redirigimos a otras pestañas desde Home; Home actúa como resumen.
    // Si el item es un partido, ya se abre el detalle arriba.
    return;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs;
    if (_currentIndex >= tabs.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _currentIndex = 0);
      });
    }

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: FadeInSlideUp(
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                ),
                child: const Icon(Icons.sports_soccer, color: Colors.white, size: 18),
              ),
              const SizedBox(width: AppTheme.spaceMd),
              const Text('Football Coaches'),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Theme switcher
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode
                      ? Icons.light_mode
                      : Icons.dark_mode_outlined,
                ),
                onPressed: () => themeProvider.toggleTheme(),
                tooltip: 'Cambiar tema',
              );
            },
          ),
          
          // Notifications
          NotificationIndicator(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => const NotificationBottomSheet(),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radius2xl),
                  ),
                ),
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
              );
            },
          ),
          
          // Logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar sesión'),
                  content: const Text('¿Estás seguro que deseas salir?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.error,
                      ),
                      child: const Text('Salir'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await AuthService.instance.logout();
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            tooltip: 'Cerrar sesión',
          ),
          const SizedBox(width: AppTheme.spaceSm),
        ],
      ),
      // Home should only render the premium dashboard content; no internal tabs.
      body: _PremiumHomeDashboard(onAgendaTap: _handleAgendaTap),
      // bottomNavigationBar is provided by MainApp; avoid duplicating here.
    );
  }
}

/// 🎯 **PREMIUM HOME DASHBOARD**
class _PremiumHomeDashboard extends StatefulWidget {
  final void Function(AgendaItem) onAgendaTap;

  const _PremiumHomeDashboard({required this.onAgendaTap});

  @override
  State<_PremiumHomeDashboard> createState() => _PremiumHomeDashboardState();
}

class _PremiumHomeDashboardState extends State<_PremiumHomeDashboard> {
  late Future<List<AgendaItem>> _futureAgenda;
  // Removed unused field to satisfy analyzer

  @override
  void initState() {
    super.initState();
    _futureAgenda = AgendaService.instance.getUpcoming();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    return PremiumRefreshIndicator(
      onRefresh: _refreshAgenda,
      color: AppTheme.primaryGreen,
      child: ListView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.fromLTRB(
          AppTheme.spaceLg,
          AppTheme.spaceLg,
          AppTheme.spaceLg,
          AppTheme.spaceXl * 3,
        ),
        children: [
          // Header Premium removed to avoid duplicate welcome; gradient header below
          const SizedBox(height: AppTheme.spaceSm),

          // Summary chips removed to avoid duplication with bottom navigation

          // Agenda-driven Quick Overview + Upcoming
          FutureBuilder<List<AgendaItem>>(
            future: _futureAgenda,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 88,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceMd),
                    const ShimmerMatchCard(),
                  ],
                );
              }

              if (snapshot.hasError) {
                return EmptyState(
                  icon: Icons.error_outline,
                  title: 'Error al cargar',
                  description: 'No se pudo cargar la agenda',
                  actionLabel: 'Reintentar',
                  onAction: _refreshAgenda,
                );
              }

              final items = snapshot.data ?? [];
              final nextMatch = items.firstWhere(
                (it) => it.matchId != null || it.title.toLowerCase().contains('vs'),
                orElse: () => AgendaItem(
                  title: 'Sin rival',
                  subtitle: '—',
                  icon: Icons.sports_soccer,
                  when: DateTime.now(),
                ),
              );
              final weekEvents = items.where((it) => it.when.isAfter(DateTime.now()) && it.when.isBefore(DateTime.now().add(const Duration(days: 7)))).length;
              final unreadChats = 0; // TODO: conectar a servicio de chat cuando esté listo

              return Column(
                children: [
                  // Premium gradient header with welcome text
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg, vertical: AppTheme.spaceLg),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryGreen,
                          AppTheme.secondaryTeal.withValues(alpha: 0.85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    ),
                    child: Row(
                      children: [
                        // User avatar
                        Builder(builder: (context) {
                          final user = AuthService.instance.currentUser;
                          final avatar = user?.avatarUrl;
                          return CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            backgroundImage: avatar != null && avatar.isNotEmpty ? NetworkImage(avatar) : null,
                            child: (avatar == null || avatar.isEmpty)
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          );
                        }),
                        const SizedBox(width: AppTheme.spaceSm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bienvenido, ${AuthService.instance.currentUser?.fullName.isNotEmpty == true ? AuthService.instance.currentUser!.fullName : 'Entrenador'}',
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              // Simple summary: role and last login
                              Text(
                                '${AuthService.instance.currentUser?.role.displayName ?? 'Coach'} · Último acceso: ' +
                                    (AuthService.instance.currentUser?.lastLoginAt != null
                                        ? _formatDate(AuthService.instance.currentUser!.lastLoginAt!)
                                        : '—'),
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            NotificationIndicator(),
                            SizedBox(width: AppTheme.spaceSm),
                            _IconBadge(icon: Icons.chat_bubble_outline, count: 0),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceLg),
                  // Quick Overview KPIs (explicit, no hidden required params)
                  FadeInSlideUp(
                    delay: const Duration(milliseconds: 100),
                    child: SectionCard(
                      title: 'Resumen rápido',
                      icon: Icons.dashboard,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _KpiCard(
                                title: 'Próximo partido',
                                subtitle: nextMatch.title,
                                trailing: _formatDate(nextMatch.when),
                                icon: Icons.sports_soccer,
                                color: AppTheme.info,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spaceMd),
                            Expanded(
                              child: _KpiCard(
                                title: 'Eventos de la semana',
                                subtitle: 'Eventos: $weekEvents',
                                trailing: '→',
                                icon: Icons.event,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spaceMd),
                            Expanded(
                              child: _KpiCard(
                                title: 'Chats sin leer',
                                subtitle: '$unreadChats',
                                trailing: 'Ver',
                                icon: Icons.chat_bubble_outline,
                                color: AppTheme.accentOrange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceLg),
                  // Quick actions row
                  FadeInSlideUp(
                    delay: const Duration(milliseconds: 120),
                    child: SectionCard(
                      title: 'Acciones rápidas',
                      icon: Icons.flash_on,
                      children: [
                        Wrap(
                          spacing: AppTheme.spaceSm,
                          runSpacing: AppTheme.spaceSm,
                          children: [
                            ActionButton(label: 'Crear amistoso', icon: Icons.handshake, height: 48, onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FriendlyMatchScreen()));
                            }),
                            ActionButton(label: 'Nuevo torneo', icon: Icons.emoji_events, height: 48, onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TournamentScreen()));
                            }),
                            ActionButton(label: 'Añadir jugador', icon: Icons.person_add, height: 48, onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TeamScreen()));
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXl),

                  // Upcoming matches section (from agenda) — show only matches
                  FadeInSlideUp(
                    delay: const Duration(milliseconds: 200),
                    child: SectionCard(
                      title: 'Próximos partidos',
                      icon: Icons.sports_soccer,
                      children: items
                          .where((it) => it.matchId != null || it.title.toLowerCase().contains('vs'))
                          .take(3)
                          .map((it) => Padding(
                                padding: const EdgeInsets.only(bottom: AppTheme.spaceSm),
                                child: AnimatedScaleTap(
                                  onTap: () => _showAgendaItemModal(it),
                                  child: _AgendaItemCard(
                                    item: it,
                                    onTap: () => _showAgendaItemModal(it),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXl),

                  // Next 7 days scroller
                  FadeInSlideUp(
                    delay: const Duration(milliseconds: 240),
                    child: _NextSevenDays(items: items),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: AppTheme.spaceXl),

          // Agenda Section (full) — only non-matches to avoid duplicates
          ValueListenableBuilder<List<AgendaItem>>(
            valueListenable: AgendaService.instance.agendaNotifier,
            builder: (context, items, _) {
              if (items.isEmpty) {
                return Column(
                  children: const [
                    ShimmerMatchCard(),
                    SizedBox(height: AppTheme.spaceMd),
                    ShimmerMatchCard(),
                  ],
                );
              }
              final nonMatches = items.where((it) {
                final t = it.title.toLowerCase();
                return !(it.matchId != null || t.contains('vs'));
              }).toList();
              return _buildAgendaSection(nonMatches);
            },
          ),

          const SizedBox(height: AppTheme.spaceXl),

          // Friendlies highlight removed to avoid duplication with tabs

          // Team snapshot removed to avoid duplication with tabs

          const SizedBox(height: AppTheme.spaceXl),

          // Recent Activity
          FadeInSlideUp(
            delay: const Duration(milliseconds: 360),
            child: const _RecentActivity(),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt;
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '$day/$month · $hour:$minute';
  }

  // ignore: unused_element
  Widget _buildUpcomingSection(List<AgendaItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Próximos Partidos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            TextButton(
              onPressed: _showAgendaModal,
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),
        
        ...items.take(3).map((item) {
          final isMatch = item.matchId != null || item.title.toLowerCase().contains('vs');
          if (!isMatch) return const SizedBox.shrink();
          return FadeInSlideUp(
            delay: const Duration(milliseconds: 180),
            child: AnimatedScaleTap(
              onTap: () => _showAgendaItemModal(item),
              child: MatchCard(
                homeTeam: item.title.split('vs').first.trim(),
                awayTeam: item.title.contains('vs') ? item.title.split('vs').last.trim() : item.subtitle ?? 'Rival',
                homeScore: null,
                awayScore: null,
                status: 'Programado',
                dateTime: item.when,
                statusColor: AppTheme.info,
                onTap: () => _showAgendaItemModal(item),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAgendaSection(List<AgendaItem> items) {
    if (items.isEmpty) {
      return FadeInSlideUp(
        delay: const Duration(milliseconds: 300),
        child: PremiumEmptyState(
          headline: 'Sin eventos por ahora',
          subtext: 'Aquí verás tus próximos partidos, entrenamientos y actividades',
          onCreate: PermissionService.instance.canRecordMatch()
              ? () async {
                  final created = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => const EventCreationScreen(),
                    ),
                  );
                  if (created == true && mounted) {
                    setState(() {});
                  }
                }
              : null,
        ),
      );
    }

    // Filter only administrative/training/meeting/calendar-like items (non-matches already applied upstream)
    final filtered = items.where((item) {
      final t = item.title.toLowerCase();
      return t.contains('entrenamiento') || t.contains('reunión') || t.contains('meeting') || t.contains('club') || t.contains('admin') || t.contains('calendario') || t.contains('anuncio') || t.contains('announcement');
    }).toList();
    final unseenAnnouncements = NotificationService.instance.unseenAnnouncementsCount;
    final grouped = _groupAgendaByDay(filtered);
    final dayKeys = grouped.keys.toList()..sort();
    
    return FadeInSlideUp(
      delay: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mi Agenda',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Row(
                children: [
                  if (unseenAnnouncements > 0)
                    Container(
                      margin: const EdgeInsets.only(right: AppTheme.spaceSm),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spaceMd,
                        vertical: AppTheme.spaceSm,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.campaign, size: 16, color: AppTheme.warning),
                          const SizedBox(width: 6),
                          Text(
                            '$unseenAnnouncements anuncios',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppTheme.warning,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spaceMd,
                      vertical: AppTheme.spaceSm,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Text(
                      '${items.length} eventos',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceLg),
          
          ...filtered.take(3).map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
              child: AnimatedScaleTap(
                onTap: () {
                  _showAgendaItemModal(item);
                  final t = item.title.toLowerCase();
                  if (t.contains('anuncio') || t.contains('announcement')) {
                    NotificationService.instance.markEventSeen(item.matchId ?? item.id ?? item.title);
                  }
                },
                child: _AgendaItemCard(
                  item: item,
                  onTap: () {
                    _showAgendaItemModal(item);
                    final t = item.title.toLowerCase();
                    if (t.contains('anuncio') || t.contains('announcement')) {
                      NotificationService.instance.markEventSeen(item.matchId ?? item.id ?? item.title);
                    }
                  },
                ),
              ),
            );
          }),

          if (filtered.length > 3)
            Center(
              child: TextButton(
                onPressed: _showAgendaModal,
                child: const Text('Ver todos los eventos'),
              ),
            ),
        ],
      ),
    );
  }

  // ignore: unused_element
  List<QuickStat> _getQuickStats(String role) {
    // Mock data - replace with real data
    return [
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
    ];
  }

  Map<DateTime, List<AgendaItem>> _groupAgendaByDay(List<AgendaItem> items) {
    final map = <DateTime, List<AgendaItem>>{};
    for (final item in items) {
      final day = DateTime(item.when.year, item.when.month, item.when.day);
      map.putIfAbsent(day, () => []).add(item);
    }
    return map;
  }

  Future<void> _refreshAgenda() async {
    final updated = AgendaService.instance.getUpcoming();
    setState(() {
      _futureAgenda = updated;
    });
    await updated;
  }

  // ignore: unused_element
  List<QuickStat> _computeStatsFromAgenda(List<AgendaItem> items) {
    int matches = 0;
    int trainings = 0;
    int meetings = 0;
    for (final it in items) {
      final t = it.title.toLowerCase();
      if (it.matchId != null || t.contains('vs')) matches++;
      if (t.contains('entrenamiento')) trainings++;
      if (t.contains('reunión') || t.contains('meeting')) meetings++;
    }
    return [
      QuickStat(label: 'Eventos', value: '${items.length}', icon: Icons.event, color: AppTheme.info),
      QuickStat(label: 'Partidos', value: '$matches', icon: Icons.sports_soccer, color: AppTheme.primaryGreen),
      QuickStat(label: 'Entrenos', value: '$trainings', icon: Icons.fitness_center, color: AppTheme.accentOrange),
      QuickStat(label: 'Reuniones', value: '$meetings', icon: Icons.meeting_room, color: AppTheme.warning),
    ];
  }

  void _showAgendaModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radius2xl)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, controller) {
            return FutureBuilder<List<AgendaItem>>(
              future: _futureAgenda,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(AppTheme.spaceLg),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        ),
                      ),
                    ),
                  );
                }
                final items = snapshot.data!;
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radius2xl)),
                  ),
                  child: ListView.builder(
                    controller: controller,
                    padding: const EdgeInsets.all(AppTheme.spaceLg),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
                        child: _AgendaItemCard(
                          item: item,
                          onTap: () {
                            Navigator.pop(context);
                            _showAgendaItemModal(item);
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showAgendaItemModal(AgendaItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radius2xl)),
      ),
      builder: (context) {
        return EventDetailsSheet(
          item: item,
          onViewMore: () {
            if (item.matchId != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MatchDetailScreen(matchId: item.matchId!),
                ),
              );
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const UpcomingFeatureScreen(),
                ),
              );
            }
          },
        );
      },
    );
  }
}

class _NextSevenDays extends StatelessWidget {
  final List<AgendaItem> items;
  const _NextSevenDays({required this.items});

  @override
  Widget build(BuildContext context) {
    final range = TimeRange.getRelevantRange();
    final start = range['start']!;
    final end = range['end']!;
    final upcoming = items
        .where((it) => it.when.isAfter(start) && it.when.isBefore(end))
        .toList()
      ..sort((a, b) => a.when.compareTo(b.when));

    final now = DateTime.now();
    final today = upcoming.where((it) => it.when.day == now.day && it.when.month == now.month && it.when.year == now.year).toList();
    final nextDays = upcoming.where((it) => !(it.when.day == now.day && it.when.month == now.month && it.when.year == now.year)).toList();

    if (upcoming.isEmpty) {
      return SectionCard(
        title: 'Próximos 7 días',
        icon: Icons.calendar_month,
        children: [
          PremiumEmptyState(
            onCreate: PermissionService.instance.canRecordMatch()
                ? () async {
                    await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => const EventCreationScreen(),
                      ),
                    );
                    // Stateless section; parent screens handle refresh
                  }
                : null,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_month, color: AppTheme.primaryGreen),
            const SizedBox(width: AppTheme.spaceSm),
            Text('Próximos 7 días', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),
        if (today.isNotEmpty) ...[
          Text('HOY', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
          const SizedBox(height: AppTheme.spaceSm),
          _HorizontalEventsList(items: today),
          const SizedBox(height: AppTheme.spaceLg),
        ],
        if (nextDays.isNotEmpty) ...[
          Text('PRÓXIMOS DÍAS', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
          const SizedBox(height: AppTheme.spaceSm),
          _HorizontalEventsList(items: nextDays),
        ],
      ],
    );
  }

  void _showItem(BuildContext context, AgendaItem it) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radius2xl)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(it.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppTheme.spaceSm),
            if (it.subtitle != null)
              Text(it.subtitle!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
            const SizedBox(height: AppTheme.spaceLg),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(child: ActionButton(label: 'Ver más', onPressed: () { Navigator.pop(context); }, isFullWidth: true)),
            ]),
          ],
        ),
      ),
    );
  }

  Color _colorForItem(AgendaItem it) {
    final t = it.title.toLowerCase();
    if (it.matchId != null || t.contains('vs')) return AppTheme.info;
    if (t.contains('entrenamiento')) return AppTheme.primaryGreen;
    if (t.contains('reunión') || t.contains('meeting')) return const Color(0xFF6A5ACD);
    if (t.contains('torneo')) return AppTheme.accentOrange;
    return AppTheme.textSecondary;
  }

  IconData _iconForItem(AgendaItem it) {
    final t = it.title.toLowerCase();
    if (it.matchId != null || t.contains('vs')) return Icons.sports_soccer;
    if (t.contains('entrenamiento')) return Icons.fitness_center;
    if (t.contains('reunión') || t.contains('meeting')) return Icons.meeting_room;
    if (t.contains('torneo')) return Icons.emoji_events;
    return Icons.event;
  }

  String _dayLabel(DateTime dt) {
    const weekdays = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
    final w = weekdays[(dt.weekday % 7) - 1];
    return '$w ${dt.day}';
  }
}

class _HorizontalEventsList extends StatelessWidget {
  final List<AgendaItem> items;
  const _HorizontalEventsList({required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppTheme.spaceMd),
        itemBuilder: (context, index) {
          final it = items[index];
          final color = EventStyle.colorFor(it);
          final icon = EventStyle.iconFor(it);
          final day = _dayLabelHorizontal(it.when);
          final hour = '${it.when.hour.toString().padLeft(2, '0')}:${it.when.minute.toString().padLeft(2, '0')}';
          final title = it.title.length > 18 ? '${it.title.substring(0, 18)}…' : it.title;
          return AnimatedScaleTap(
            onTap: () => _showItemHorizontal(context, it),
            child: Container(
              width: 170,
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                boxShadow: AppTheme.shadowSm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.14)),
                      child: Icon(icon, color: color, size: 16),
                    ),
                    const SizedBox(width: AppTheme.spaceSm),
                    Text(day, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.textSecondary)),
                  ]),
                  const SizedBox(height: AppTheme.spaceSm),
                  Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text(hour, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.textSecondary)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

String _dayLabelHorizontal(DateTime dt) {
  const weekdays = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
  final w = weekdays[(dt.weekday % 7) - 1];
  return '$w ${dt.day}';
}

  void _showItemHorizontal(BuildContext context, AgendaItem it) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radius2xl)),
    ),
      builder: (context) => EventDetailsSheet(
        item: it,
        onViewMore: () {
          if (it.matchId != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MatchDetailScreen(matchId: it.matchId!),
              ),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const UpcomingFeatureScreen(),
              ),
            );
          }
        },
      ),
  );
}

class _RecentActivity extends StatefulWidget {
  const _RecentActivity();
  @override
  State<_RecentActivity> createState() => _RecentActivityState();
}

class _RecentActivityState extends State<_RecentActivity> {
  final List<_ActivityItem> _items = [
    _ActivityItem(type: _ActivityType.scheduleChange, text: 'Cambio de horario: Entreno pasa a 19:00', timestamp: DateTime.now().subtract(const Duration(hours: 2))),
    _ActivityItem(type: _ActivityType.newEvent, text: 'Nuevo evento: Reunión técnica', timestamp: DateTime.now().subtract(const Duration(hours: 5))),
    _ActivityItem(type: _ActivityType.friendlyProposal, text: 'Propuesta de amistoso vs Águilas', timestamp: DateTime.now().subtract(const Duration(hours: 9))),
    _ActivityItem(type: _ActivityType.tournamentProgress, text: 'Torneo: Avance a semifinales', timestamp: DateTime.now().subtract(const Duration(hours: 14))),
    _ActivityItem(type: _ActivityType.clubAlert, text: 'Aviso del club: Revisar documentación', timestamp: DateTime.now().subtract(const Duration(hours: 22))),
  ];

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return const SizedBox.shrink();
    }
    return SectionCard(
      title: 'Actividad reciente',
      icon: Icons.bolt,
      children: _items.map((item) {
        return Dismissible(
          key: ValueKey(item.text),
          background: _swipeBackground(context, true),
          secondaryBackground: _swipeBackground(context, false),
          onDismissed: (dir) {
            setState(() => _items.remove(item));
            if (_items.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sin actividad por ahora 👌')),
              );
            }
            NotificationToast.show(
              context,
              title: dir == DismissDirection.startToEnd ? 'Marcado como leído' : 'Acción realizada',
              message: dir == DismissDirection.startToEnd ? 'El ítem se marcó como leído.' : 'Se abrió el detalle.',
              icon: Icons.check_circle,
            );
          },
          child: ListTile(
            leading: _activityIcon(item.type),
            title: Text(item.text, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text(_timeAgo(item.timestamp), style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.textSecondary)),
            onTap: () {
              // Open internal detail modal
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => Padding(
                  padding: const EdgeInsets.all(AppTheme.spaceLg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Detalle de actividad', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: AppTheme.spaceSm),
                      Text(item.text),
                      const SizedBox(height: AppTheme.spaceLg),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _swipeBackground(BuildContext context, bool leading) {
    return Container(
      alignment: leading ? Alignment.centerLeft : Alignment.centerRight,
      color: leading ? AppTheme.success.withValues(alpha: 0.15) : AppTheme.info.withValues(alpha: 0.15),
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
      child: Icon(leading ? Icons.mark_email_read : Icons.open_in_new, color: leading ? AppTheme.success : AppTheme.info),
    );
  }

  Widget _activityIcon(_ActivityType type) {
    switch (type) {
      case _ActivityType.scheduleChange:
        return const Icon(Icons.schedule, color: AppTheme.info);
      case _ActivityType.newEvent:
        return const Icon(Icons.event_available, color: AppTheme.primaryGreen);
      case _ActivityType.friendlyProposal:
        return const Icon(Icons.handshake, color: AppTheme.accentOrange);
      case _ActivityType.tournamentProgress:
        return const Icon(Icons.emoji_events, color: AppTheme.accentOrange);
      case _ActivityType.clubAlert:
        return const Icon(Icons.warning_amber, color: Colors.redAccent);
    }
  }

  String _timeAgo(DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'hace ${diff.inHours}h';
    return 'hace ${diff.inDays}d';
  }
}

enum _ActivityType { scheduleChange, newEvent, friendlyProposal, tournamentProgress, clubAlert }

class _ActivityItem {
  final _ActivityType type;
  final String text;
  final DateTime timestamp;

  _ActivityItem({required this.type, required this.text, required this.timestamp});
}


/// Compact summary chips row: calendar, teams, friendlies, tournaments
class _SummaryChips extends StatelessWidget {
  const _SummaryChips();
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppTheme.spaceMd,
      runSpacing: AppTheme.spaceMd,
      children: const [
        _SummaryChip(icon: Icons.calendar_month, label: 'Calendario'),
        _SummaryChip(icon: Icons.groups_2, label: 'Equipos'),
        _SummaryChip(icon: Icons.handshake, label: 'Amistosos'),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SummaryChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceLg,
        vertical: AppTheme.spaceSm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.primaryGreen),
          const SizedBox(width: AppTheme.spaceSm),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Friendlies section highlight (compact list of last proposals)
class _FriendliesHighlight extends StatelessWidget {
  const _FriendliesHighlight();
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// Team snapshot: category + basic stats
class _TeamSnapshotCard extends StatelessWidget {
  const _TeamSnapshotCard();
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final List<Widget> children;
  const SectionCard({super.key, required this.title, this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon!, color: AppTheme.primaryGreen),
                const SizedBox(width: AppTheme.spaceSm),
              ],
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          ...children,
        ],
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  final String userName;
  final String role;

  const _WelcomeHeader({
    required this.userName,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final greeting = _getGreeting();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Text(
          userName,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceMd,
            vertical: AppTheme.spaceSm,
          ),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Text(
            _getRoleLabel(role),
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'coach':
        return 'Entrenador';
      case 'player':
        return 'Jugador';
      case 'superadmin':
        return 'Super Admin';
      case 'club_admin':
        return 'Admin de Club';
      case 'scout':
        return 'Scout';
      case 'referee':
        return 'Árbitro';
      default:
        return role;
    }
  }
}

class _PremiumHeader extends StatelessWidget {
  final String userName;
  const _PremiumHeader({required this.userName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hour = DateTime.now().hour;
    final timeGreeting = hour < 12 ? 'Buenos días' : hour < 20 ? 'Buenas tardes' : 'Buenas noches';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceLg, horizontal: AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.15)),
            ),
            child: const Icon(Icons.person, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: AppTheme.spaceLg),
          // Greeting and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hola, $userName 👋', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  '$timeGreeting · Tienes eventos esta semana',
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          // Actions removed (use app bar indicators)
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final int count;
  const _IconBadge({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(22),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Icon(icon, color: AppTheme.textSecondary),
        ),
        if (count > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ),
      ],
    );
  }
}

class _QuickOverview extends StatelessWidget {
  final IconData icon;
  final AgendaItem nextMatch;
  final int weekEvents;
  final int unreadChats;
  const _QuickOverview({required this.icon, required this.nextMatch, required this.weekEvents, required this.unreadChats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: AnimatedScaleTap(
            child: _KpiCard(
              title: 'Próximo partido',
              subtitle: nextMatch.title,
              trailing: _formatDate(nextMatch.when),
              icon: Icons.sports_soccer,
              color: AppTheme.info,
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spaceMd),
        Expanded(
          child: AnimatedScaleTap(
            child: _KpiCard(
              title: 'Semana',
              subtitle: 'Eventos: $weekEvents',
              trailing: '→',
              icon: Icons.event,
              color: AppTheme.primaryGreen,
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spaceMd),
        Expanded(
          child: AnimatedScaleTap(
            child: _KpiCard(
              title: 'Chats',
              subtitle: 'Sin leer: $unreadChats',
              trailing: 'Ver',
              icon: Icons.chat_bubble_outline,
              color: AppTheme.accentOrange,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt;
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '$day/$month · $hour:$minute';
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;
  final IconData icon;
  final Color color;
  const _KpiCard({required this.title, required this.subtitle, required this.trailing, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        scale: 1.0,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          onTap: () {},
          hoverColor: AppTheme.primaryGreen.withValues(alpha: 0.02),
          splashColor: AppTheme.primaryGreen.withValues(alpha: 0.06),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: AppTheme.shadowSm,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.12),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: AppTheme.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Text(trailing, style: theme.textTheme.labelMedium?.copyWith(color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AgendaItemCard extends StatelessWidget {
  final AgendaItem item;
  final VoidCallback onTap;

  const _AgendaItemCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = TimeFormat.hourMinute(context, item.when);
    const timeColWidth = 88.0; // fixed width to align column

    return AnimatedScaleTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              ),
              child: Icon(
                item.icon ?? Icons.event,
                color: AppTheme.primaryGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: timeColWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeStr,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryGreen,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(item.when),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);

    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Mañana';
    if (diff.inDays < 7) return 'En ${diff.inDays} días';

    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${date.day} ${months[date.month - 1]}';
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget content;

  const _TabItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.content,
  });
}
