import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';

/// ⚽ **MATCH TIMELINE** - Interactive event timeline for live matches
/// Premium timeline with animations for goals, cards, substitutions

class MatchTimeline extends StatelessWidget {
  final List<TimelineEvent> events;
  final bool isLive;

  const MatchTimeline({
    super.key,
    required this.events,
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeInSlideUp(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.timeline,
                      color: AppTheme.primaryGreen,
                      size: 24,
                    ),
                    const SizedBox(width: AppTheme.spaceSm),
                    Text(
                      'Timeline del Partido',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                if (isLive)
                  PulseAnimation(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spaceMd,
                        vertical: AppTheme.spaceSm,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.error,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'EN VIVO',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceXl),

            // Timeline events
            if (events.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.space2xl),
                  child: Column(
                    children: [
                      Icon(
                        Icons.sports_soccer,
                        size: 48,
                        color: AppTheme.textTertiary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: AppTheme.spaceMd),
                      Text(
                        'No hay eventos aún',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return FadeInSlideUp(
                    delay: Duration(milliseconds: 80 * index),
                    child: _TimelineEventItem(
                      event: events[index],
                      isFirst: index == 0,
                      isLast: index == events.length - 1,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _TimelineEventItem extends StatelessWidget {
  final TimelineEvent event;
  final bool isFirst;
  final bool isLast;

  const _TimelineEventItem({
    required this.event,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventColor = _getEventColor(event.type);

    return AnimatedScaleTap(
      onTap: event.onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          SizedBox(
            width: 50,
            child: Text(
              "${event.minute}'",
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: eventColor,
              ),
            ),
          ),

          // Timeline indicator
          Column(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [eventColor, eventColor.withValues(alpha: 0.7)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: eventColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  _getEventIcon(event.type),
                  color: Colors.white,
                  size: 20,
                ),
              ),

              // Connector line
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        eventColor.withValues(alpha: 0.5),
                        AppTheme.textTertiary.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: AppTheme.spaceMd),

          // Event details
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: AppTheme.spaceLg),
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              decoration: BoxDecoration(
                color: eventColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(
                  color: eventColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spaceSm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: eventColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Text(
                      _getEventTypeLabel(event.type),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: eventColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceSm),

                  // Player name
                  Text(
                    event.playerName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // Additional info
                  if (event.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      event.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],

                  // Team indicator
                  const SizedBox(height: AppTheme.spaceSm),
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: event.isHomeTeam
                              ? AppTheme.primaryGreen
                              : AppTheme.accentBlue,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        event.teamName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.goal:
        return AppTheme.success;
      case EventType.yellowCard:
        return AppTheme.warning;
      case EventType.redCard:
        return AppTheme.error;
      case EventType.substitution:
        return AppTheme.info;
      case EventType.penalty:
        return AppTheme.accentOrange;
      case EventType.ownGoal:
        return const Color(0xFF6B4E71);
      case EventType.varCheck:
        return AppTheme.secondaryTeal;
    }
  }

  IconData _getEventIcon(EventType type) {
    switch (type) {
      case EventType.goal:
        return Icons.sports_soccer;
      case EventType.yellowCard:
      case EventType.redCard:
        return Icons.square;
      case EventType.substitution:
        return Icons.swap_horiz;
      case EventType.penalty:
        return Icons.gps_fixed;
      case EventType.ownGoal:
        return Icons.sports_soccer;
      case EventType.varCheck:
        return Icons.video_camera_back;
    }
  }

  String _getEventTypeLabel(EventType type) {
    switch (type) {
      case EventType.goal:
        return 'GOL';
      case EventType.yellowCard:
        return 'AMARILLA';
      case EventType.redCard:
        return 'ROJA';
      case EventType.substitution:
        return 'CAMBIO';
      case EventType.penalty:
        return 'PENALTI';
      case EventType.ownGoal:
        return 'AUTOGOL';
      case EventType.varCheck:
        return 'VAR';
    }
  }
}

enum EventType {
  goal,
  yellowCard,
  redCard,
  substitution,
  penalty,
  ownGoal,
  varCheck,
}

class TimelineEvent {
  final int minute;
  final EventType type;
  final String playerName;
  final String teamName;
  final bool isHomeTeam;
  final String? description;
  final VoidCallback? onTap;

  TimelineEvent({
    required this.minute,
    required this.type,
    required this.playerName,
    required this.teamName,
    required this.isHomeTeam,
    this.description,
    this.onTap,
  });
}

/// 🎯 **MATCH STATS COMPARISON** - Side-by-side team stats
class MatchStatsComparison extends StatelessWidget {
  final List<MatchStat> stats;
  final String homeTeam;
  final String awayTeam;

  const MatchStatsComparison({
    super.key,
    required this.stats,
    required this.homeTeam,
    required this.awayTeam,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeInSlideUp(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: AppTheme.primaryGreen,
                  size: 24,
                ),
                const SizedBox(width: AppTheme.spaceSm),
                Text(
                  'Estadísticas',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceXl),

            // Team headers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    homeTeam,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryGreen,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: AppTheme.spaceLg),
                Expanded(
                  child: Text(
                    awayTeam,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceLg),

            // Stats
            ...stats.asMap().entries.map((entry) {
              final index = entry.key;
              final stat = entry.value;
              return FadeInSlideUp(
                delay: Duration(milliseconds: 80 * index),
                child: _MatchStatItem(stat: stat),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _MatchStatItem extends StatelessWidget {
  final MatchStat stat;

  const _MatchStatItem({required this.stat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = stat.homeValue + stat.awayValue;
    final homePercent = total > 0 ? stat.homeValue / total : 0.5;
    final awayPercent = total > 0 ? stat.awayValue / total : 0.5;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceLg),
      child: Column(
        children: [
          // Values
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stat.homeValue.toString(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryGreen,
                ),
              ),
              Text(
                stat.label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                stat.awayValue.toString(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accentBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),

          // Progress bars
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  // Home team bar
                  Expanded(
                    flex: (homePercent * 100).toInt(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryGreen,
                            AppTheme.primaryGreen.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Away team bar
                  Expanded(
                    flex: (awayPercent * 100).toInt(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.accentBlue.withValues(alpha: 0.7),
                            AppTheme.accentBlue,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MatchStat {
  final String label;
  final int homeValue;
  final int awayValue;

  MatchStat({
    required this.label,
    required this.homeValue,
    required this.awayValue,
  });
}
