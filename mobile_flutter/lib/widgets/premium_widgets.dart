import 'package:flutter/material.dart';
// shimmer is only needed in screens; remove here to avoid unused import warnings
import '../theme/app_theme.dart';
import 'animations.dart';

/// 🎮 **PREMIUM INTERACTIVE WIDGETS**
/// High-quality microinteractions for sports app

/// 📊 **STAT CARD** - Animated stat display
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedScaleTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.15),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
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
}

/// 🏆 **MATCH CARD** - Premium match display with score
class MatchCard extends StatelessWidget {
  final String homeTeam;
  final String awayTeam;
  final String? homeScore;
  final String? awayScore;
  final String status;
  final DateTime dateTime;
  final VoidCallback? onTap;
  final Color? statusColor;

  const MatchCard({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    this.homeScore,
    this.awayScore,
    required this.status,
    required this.dateTime,
    this.onTap,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLive = status.toLowerCase() == 'live';
    final color = statusColor ?? (isLive ? AppTheme.error : AppTheme.textSecondary);

    return AnimatedScaleTap(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          children: [
            // Status bar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceLg,
                vertical: AppTheme.spaceSm,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusXl),
                ),
              ),
              child: Row(
                children: [
                  if (isLive)
                    PulseAnimation(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.error,
                        ),
                      ),
                    ),
                  if (isLive) const SizedBox(width: AppTheme.spaceSm),
                  Text(
                    status.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDateTime(dateTime),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Match content
            Padding(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              child: Row(
                children: [
                  // Home team
                  Expanded(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                          child: Text(
                            homeTeam.substring(0, 1).toUpperCase(),
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceSm),
                        Text(
                          homeTeam,
                          style: theme.textTheme.titleSmall,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Score
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spaceLg,
                      vertical: AppTheme.spaceSm,
                    ),
                    child: Row(
                      children: [
                        Text(
                          homeScore ?? '-',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: homeScore != null
                                ? AppTheme.textPrimary
                                : AppTheme.textTertiary,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spaceMd),
                        Text(
                          ':',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: AppTheme.textTertiary,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spaceMd),
                        Text(
                          awayScore ?? '-',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: awayScore != null
                                ? AppTheme.textPrimary
                                : AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Away team
                  Expanded(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.accentBlue.withValues(alpha: 0.1),
                          child: Text(
                            awayTeam.substring(0, 1).toUpperCase(),
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: AppTheme.accentBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceSm),
                        Text(
                          awayTeam,
                          style: theme.textTheme.titleSmall,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    
    if (diff.inDays == 0) return 'Hoy ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    if (diff.inDays == 1) return 'Ayer';
    return '${dt.day}/${dt.month}';
  }
}

/// 🎯 **ACTION BUTTON** - Premium CTA button
class ActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isLoading;
  final bool isFullWidth;
  // Accessibility/UX polish
  final String? semanticsLabel;
  final double? height; // allow smaller buttons on compact screens

  const ActionButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.isLoading = false,
    this.isFullWidth = false,
    this.semanticsLabel,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppTheme.primaryGreen;
    final fgColor = foregroundColor ?? Colors.white;

    Widget button = _HoverFocusButton(
      bgColor: bgColor,
      fgColor: fgColor,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      icon: icon,
      label: label,
      onPressed: onPressed,
      semanticsLabel: semanticsLabel,
      height: height,
    );

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}

/// Internal: adds hover elevation and focus outline to ActionButton
class _HoverFocusButton extends StatefulWidget {
  final Color bgColor;
  final Color fgColor;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final String label;
  final VoidCallback? onPressed;
  final String? semanticsLabel;
  final double? height;

  const _HoverFocusButton({
    required this.bgColor,
    required this.fgColor,
    required this.isLoading,
    required this.isFullWidth,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.semanticsLabel,
    this.height,
  });

  @override
  State<_HoverFocusButton> createState() => _HoverFocusButtonState();
}

class _HoverFocusButtonState extends State<_HoverFocusButton> {
  bool _hovering = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final baseShadow = AppTheme.shadowMd;
    final hoverShadow = [
      const BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 6)),
    ];

    final outlineColor = AppTheme.primaryGreen;

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      height: widget.height ?? 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [widget.bgColor, widget.bgColor.withValues(alpha: 0.85)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: _hovering ? hoverShadow : baseShadow,
        border: _focused ? Border.all(color: outlineColor, width: 2) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXl),
            child: Row(
              mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(widget.fgColor),
                    ),
                  )
                else if (widget.icon != null)
                  Icon(widget.icon, color: widget.fgColor, size: 20),
                if ((widget.icon != null || widget.isLoading) && widget.label.isNotEmpty)
                  const SizedBox(width: AppTheme.spaceSm),
                if (widget.label.isNotEmpty)
                  Text(
                    widget.label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: widget.fgColor,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    return FocusableActionDetector(
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        cursor: SystemMouseCursors.click,
        child: Semantics(
          button: true,
          label: widget.semanticsLabel ?? widget.label,
          child: widget.isFullWidth ? SizedBox(width: double.infinity, child: content) : content,
        ),
      ),
    );
  }
}

/// 🏅 **BADGE WIDGET** - Gamification badge
class AchievementBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isUnlocked;

  const AchievementBadge({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.isUnlocked = true,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (isUnlocked)
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isUnlocked
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [color, color.withValues(alpha: 0.7)],
                      )
                    : null,
                color: isUnlocked ? null : AppTheme.textTertiary.withValues(alpha: 0.2),
                border: Border.all(
                  color: isUnlocked ? color : AppTheme.textTertiary,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: isUnlocked ? Colors.white : AppTheme.textTertiary,
                size: 28,
              ),
            ),
            if (!isUnlocked)
              const Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: AppTheme.textTertiary,
                  child: Icon(Icons.lock, size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isUnlocked ? AppTheme.textPrimary : AppTheme.textTertiary,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ShimmerKpi removed; use inline Shimmer.fromColors where needed

/// 📈 **PROGRESS BAR** - Animated progress indicator
class AnimatedProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final Color? color;
  final double height;
  final String? label;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.color,
    this.height = 8,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final barColor = color ?? AppTheme.primaryGreen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label!,
                style: theme.textTheme.labelSmall,
              ),
              Text(
                '${(value * 100).toInt()}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                // Background
                Container(
                  color: barColor.withValues(alpha: 0.15),
                ),
                
                // Progress
                FractionallySizedBox(
                  widthFactor: value.clamp(0.0, 1.0),
                  child: AnimatedContainer(
                    duration: AppAnimations.medium,
                    curve: AppAnimations.smooth,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [barColor, barColor.withValues(alpha: 0.8)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 🔔 **NOTIFICATION TOAST** - Custom in-app notification
class NotificationToast {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    Color? color,
    Duration duration = const Duration(seconds: 3),
  }) {
    final notificationColor = color ?? AppTheme.primaryGreen;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppTheme.spaceLg),
        content: FadeInSlideUp(
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [notificationColor, notificationColor.withValues(alpha: 0.85)],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: AppTheme.shadowLg,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: AppTheme.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ⚡ **QUICK ACTION FAB** - Contextual floating action button
class QuickActionFab extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const QuickActionFab({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? AppTheme.primaryGreen;

    return AnimatedScaleTap(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceLg,
          vertical: AppTheme.spaceMd,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgColor, bgColor.withValues(alpha: 0.85)],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radius2xl),
          boxShadow: AppTheme.shadowLg,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: AppTheme.spaceSm),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
