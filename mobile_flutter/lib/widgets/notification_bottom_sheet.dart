import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'animations.dart';

class NotificationBottomSheet extends StatelessWidget {
  const NotificationBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GradientContainer(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.scaffoldBackgroundColor,
          theme.scaffoldBackgroundColor.withValues(alpha: 0.98),
        ],
      ),
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppTheme.radius2xl),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppTheme.spaceLg),
                  decoration: BoxDecoration(
                    color: AppTheme.textTertiary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                ),
              ),

              // Header
              FadeInSlideUp(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notificaciones',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Mark all as read
                      },
                      child: const Text('Marcar todas leídas'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spaceLg),

              // Mock notifications
              ..._getMockNotifications().map((notification) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
                  child: FadeInSlideUp(
                    delay: Duration(milliseconds: 100 * _getMockNotifications().indexOf(notification)),
                    child: _NotificationCard(notification: notification),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  List<_NotificationData> _getMockNotifications() {
    return [
      _NotificationData(
        title: 'Partido confirmado',
        message: 'Tu partido contra Real Madrid fue confirmado para mañana a las 18:00',
        icon: Icons.check_circle,
        color: AppTheme.success,
        time: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
      _NotificationData(
        title: 'Nuevo jugador añadido',
        message: 'Juan Pérez fue añadido a tu equipo',
        icon: Icons.person_add,
        color: AppTheme.info,
        time: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      _NotificationData(
        title: 'Recordatorio',
        message: 'Tienes un entrenamiento programado para hoy a las 16:00',
        icon: Icons.notifications,
        color: AppTheme.warning,
        time: DateTime.now().subtract(const Duration(hours: 4)),
        isRead: true,
      ),
    ];
  }
}

class _NotificationCard extends StatelessWidget {
  final _NotificationData notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedScaleTap(
      onTap: () {
        // Handle tap
      },
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        decoration: BoxDecoration(
          color: notification.isRead
              ? theme.cardColor
              : notification.color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: notification.isRead
                ? Colors.transparent
                : notification.color.withValues(alpha: 0.2),
          ),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: notification.color.withValues(alpha: 0.1),
              ),
              child: Icon(
                notification.icon,
                color: notification.color,
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: notification.color,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  Text(
                    notification.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  Text(
                    _formatTime(notification.time),
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

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    return 'Hace ${diff.inDays}d';
  }
}

class _NotificationData {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final DateTime time;
  final bool isRead;

  const _NotificationData({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.time,
    required this.isRead,
  });
}

class GradientContainer extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final BorderRadius? borderRadius;

  const GradientContainer({
    super.key,
    required this.child,
    required this.gradient,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}
