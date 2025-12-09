import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';

/// 📊 **ADVANCED DASHBOARD WIDGETS**
/// Interactive charts, stats, and premium visualizations

/// 🎯 **DASHBOARD HEADER** - Hero section with stats
class DashboardHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<DashboardStat> stats;
  final VoidCallback? onActionTap;
  final String? actionLabel;

  const DashboardHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.stats,
    this.onActionTap,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedGradientContainer(
      colors: isDark
          ? [AppTheme.darkSurface, AppTheme.darkSurfaceVariant]
          : [AppTheme.primaryGreen, AppTheme.secondaryTeal],
      borderRadius: BorderRadius.circular(AppTheme.radius2xl),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            FadeInSlideUp(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spaceXl),

            // Stats Row
            StaggeredList(
              direction: Axis.horizontal,
              delay: const Duration(milliseconds: 100),
              children: stats.map((stat) {
                return Expanded(
                  child: _DashboardStatItem(
                    stat: stat,
                    isDark: isDark,
                  ),
                );
              }).toList(),
            ),

            // Action Button
            if (onActionTap != null && actionLabel != null) ...[
              const SizedBox(height: AppTheme.spaceLg),
              FadeInSlideUp(
                delay: const Duration(milliseconds: 400),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onActionTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      actionLabel!,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DashboardStatItem extends StatelessWidget {
  final DashboardStat stat;
  final bool isDark;

  const _DashboardStatItem({
    required this.stat,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.18),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        children: [
          Icon(
            stat.icon,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            stat.value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stat.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class DashboardStat {
  final String label;
  final String value;
  final IconData icon;

  DashboardStat({
    required this.label,
    required this.value,
    required this.icon,
  });
}

/// 📈 **PERFORMANCE CHART** - Beautiful line/bar chart
class PerformanceChart extends StatelessWidget {
  final List<ChartData> data;
  final String title;
  final ChartType type;
  final Color? color;

  const PerformanceChart({
    super.key,
    required this.data,
    required this.title,
    this.type = ChartType.bar,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chartColor = color ?? AppTheme.primaryGreen;
    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);

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
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(
                  type == ChartType.bar
                      ? Icons.bar_chart
                      : Icons.show_chart,
                  color: chartColor,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceXl),

            // Chart
            SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: data.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final normalizedHeight = (item.value / maxValue) * 140;

                  return Expanded(
                    child: FadeInSlideUp(
                      delay: Duration(milliseconds: 50 * index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Value label
                            Text(
                              item.value.toStringAsFixed(0),
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: chartColor,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Bar
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOutCubic,
                              height: normalizedHeight,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    chartColor.withValues(alpha: 0.7),
                                    chartColor,
                                  ],
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(AppTheme.radiusSm),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Label
                            Text(
                              item.label,
                              style: theme.textTheme.labelSmall,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum ChartType { bar, line }

class ChartData {
  final String label;
  final double value;

  ChartData({required this.label, required this.value});
}

/// 🏆 **RANKING LIST** - Leaderboard with positions
class RankingList extends StatelessWidget {
  final List<RankingItem> items;
  final String title;

  const RankingList({
    super.key,
    required this.items,
    required this.title,
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
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Icon(
                  Icons.emoji_events,
                  color: AppTheme.accentOrange,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceLg),

            // Rankings
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final position = index + 1;

              return FadeInSlideUp(
                delay: Duration(milliseconds: 80 * index),
                child: _RankingListItem(
                  position: position,
                  item: item,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _RankingListItem extends StatelessWidget {
  final int position;
  final RankingItem item;

  const _RankingListItem({
    required this.position,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTopThree = position <= 3;
    final medalColor = position == 1
        ? const Color(0xFFFFD700) // Gold
        : position == 2
            ? const Color(0xFFC0C0C0) // Silver
            : const Color(0xFFCD7F32); // Bronze

    return AnimatedScaleTap(
      onTap: item.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spaceSm),
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: isTopThree
              ? medalColor.withValues(alpha: 0.08)
              : AppTheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: isTopThree
              ? Border.all(color: medalColor.withValues(alpha: 0.3), width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            // Position badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isTopThree
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [medalColor, medalColor.withValues(alpha: 0.7)],
                      )
                    : null,
                color: isTopThree ? null : AppTheme.textTertiary.withValues(alpha: 0.2),
              ),
              child: Center(
                child: isTopThree
                    ? const Icon(Icons.emoji_events, color: Colors.white, size: 20)
                    : Text(
                        '$position',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Score/Value
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceMd,
                vertical: AppTheme.spaceSm,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Text(
                item.value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RankingItem {
  final String name;
  final String? subtitle;
  final String value;
  final VoidCallback? onTap;

  RankingItem({
    required this.name,
    this.subtitle,
    required this.value,
    this.onTap,
  });
}

/// ⚡ **QUICK STATS GRID** - Grid of stat cards
class QuickStatsGrid extends StatelessWidget {
  final List<QuickStat> stats;

  const QuickStatsGrid({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppTheme.spaceMd,
        mainAxisSpacing: AppTheme.spaceMd,
        childAspectRatio: 1.4,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        return FadeInSlideUp(
          delay: Duration(milliseconds: 80 * index),
          child: _QuickStatCard(stat: stats[index]),
        );
      },
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final QuickStat stat;

  const _QuickStatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedScaleTap(
      onTap: stat.onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              stat.color.withValues(alpha: 0.08),
              stat.color.withValues(alpha: 0.12),
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(color: stat.color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceSm),
              decoration: BoxDecoration(
                color: stat.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Icon(
                stat.icon,
                color: stat.color,
                size: 24,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: stat.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QuickStat {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  QuickStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });
}
