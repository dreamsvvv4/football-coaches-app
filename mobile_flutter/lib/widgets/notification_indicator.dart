import 'package:flutter/material.dart';
import '../services/notification_service.dart';

/// Material 3 styled notification indicator widget
/// Shows badge with unread notification count
class NotificationIndicator extends StatefulWidget {
  final VoidCallback? onPressed;
  final EdgeInsets padding;

  const NotificationIndicator({
    super.key,
    this.onPressed,
    this.padding = const EdgeInsets.all(8.0),
  });

  @override
  State<NotificationIndicator> createState() => _NotificationIndicatorState();
}

class _NotificationIndicatorState extends State<NotificationIndicator> {
  late NotificationService _notificationService;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService.instance;

    // Listen to notification stream
    _notificationService.notificationStream.listen((notification) {
      setState(() {
        _unreadCount++;
      });
    });

    // Initial count
    _unreadCount = _notificationService.getNotificationCount();
  }

  void _clearNotifications() {
    setState(() {
      _unreadCount = 0;
    });
    _notificationService.clearAllNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Stack(
        children: [
          // Bell icon button
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              _clearNotifications();
              widget.onPressed?.call();
            },
            tooltip: 'Notifications',
          ),
          // Badge with count
          if (_unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Badge(
                label: Text(
                  _unreadCount > 99 ? '99+' : '$_unreadCount',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
        ],
      ),
    );
  }
}

/// Bottom sheet to display recent notifications
class NotificationBottomSheet extends StatefulWidget {
  const NotificationBottomSheet({super.key});

  @override
  State<NotificationBottomSheet> createState() => _NotificationBottomSheetState();
}

class _NotificationBottomSheetState extends State<NotificationBottomSheet> {
  late NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService.instance;
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _notificationService.getRecentNotifications(limit: 20);

    return Material(
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (notifications.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _notificationService.clearAllNotifications();
                        });
                      },
                      child: const Text('Clear All'),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Notifications list
            if (notifications.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 48,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _NotificationTile(notification: notification);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Individual notification tile
class _NotificationTile extends StatelessWidget {
  final PushNotification notification;

  const _NotificationTile({required this.notification});

  Color _getColorByType(String type) {
    switch (type) {
      case 'match':
        return const Color(0xFF0E7C61); // Primary green
      case 'tournament':
        return const Color(0xFF0066CC); // Blue
      case 'friendly':
        return const Color(0xFFFF6B00); // Orange
      default:
        return const Color(0xFF666666); // Gray
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to entity
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Color accent
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getColorByType(notification.type),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(notification.timestamp),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Type badge
                Chip(
                  label: Text(notification.type.toUpperCase()),
                  backgroundColor: _getColorByType(notification.type).withAlpha(25),
                  labelStyle: TextStyle(
                    color: _getColorByType(notification.type),
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
