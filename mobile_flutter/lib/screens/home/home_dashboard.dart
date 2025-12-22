import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../theme/app_theme.dart';
import '../../services/agenda_service.dart';
import '../event_detail_screen.dart';
import '../../widgets/loading_widgets.dart';
import '../../services/auth_service.dart';
import '../../services/club_registry.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  late final Future<List<AgendaItem>> _upcomingFuture;
  String _clubTitle = 'Mi Club';
  String _clubSubtitle = 'Panel del club';

  @override
  void initState() {
    super.initState();
    _upcomingFuture = AgendaService.instance.getUpcoming();

    final clubId = AuthService.instance.activeContext?.clubId;
    final club = (clubId != null && clubId.isNotEmpty)
        ? ClubRegistry.getClubById(clubId)
        : null;
    if (club != null) {
      _clubTitle = club.name;
      final parts = <String>[];
      if ((club.city ?? '').trim().isNotEmpty) parts.add(club.city!.trim());
      if ((club.country ?? '').trim().isNotEmpty) parts.add(club.country!.trim());
      _clubSubtitle = parts.isEmpty ? 'Panel del club' : parts.join(' • ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Premium feel on web/desktop: keep content readable by constraining width.
          final maxContentWidth = constraints.maxWidth >= 900 ? 980.0 : double.infinity;
          return SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spaceLg),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeaderBranding(title: _clubTitle, subtitle: _clubSubtitle),
                        const SizedBox(height: AppTheme.spaceXl),
                        const _KpiRow(),
                        const SizedBox(height: AppTheme.spaceXl),
                        _UpcomingEventsRow(upcomingFuture: _upcomingFuture),
                        const SizedBox(height: AppTheme.spaceXl),
                        const _QuickActionsGrid(),
                        SizedBox(height: theme.platform == TargetPlatform.android || theme.platform == TargetPlatform.iOS ? 0 : AppTheme.spaceLg),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeaderBranding extends StatelessWidget {
  final String title;
  final String subtitle;
  const _HeaderBranding({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktopLike = kIsWeb ||
        theme.platform == TargetPlatform.windows ||
        theme.platform == TargetPlatform.macOS ||
        theme.platform == TargetPlatform.linux;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceXl),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        // Web/desktop: keep it premium but less "heavy".
        boxShadow: isDesktopLike ? AppTheme.shadowMd : AppTheme.shadowLg,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const Icon(Icons.shield, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: AppTheme.spaceLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.white.withValues(alpha: 0.85))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  const _KpiRow();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 720;

        final cards = const [
          _KpiCard(icon: Icons.sports_soccer, label: 'Próximo partido', value: 'Sáb 18:00'),
          _KpiCard(icon: Icons.fitness_center, label: 'Entrenamiento', value: 'Jue 17:00'),
          _KpiCard(icon: Icons.notifications, label: 'No leídas', value: '3'),
        ];

        if (isNarrow) {
          return Column(
            children: const [
              _KpiCard(icon: Icons.sports_soccer, label: 'Próximo partido', value: 'Sáb 18:00'),
              SizedBox(height: AppTheme.spaceLg),
              _KpiCard(icon: Icons.fitness_center, label: 'Entrenamiento', value: 'Jue 17:00'),
              SizedBox(height: AppTheme.spaceLg),
              _KpiCard(icon: Icons.notifications, label: 'No leídas', value: '3'),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: AppTheme.spaceLg),
            Expanded(child: cards[1]),
            const SizedBox(width: AppTheme.spaceLg),
            Expanded(child: cards[2]),
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _KpiCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppTheme.primaryGreen.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: AppTheme.spaceMd),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _UpcomingEventsRow extends StatelessWidget {
  final Future<List<AgendaItem>> upcomingFuture;
  const _UpcomingEventsRow({required this.upcomingFuture});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Próximos eventos',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppTheme.spaceMd),
        SizedBox(
          height: 96,
          child: FutureBuilder<List<AgendaItem>>(
            future: upcomingFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: AppTheme.spaceMd),
                  itemBuilder: (context, index) {
                    return ShimmerBox(
                      width: 240,
                      height: 96,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    );
                  },
                );
              }

              if (snapshot.hasError) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'No se pudieron cargar los eventos.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }

              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'No hay eventos próximos.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppTheme.spaceMd),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _EventPill(item: item);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EventPill extends StatelessWidget {
  final AgendaItem item;
  const _EventPill({required this.item});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktopLike = kIsWeb ||
        theme.platform == TargetPlatform.windows ||
        theme.platform == TargetPlatform.macOS ||
        theme.platform == TargetPlatform.linux;

    final semanticLabel = '${item.title}. ${item.subtitle}';

    final overlay = WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.pressed)) {
        return theme.colorScheme.primary.withValues(alpha: 0.14);
      }
      if (states.contains(WidgetState.focused)) {
        return theme.colorScheme.primary.withValues(alpha: 0.12);
      }
      if (states.contains(WidgetState.hovered)) {
        return theme.colorScheme.primary.withValues(alpha: 0.08);
      }
      return null;
    });

    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      overlayColor: overlay,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EventDetailScreen(event: item),
          ),
        );
      },
      child: Semantics(
        button: true,
        label: semanticLabel,
        child: Tooltip(
          message: semanticLabel,
          child: Material(
            color: Colors.transparent,
            child: Ink(
              width: 240,
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                // Web/desktop: keep depth subtle.
                boxShadow: isDesktopLike ? AppTheme.shadowSm : AppTheme.shadowSm,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryTeal.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: AppTheme.secondaryTeal),
                  ),
                  const SizedBox(width: AppTheme.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceXs),
                        Text(
                          item.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(icon: Icons.add_box, label: 'Crear evento', route: '/event_creator'),
      _QuickAction(icon: Icons.groups, label: 'Convocar jugadores', route: '/callups'),
      _QuickAction(icon: Icons.fitness_center, label: 'Entrenamientos', route: '/training_rules'),
      _QuickAction(icon: Icons.campaign, label: 'Anuncios', route: '/announcements'),
      _QuickAction(icon: Icons.chat, label: 'Chat del equipo', route: '/team_chat'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: actions
            .map(
              (action) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceSm),
                child: _QuickActionCircle(action: action),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final String? route;
  const _QuickAction({required this.icon, required this.label, this.route});
}


class _QuickActionCircle extends StatelessWidget {
  final _QuickAction action;
  const _QuickActionCircle({required this.action});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktopLike = kIsWeb ||
        theme.platform == TargetPlatform.windows ||
        theme.platform == TargetPlatform.macOS ||
        theme.platform == TargetPlatform.linux;

    final overlay = WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.pressed)) {
        return Colors.white.withValues(alpha: 0.22);
      }
      if (states.contains(WidgetState.focused)) {
        return Colors.white.withValues(alpha: 0.18);
      }
      if (states.contains(WidgetState.hovered)) {
        return Colors.white.withValues(alpha: 0.12);
      }
      return null;
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: Semantics(
            button: true,
            label: action.label,
            child: Tooltip(
              message: action.label,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppTheme.radius3xl),
                overlayColor: overlay,
                onTap: () {
                  final route = action.route;
                  if (route != null) {
                    Navigator.of(context).pushNamed(route);
                  }
                },
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    gradient: AppTheme.heroGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radius3xl),
                    // Web/desktop: reduce glow to feel less heavy.
                    boxShadow: isDesktopLike ? AppTheme.shadowSm : AppTheme.shadowMd,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: isDesktopLike ? 0.14 : 0.18),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      action.icon,
                      color: Colors.white,
                      size: 28,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 108,
          child: Text(
            action.label,
            style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  height: 1.15,
                  color: theme.colorScheme.onSurface,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
