import 'package:flutter/material.dart';
import 'convocatoria_flow_screen.dart';
import '../services/auth_service.dart';
import '../services/agenda_service.dart';
import '../services/match_service.dart';
import '../services/permission_service.dart';
import '../models/permissions.dart';
import '../services/club_registry.dart';
import '../widgets/notification_indicator.dart';
import 'match_detail_screen.dart';
import 'team_screen.dart';
import 'tournament_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'friendly_match_screen.dart';
import 'friendly_matches/friendly_match_creator_screen.dart';
import 'friendly_matches/incoming_requests_screen.dart';
import 'friendly_matches/outgoing_requests_screen.dart';
import 'friendly_matches/request_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _handleAgendaTap(AgendaItem item) {
    if (item.matchId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MatchDetailScreen(matchId: item.matchId!),
        ),
      );
      return;
    }
    
    // Navigate to the correct tab instead of pushing a new route
    final tabs = _tabs;
    final isTournament = item.title.toLowerCase().contains('liga') || item.title.toLowerCase().contains('torneo');
    
    if (isTournament) {
      // Find and select the Tournaments tab
      final tournamentIndex = tabs.indexWhere((t) => t.label == 'Torneos');
      if (tournamentIndex >= 0) {
        setState(() => _currentIndex = tournamentIndex);
        return;
      }
    } else {
      // Find and select the Friendly Matches tab
      final friendlyIndex = tabs.indexWhere((t) => t.label == 'Amistosos');
      if (friendlyIndex >= 0) {
        setState(() => _currentIndex = friendlyIndex);
        return;
      }
    }
  }

  List<_TabItem> get _tabs {
    // Centralizado: permisos premium
    final user = AuthService.instance.currentUser;
    final context = AuthService.instance.activeContext; // Puede ser null
    final perms = PermissionService.getPermissionsForContext(context);
    final items = <_TabItem>[];
    if (perms.contains(Permission.viewEvents)) {
      items.add(_TabItem(label: 'Inicio', icon: Icons.home_outlined, selectedIcon: Icons.home, content: _HomeDashboard(onAgendaTap: _handleAgendaTap)));
    }
    if (perms.contains(Permission.viewTeam)) {
      final clubId = AuthService.instance.activeContext?.clubId;
      final club = ClubRegistry.getClubById(clubId) ?? (ClubRegistry.clubs.isNotEmpty ? ClubRegistry.clubs.first : null);
      if (club != null) {
        items.add(_TabItem(label: 'Equipo', icon: Icons.people_outline, selectedIcon: Icons.people, content: TeamScreen(club: club)));
      }
    }
    if (perms.contains(Permission.manageFriendly) || perms.contains(Permission.createFriendlyRequest)) {
      items.add(const _TabItem(label: 'Amistosos', icon: Icons.handshake_outlined, selectedIcon: Icons.handshake, content: FriendlyMatchScreen()));
    }
    // Torneos deshabilitado por feature flag
    // if (perms.contains(Permission.manageTournaments)) {
    //   items.add(const _TabItem(label: 'Torneos', icon: Icons.emoji_events_outlined, selectedIcon: Icons.emoji_events, content: TournamentScreen()));
    // }
    if (perms.contains(Permission.viewPersonalStats) || items.isEmpty) {
      items.add(const _TabItem(label: 'Perfil', icon: Icons.person_outline, selectedIcon: Icons.person, content: ProfileScreen()));
    }
    return items;
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
        title: const Text('Football Coaches'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          NotificationIndicator(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => const NotificationBottomSheet(),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                isScrollControlled: true,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.instance.logout();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          IconButton(
            icon: const Icon(Icons.campaign),
            tooltip: 'Convocatorias',
            onPressed: () {
              Navigator.pushNamed(context, '/convocatoria');
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex.clamp(0, tabs.isNotEmpty ? tabs.length - 1 : 0),
        children: tabs.map((t) => t.content).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex.clamp(0, tabs.isNotEmpty ? tabs.length - 1 : 0),
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: tabs
            .map((t) => NavigationDestination(icon: Icon(t.icon), selectedIcon: Icon(t.selectedIcon), label: t.label))
            .toList(),
      ),
      floatingActionButton: null,
    );
  }
}

class _HomeDashboard extends StatefulWidget {
  final void Function(AgendaItem) onAgendaTap;
  const _HomeDashboard({required this.onAgendaTap});

  @override
  State<_HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<_HomeDashboard> {
  late Future<List<AgendaItem>> _futureAgenda;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _futureAgenda = AgendaService.instance.getUpcoming();
  }

  @override
  Widget build(BuildContext context) {
    final perms = PermissionService.getPermissionsForContext(AuthService.instance.activeContext);
    var role = AuthService.instance.currentUser?.role;
    late String roleStr;
    if (role is Enum) {
      roleStr = role.toString().split('.').last.toLowerCase();
    } else {
      roleStr = (role?.toString() ?? 'coach').toLowerCase();
    }
    final theme = Theme.of(context);

    return Column(
      children: [
        // ...existing code...
        ElevatedButton.icon(
          icon: const Icon(Icons.campaign),
          label: const Text('Crear convocatoria'),
          onPressed: () {
            Navigator.pushNamed(context, '/convocatoria');
          },
        ),
        // ...existing code...
      ],
    );
  }
}

class _HomeBackdrop extends StatelessWidget {
  const _HomeBackdrop();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primary.withValues(alpha: 0.14),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String role;
  final VoidCallback onCreateFriendly;
  const _HeroCard({required this.role, required this.onCreateFriendly});

  @override
  Widget build(BuildContext context) {
    final roleKey = role.toLowerCase();
    String heroTitle;
    String heroSubtitle;
    switch (roleKey) {
      case 'player':
        heroTitle = 'Tu plan para hoy';
        heroSubtitle = 'Consulta horarios, confirma asistencia y recibe avisos clave.';
        break;
      case 'staff':
        heroTitle = 'Coordina al cuerpo técnico';
        heroSubtitle = 'Comparte novedades tácticas, controla cargas y mantén feedback constante.';
        break;
      case 'manager':
        heroTitle = 'Gestiona la jornada';
        heroSubtitle = 'Supervisa agenda, resultados y seguimientos desde un mismo panel.';
        break;
      default:
        heroTitle = 'Planifica el próximo partido';
        heroSubtitle = 'Organiza amistosos, convoca al plantel y comunica ajustes al instante.';
        break;
    }

    final theme = Theme.of(context);
    final gradient = LinearGradient(
      colors: [
        theme.colorScheme.primary,
        theme.colorScheme.primary.withValues(alpha: 0.78),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.16),
            blurRadius: 30,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.18),
            ),
            child: const Icon(Icons.sports_soccer, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(heroTitle, style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(heroSubtitle, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.82))),
                const SizedBox(height: 20),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: onCreateFriendly,
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Crear amistoso'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = <_QuickActionData>[
      _QuickActionData(
        label: 'Convocar jugadores',
        icon: Icons.campaign,
        builder: (_) => const ConvocatoriaFlowScreen(),
      ),
      _QuickActionData(
        label: 'Mi equipo',
        icon: Icons.people,
        builder: (_) {
          final clubId = AuthService.instance.activeContext?.clubId;
          final club = ClubRegistry.getClubById(clubId) ?? (ClubRegistry.clubs.isNotEmpty ? ClubRegistry.clubs.first : null);
          if (club == null) {
            return const Scaffold(
              body: Center(child: Text('No hay un club seleccionado.')),
            );
          }
          return TeamScreen(club: club);
        },
      ),
      _QuickActionData(
        label: 'Amistosos',
        icon: Icons.handshake,
        builder: (_) => const FriendlyMatchScreen(),
      ),
      // _QuickActionData(
      //   label: 'Torneos',
      //   icon: Icons.emoji_events,
      //   builder: (_) => const TournamentScreen(),
      // ),
      _QuickActionData(
        label: 'Chat',
        icon: Icons.chat_bubble,
        builder: (_) => const ChatScreen(),
      ),
    ];

    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: actions
              .map(
                  (action) => FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), // Reduced padding
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Slightly smaller radius
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: action.builder));
                    },
                    icon: Icon(action.icon, color: theme.colorScheme.primary, size: 20),
                    label: Text(
                      action.label,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), // Smaller font
                    ),
                  ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7)),
        ),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 160,
        child: Center(
          child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _ErrorCard({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hubo un problema al cargar la agenda', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Verifica tu conexión o inténtalo de nuevo en unos segundos.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.72))),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => onRetry(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAgendaCard extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyAgendaCard({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sin eventos próximos', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Aún no hay actividades agendadas. Crea un amistoso o programa una sesión de entrenamiento.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.72))),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Crear evento'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionData {
  final String label;
  final IconData icon;
  final WidgetBuilder builder;

  const _QuickActionData({required this.label, required this.icon, required this.builder});
}

