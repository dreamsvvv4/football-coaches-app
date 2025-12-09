import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 📦 **SHIMMER LOADING WIDGETS**
/// Premium loading placeholders for content

class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? AppTheme.darkSurfaceVariant
        : const Color(0xFFE0E0E0);
    final highlightColor = isDark
        ? AppTheme.darkSurface
        : const Color(0xFFF5F5F5);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(AppTheme.radiusMd),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ShimmerMatchCard extends StatelessWidget {
  const ShimmerMatchCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const ShimmerBox(width: 60, height: 12),
              const Spacer(),
              ShimmerBox(
                width: 80,
                height: 12,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceLg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  ShimmerBox(
                    width: 48,
                    height: 48,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  const ShimmerBox(width: 60, height: 12),
                ],
              ),
              const Column(
                children: [
                  ShimmerBox(width: 40, height: 32),
                  SizedBox(height: AppTheme.spaceSm),
                  ShimmerBox(width: 20, height: 12),
                ],
              ),
              Column(
                children: [
                  ShimmerBox(
                    width: 48,
                    height: 48,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  const ShimmerBox(width: 60, height: 12),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ShimmerListTile extends StatelessWidget {
  const ShimmerListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
      child: Row(
        children: [
          ShimmerBox(
            width: 56,
            height: 56,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          const SizedBox(width: AppTheme.spaceMd),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: double.infinity, height: 16),
                SizedBox(height: AppTheme.spaceSm),
                ShimmerBox(width: 120, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 🗑️ **SWIPE TO DISMISS** - Swipe actions on list items
class SwipeToDismiss extends StatelessWidget {
  final Widget child;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onArchive;
  final String confirmDeleteMessage;

  const SwipeToDismiss({
    super.key,
    required this.child,
    this.onDelete,
    this.onEdit,
    this.onArchive,
    this.confirmDeleteMessage = '¿Eliminar este elemento?',
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: _getDirection(),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart && onDelete != null) {
          return await _showDeleteDialog(context);
        }
        if (direction == DismissDirection.startToEnd && onEdit != null) {
          onEdit!();
          return false;
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart && onDelete != null) {
          onDelete!();
        }
      },
      background: _buildSwipeBackground(
        alignment: Alignment.centerLeft,
        color: AppTheme.info,
        icon: Icons.edit,
        label: 'Editar',
      ),
      secondaryBackground: _buildSwipeBackground(
        alignment: Alignment.centerRight,
        color: AppTheme.error,
        icon: Icons.delete,
        label: 'Eliminar',
      ),
      child: child,
    );
  }

  DismissDirection _getDirection() {
    if (onEdit != null && onDelete != null) {
      return DismissDirection.horizontal;
    } else if (onEdit != null) {
      return DismissDirection.startToEnd;
    } else if (onDelete != null) {
      return DismissDirection.endToStart;
    }
    return DismissDirection.none;
  }

  Widget _buildSwipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXl),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: Text(confirmDeleteMessage),
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
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

/// 🎯 **EMPTY STATE** - Beautiful empty state placeholder
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space2xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          AppTheme.darkSurfaceVariant,
                          AppTheme.darkSurface,
                        ]
                      : [
                          AppTheme.primaryGreen.withValues(alpha: 0.1),
                          AppTheme.secondaryTeal.withValues(alpha: 0.1),
                        ],
                ),
              ),
              child: Icon(
                icon,
                size: 56,
                color: isDark
                    ? AppTheme.darkTextSecondary
                    : AppTheme.primaryGreen.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppTheme.spaceXl),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppTheme.spaceXl),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 🔄 **PULL TO REFRESH** - Premium refresh indicator
class PremiumRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;

  const PremiumRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? AppTheme.primaryGreen,
      backgroundColor: Colors.white,
      strokeWidth: 3,
      displacement: 60,
      child: child,
    );
  }
}

/// ⭐ **RATING STARS** - Interactive rating display
class RatingStars extends StatelessWidget {
  final double rating; // 0.0 to 5.0
  final double size;
  final Color? color;
  final bool interactive;
  final ValueChanged<double>? onRatingChanged;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 20,
    this.color,
    this.interactive = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? AppTheme.accentOrange;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final filled = rating >= starValue
            ? 1.0
            : rating > starValue - 1
                ? rating - (starValue - 1)
                : 0.0;

        return GestureDetector(
          onTap: interactive
              ? () => onRatingChanged?.call(starValue.toDouble())
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Stack(
              children: [
                Icon(
                  Icons.star_border,
                  size: size,
                  color: starColor.withValues(alpha: 0.3),
                ),
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: filled,
                    child: Icon(
                      Icons.star,
                      size: size,
                      color: starColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

/// 📊 **MINI CHART** - Simple bar chart widget
class MiniBarChart extends StatelessWidget {
  final List<double> values;
  final List<String>? labels;
  final double height;
  final Color? color;

  const MiniBarChart({
    super.key,
    required this.values,
    this.labels,
    this.height = 100,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = color ?? AppTheme.primaryGreen;
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(values.length, (index) {
          final normalizedHeight = (values[index] / maxValue) * height;
          
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: normalizedHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          barColor.withValues(alpha: 0.7),
                          barColor,
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppTheme.radiusSm),
                      ),
                    ),
                  ),
                  if (labels != null && labels!.length > index) ...[
                    const SizedBox(height: 4),
                    Text(
                      labels![index],
                      style: Theme.of(context).textTheme.labelSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// 🎨 **GRADIENT CONTAINER** - Premium gradient backgrounds
class GradientContainer extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const GradientContainer({
    super.key,
    required this.child,
    required this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors,
        ),
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}
