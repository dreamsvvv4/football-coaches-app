import 'dart:async';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';
import 'auth_service.dart';

/// Mixin to enable notification triggering in services
mixin NotificationMixin {
  NotificationService get notificationService => NotificationService.instance;
  AuthService get authService => AuthService.instance;

  /// Trigger a match event notification
  Future<void> notifyMatchEvent({
    required String matchId,
    required String type, // 'goal', 'yellow_card', 'red_card', 'substitution', etc.
    required String title,
    required String body,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // In MVP, we mock this. In production, backend would send via FCM
      // Mock notification for testing
      _logNotificationEvent('match', matchId, type);

      // In real scenario, this would be received from Firebase
      // For MVP, we simulate local notification
      if (kDebugMode) {
        print('Match notification triggered: $title - $body');
      }
    } catch (e) {
      print('Error triggering match notification: $e');
    }
  }

  /// Trigger a tournament event notification
  Future<void> notifyTournamentEvent({
    required String tournamentId,
    required String type, // 'standings_updated', 'phase_advanced', 'match_scheduled'
    required String title,
    required String body,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      _logNotificationEvent('tournament', tournamentId, type);
      if (kDebugMode) {
        print('Tournament notification triggered: $title - $body');
      }
    } catch (e) {
      print('Error triggering tournament notification: $e');
    }
  }

  /// Trigger a friendly match event notification
  Future<void> notifyFriendlyEvent({
    required String friendlyId,
    required String type, // 'proposed', 'accepted', 'declined', 'started'
    required String title,
    required String body,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      _logNotificationEvent('friendly', friendlyId, type);
      if (kDebugMode) {
        print('Friendly match notification triggered: $title - $body');
      }
    } catch (e) {
      print('Error triggering friendly notification: $e');
    }
  }

  /// Trigger a system notification
  Future<void> notifySystem({
    required String title,
    required String body,
    String? actionUrl,
  }) async {
    try {
      _logNotificationEvent('system', 'system', 'system_alert');
      if (kDebugMode) {
        print('System notification triggered: $title - $body');
      }
    } catch (e) {
      print('Error triggering system notification: $e');
    }
  }

  /// Trigger club event notification
  Future<void> notifyClubEvent({
    required String clubId,
    required String type, // 'team_updated', 'player_added', 'tournament_joined'
    required String title,
    required String body,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      _logNotificationEvent('club', clubId, type);
      if (kDebugMode) {
        print('Club notification triggered: $title - $body');
      }
    } catch (e) {
      print('Error triggering club notification: $e');
    }
  }

  /// Trigger multiple notifications in sequence (useful for batch events)
  Future<void> notifyBatch(List<Map<String, dynamic>> notifications) async {
    try {
      for (final notification in notifications) {
        final type = notification['type'] as String? ?? 'system';
        final title = notification['title'] as String? ?? 'Update';
        final body = notification['body'] as String? ?? '';

        switch (type) {
          case 'match':
            await notifyMatchEvent(
              matchId: notification['entityId'] as String,
              type: notification['eventType'] as String? ?? 'update',
              title: title,
              body: body,
              additionalData: notification['data'] as Map<String, dynamic>?,
            );
            break;
          case 'tournament':
            await notifyTournamentEvent(
              tournamentId: notification['entityId'] as String,
              type: notification['eventType'] as String? ?? 'update',
              title: title,
              body: body,
              additionalData: notification['data'] as Map<String, dynamic>?,
            );
            break;
          case 'friendly':
            await notifyFriendlyEvent(
              friendlyId: notification['entityId'] as String,
              type: notification['eventType'] as String? ?? 'update',
              title: title,
              body: body,
              additionalData: notification['data'] as Map<String, dynamic>?,
            );
            break;
          default:
            await notifySystem(
              title: title,
              body: body,
            );
        }

        // Stagger notifications slightly
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      print('Error triggering batch notifications: $e');
    }
  }

  /// Check if user should receive notifications
  bool shouldNotifyUser() {
    final user = authService.currentUser;
    return user != null;
  }

  /// Check if user has permission to trigger notifications (admin/coach only)
  bool canTriggerNotifications() {
    final user = authService.currentUser;
    if (user == null) return false;

    final roleStr = user.role is String
        ? (user.role as String)
        : user.role.toString().split('.').last;
    final roleLower = roleStr.toLowerCase();
    return ['coach', 'superadmin', 'clubadmin'].contains(roleLower);
  }

  /// Log notification event (for analytics/debugging)
  void _logNotificationEvent(String entityType, String entityId, String eventType) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      print('[$timestamp] Notification: $entityType($entityId) - $eventType');
    }
  }

  /// Simulate FCM event reception (for MVP testing)
  /// This allows testing notification flow without actual FCM
  Future<void> simulateFCMEvent({
    required String title,
    required String body,
    required String type, // 'match', 'tournament', 'friendly', 'system'
    required String entityId,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notification = PushNotification(
        title: title,
        body: body,
        data: data ?? {},
        timestamp: DateTime.now(),
        type: type,
        entityId: entityId,
      );

      // In a real scenario, Firebase would deliver this
      // For MVP, we simulate it locally
      if (kDebugMode) {
        print('Simulating FCM event: ${notification.title}');
      }

      // Add to notifications (simulating delivery)
      // Note: In real implementation, this comes from Firebase handlers
    } catch (e) {
      print('Error simulating FCM event: $e');
    }
  }
}

/// Extension to add notification capabilities to any service
extension NotificationCapability on Object {
  NotificationService get notificationService => NotificationService.instance;
}