class _AgendaTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String timeLabel;
  final String subtitle;
  final String relative;
  final int index;
  final VoidCallback onTap;

  const _AgendaTile({
    required this.icon,
    required this.title,
    required this.timeLabel,
    required this.subtitle,
    required this.relative,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final trailing = <Widget>[];
    trailing.add(
      CircleAvatar(
        radius: 12,
        backgroundColor: Colors.white.withValues(alpha: 0.12),
        child: Text('$index', style: const TextStyle(fontSize: 12, color: Colors.white)),
      ),
    );

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$timeLabel · $subtitle',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.72)),
                    ),
                    const SizedBox(height: 8),
                    Text(relative, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6))),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: trailing,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgendaDayPicker extends StatelessWidget {
  final List<DateTime> days;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onChanged;

  const _AgendaDayPicker({required this.days, required this.selectedDay, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = _startOfDay(day) == _startOfDay(selectedDay);
          return ChoiceChip(
            label: Text(_dayLabel(day)),
            selected: isSelected,
            onSelected: (_) => onChanged(day),
            selectedColor: Theme.of(context).colorScheme.primary,
            labelStyle: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: days.length,
      ),
    );
  }
}

class _AgendaDaySummary extends StatelessWidget {
  final List<AgendaItem> items;
  final DateTime day;

