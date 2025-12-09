import 'package:flutter/material.dart';
import '../widgets/animations.dart';
import '../widgets/premium_widgets.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/loading_widgets.dart';
import '../widgets/form_widgets.dart';
import '../theme/app_theme.dart';

class TournamentScreenEnhanced extends StatefulWidget {
  const TournamentScreenEnhanced({super.key});

  @override
  State<TournamentScreenEnhanced> createState() => _TournamentScreenEnhancedState();
}

class _TournamentScreenEnhancedState extends State<TournamentScreenEnhanced> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = false;
  
  final List<TournamentData> _tournaments = [
    TournamentData(
      id: '1',
      name: 'Liga Juvenil 2024',
      type: 'Liga',
      status: 'active',
      teams: ['Barcelona', 'Real Madrid', 'Atlético', 'Valencia'],
      currentMatchday: 5,
      totalMatchdays: 6,
      position: 2,
    ),
    TournamentData(
      id: '2',
      name: 'Copa del Rey',
      type: 'Copa',
      status: 'active',
      teams: ['Barcelona', 'Real Madrid', 'Sevilla', 'Athletic'],
      currentMatchday: 2,
      totalMatchdays: 3,
      position: null,
    ),
    TournamentData(
      id: '3',
      name: 'Torneo de Verano',
      type: 'Copa',
      status: 'finished',
      teams: ['Barcelona', 'Valencia', 'Betis', 'Villarreal'],
      currentMatchday: 3,
      totalMatchdays: 3,
      position: 1,
      champion: 'Barcelona',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Torneos y Ligas'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Activos', icon: Icon(Icons.play_circle_outline)),
            Tab(text: 'Finalizados', icon: Icon(Icons.emoji_events)),
          ],
        ),
      ),
      body: Stack(
        children: [
          _buildGradientBackground(),
          SafeArea(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActiveTournaments(),
                _buildFinishedTournaments(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: QuickActionFab(
        icon: Icons.add,
        label: 'Crear Torneo',
        onPressed: _createTournamentDialog,
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.accentOrange.withValues(alpha: 0.08),
            Colors.transparent,
          ],
          stops: const [0.0, 0.4],
        ),
      ),
    );
  }

  Widget _buildActiveTournaments() {
    final active = _tournaments.where((t) => t.status == 'active').toList();

    if (active.isEmpty) {
      return FadeInSlideUp(
        child: EmptyState(
          icon: Icons.emoji_events_outlined,
          title: 'Sin torneos activos',
          description: 'Crea tu primer torneo o liga',
          actionLabel: 'Crear Torneo',
          onAction: _createTournamentDialog,
        ),
      );
    }

    return PremiumRefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        children: [
          // Header stats
          FadeInSlideUp(
            child: QuickStatsGrid(
              stats: [
                QuickStat(
                  label: 'Torneos',
                  value: '${active.length}',
                  icon: Icons.emoji_events,
                  color: AppTheme.accentOrange,
                ),
                QuickStat(
                  label: 'Partidos',
                  value: '24',
                  icon: Icons.sports_soccer,
                  color: AppTheme.primaryGreen,
                ),
                QuickStat(
                  label: 'Victorias',
                  value: '15',
                  icon: Icons.check_circle,
                  color: AppTheme.success,
                ),
                QuickStat(
                  label: 'Goles',
                  value: '48',
                  icon: Icons.sports,
                  color: AppTheme.info,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spaceXl),

          // Tournaments list
          Text(
            'Mis Torneos',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppTheme.spaceLg),

          StaggeredList(
            delay: const Duration(milliseconds: 100),
            children: active.map((tournament) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
                child: _TournamentCard(
                  tournament: tournament,
                  onTap: () => _openTournamentDetail(tournament),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishedTournaments() {
    final finished = _tournaments.where((t) => t.status == 'finished').toList();

    if (finished.isEmpty) {
      return FadeInSlideUp(
        child: EmptyState(
          icon: Icons.emoji_events,
          title: 'Sin torneos finalizados',
          description: 'Los torneos completados aparecerán aquí',
        ),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      children: [
        StaggeredList(
          children: finished.map((tournament) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
              child: _TournamentCard(
                tournament: tournament,
                onTap: () => _openTournamentDetail(tournament),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _openTournamentDetail(TournamentData tournament) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TournamentDetailScreen(tournament: tournament),
      ),
    );
  }

  void _createTournamentDialog() async {
    final nameController = TextEditingController();
    String type = 'Liga';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusXl)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(AppTheme.spaceXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.primaryGradient,
                    ),
                    child: const Icon(Icons.emoji_events, color: Colors.white),
                  ),
                  const SizedBox(width: AppTheme.spaceMd),
                  Expanded(
                    child: Text(
                      'Crear Torneo',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceXl),
              PremiumTextField(
                label: 'Nombre del torneo',
                hint: 'Ej: Liga Juvenil 2024',
                controller: nameController,
                prefixIcon: Icons.emoji_events,
              ),
              const SizedBox(height: AppTheme.spaceLg),
              PremiumChipSelector<String>(
                label: 'Tipo de competición',
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
                selected: type,
                onSelected: (value) => type = value,
              ),
              const SizedBox(height: AppTheme.spaceXl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceMd),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceMd),
                  Expanded(
                    child: ActionButton(
                      label: 'Crear',
                      onPressed: () => Navigator.pop(context, true),
                      isFullWidth: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true && mounted) {
      NotificationToast.show(
        context,
        title: 'Torneo creado correctamente',
        message: 'Se notificará a los miembros del equipo.',
        icon: Icons.check_circle,
      );
    }
  }
}

// Models
class TournamentData {
  final String id;
  final String name;
  final String type;
  final String status;
  final List<String> teams;
  final int currentMatchday;
  final int totalMatchdays;
  final int? position;
  final String? champion;

  TournamentData({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.teams,
    required this.currentMatchday,
    required this.totalMatchdays,
    this.position,
    this.champion,
  });
}

// Widgets
class _TournamentCard extends StatelessWidget {
  final TournamentData tournament;
  final VoidCallback onTap;

  const _TournamentCard({
    required this.tournament,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFinished = tournament.status == 'finished';
    final typeColor = tournament.type == 'Liga' ? AppTheme.primaryGreen : AppTheme.accentOrange;

    return AnimatedScaleTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: AppTheme.shadowMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: typeColor.withValues(alpha: 0.15),
                  ),
                  child: Icon(
                    tournament.type == 'Liga' ? Icons.format_list_numbered : Icons.emoji_events,
                    color: typeColor,
                  ),
                ),
                const SizedBox(width: AppTheme.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tournament.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spaceSm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            child: Text(
                              tournament.type,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: typeColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spaceSm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spaceSm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isFinished
                                  ? AppTheme.textTertiary.withValues(alpha: 0.15)
                                  : AppTheme.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            child: Text(
                              isFinished ? 'Finalizado' : 'En curso',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isFinished ? AppTheme.textTertiary : AppTheme.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceLg),

            // Progress
            if (!isFinished) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Jornada ${tournament.currentMatchday} de ${tournament.totalMatchdays}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    '${((tournament.currentMatchday / tournament.totalMatchdays) * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: typeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceSm),
              AnimatedProgressBar(
                value: tournament.currentMatchday / tournament.totalMatchdays,
                color: typeColor,
              ),
            ],

            // Champion badge
            if (isFinished && tournament.champion != null) ...[
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                decoration: BoxDecoration(
                  gradient: AppTheme.heroGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.white, size: 20),
                    const SizedBox(width: AppTheme.spaceSm),
                    Text(
                      'Campeón: ${tournament.champion}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppTheme.spaceLg),

            // Stats
            Row(
              children: [
                _MiniStat(
                  icon: Icons.groups,
                  label: 'Equipos',
                  value: '${tournament.teams.length}',
                ),
                const SizedBox(width: AppTheme.spaceLg),
                if (tournament.position != null)
                  _MiniStat(
                    icon: Icons.military_tech,
                    label: 'Posición',
                    value: '${tournament.position}°',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// Detail Screen
class TournamentDetailScreen extends StatefulWidget {
  final TournamentData tournament;

  const TournamentDetailScreen({super.key, required this.tournament});

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tournament.type == 'Liga' ? 3 : 2,
      vsync: this,
    );
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
        title: Text(widget.tournament.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Partidos', icon: Icon(Icons.sports_soccer)),
            if (widget.tournament.type == 'Liga')
              const Tab(text: 'Clasificación', icon: Icon(Icons.format_list_numbered)),
            if (widget.tournament.type == 'Copa')
              const Tab(text: 'Bracket', icon: Icon(Icons.account_tree)),
            const Tab(text: 'Estadísticas', icon: Icon(Icons.bar_chart)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMatchesTab(),
          if (widget.tournament.type == 'Liga')
            _buildStandingsTab()
          else
            _buildBracketTab(),
          _buildStatsTab(),
        ],
      ),
    );
  }

  Widget _buildMatchesTab() {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      children: [
        FadeInSlideUp(
          child: MatchCard(
            homeTeam: 'Barcelona',
            awayTeam: 'Real Madrid',
            homeScore: '2',
            awayScore: '1',
            status: 'Finalizado',
            dateTime: DateTime.now().subtract(const Duration(days: 2)),
            statusColor: AppTheme.success,
            onTap: () {},
          ),
        ),
        const SizedBox(height: AppTheme.spaceMd),
        FadeInSlideUp(
          delay: const Duration(milliseconds: 100),
          child: MatchCard(
            homeTeam: 'Atlético',
            awayTeam: 'Valencia',
            homeScore: null,
            awayScore: null,
            status: 'Programado',
            dateTime: DateTime.now().add(const Duration(days: 5)),
            statusColor: AppTheme.info,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildStandingsTab() {
    final standings = [
      {'team': 'Barcelona', 'played': 5, 'wins': 4, 'draws': 1, 'losses': 0, 'pts': 13},
      {'team': 'Real Madrid', 'played': 5, 'wins': 3, 'draws': 1, 'losses': 1, 'pts': 10},
      {'team': 'Atlético', 'played': 5, 'wins': 2, 'draws': 2, 'losses': 1, 'pts': 8},
      {'team': 'Valencia', 'played': 5, 'wins': 0, 'draws': 1, 'losses': 4, 'pts': 1},
    ];

    return ListView(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      children: [
        FadeInSlideUp(
          child: RankingList(
            title: 'Clasificación',
            items: standings.map((s) => RankingItem(
              name: s['team'] as String,
              value: (s['pts'] as int).toString(),
              subtitle: 'PJ: ${s['played']} | V: ${s['wins']} | E: ${s['draws']} | D: ${s['losses']}',
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBracketTab() {
    return Center(
      child: FadeInSlideUp(
        child: EmptyState(
          icon: Icons.account_tree,
          title: 'Bracket próximamente',
          description: 'La visualización del bracket estará disponible pronto',
        ),
      ),
    );
  }

  Widget _buildStatsTab() {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      children: [
        FadeInSlideUp(
          child: PerformanceChart(
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
        ),
      ],
    );
  }
}