  const _AgendaDaySummary({required this.items, required this.day});

  @override
  Widget build(BuildContext context) {
    final matches = items.where((i) => i.matchId != null).toList();
    final otherEvents = items.length - matches.length;
    final now = DateTime.now();
    final upcoming = items.where((i) => i.when.isAfter(now)).toList()
      ..sort((a, b) => a.when.compareTo(b.when));
    final nextLabel = items.isEmpty
        ? 'Libre'
        : upcoming.isNotEmpty
            ? TimeOfDay.fromDateTime(upcoming.first.when).format(context)
            : 'Completado';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          _SummaryStat(label: 'Eventos', value: '${items.length}'),
          const SizedBox(width: 16),
          _SummaryStat(label: 'Partidos', value: '${matches.length}', hint: otherEvents > 0 ? '+$otherEvents otros' : null),
          const SizedBox(width: 16),
          _SummaryStat(label: 'Próximo', value: nextLabel),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final String? hint;

  const _SummaryStat({required this.label, required this.value, this.hint});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7))),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          if (hint != null)
            Text(
              hint!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}

Map<DateTime, List<AgendaItem>> _groupAgendaByDay(List<AgendaItem> items) {
  final map = <DateTime, List<AgendaItem>>{};
  for (final item in items) {
    final day = _startOfDay(item.when);
    map.putIfAbsent(day, () => []).add(item);
  }
  for (final entry in map.entries) {
    entry.value.sort((a, b) => a.when.compareTo(b.when));
  }
  return map;
}

DateTime _startOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

String _dayLabel(DateTime day) {
  final today = _startOfDay(DateTime.now());
  final diff = day.difference(today).inDays;
  if (diff == 0) return 'Hoy';
  if (diff == 1) return 'Mañana';
  if (diff == -1) return 'Ayer';
  const weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  final weekday = weekdays[day.weekday - 1];
  return '$weekday ${day.day}/${day.month}';
}

String _statusLabel(String status) {
  switch (status) {
    case 'scheduled':
      return 'Programado';
    case 'live':
      return 'En juego';
    case 'finished':
      return 'Finalizado';
    default:
      return status;
  }
}

Color _statusChipColor(String status) {
  switch (status) {
    case 'live':
      return Colors.orangeAccent.shade100;
    case 'finished':
      return Colors.blueGrey.shade100;
    default:
      return Colors.greenAccent.shade100;
  }
}

String _relativeAgendaTime(DateTime when) {
  final now = DateTime.now();
  final diff = when.difference(now);
  if (diff.inDays > 0) {
    final days = diff.inDays;
    return days == 1 ? 'Mañana' : 'En $days días';
  }
  if (diff.inHours > 0) {
    final hours = diff.inHours;
    return hours == 1 ? 'En 1 hora' : 'En $hours horas';
  }
  if (diff.inMinutes > 0) {
    final minutes = diff.inMinutes;
    return minutes == 1 ? 'En 1 minuto' : 'En $minutes minutos';
  }
  return 'En curso';
}

class _TabItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget content;

  const _TabItem({required this.label, required this.icon, required this.selectedIcon, required this.content});
}

final Map<String, WidgetBuilder> friendlyRoutes = {
  '/friendly_matches/create': (_) => const FriendlyMatchCreatorScreen(),
  '/friendly_matches/incoming': (_) => const IncomingRequestsScreen(),
  '/friendly_matches/outgoing': (_) => const OutgoingRequestsScreen(),
  '/friendly_matches/request_edit': (_) => const RequestEditScreen(),
};
