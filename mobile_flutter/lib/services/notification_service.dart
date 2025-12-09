import '../models/club_event.dart';
import 'dart:async';
import 'dart:convert' show jsonEncode, jsonDecode;
import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

/// Represents a received notification
class PushNotification {
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String type; // 'match', 'friendly', 'system' (tournament hidden)
  final String? entityId; // matchId, friendlyId, etc. (tournamentId hidden)
  final bool isAnnouncement;
  bool isRead;

  PushNotification({
    required this.title,
    required this.body,
    this.imageUrl,
    required this.data,
    required this.timestamp,
    required this.type,
    this.entityId,
    this.isAnnouncement = false,
    this.isRead = false,
  });

  factory PushNotification.fromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    final notification = message.notification;

    return PushNotification(
      title: notification?.title ?? 'Notificación',
      body: notification?.body ?? '',
      imageUrl: notification?.android?.imageUrl ?? notification?.apple?.imageUrl,
      data: data,
      timestamp: DateTime.now(),
      type: data['type'] ?? 'system',
      entityId: data['entityId'],
      isAnnouncement: (data['type'] ?? '') == 'announcement',
      isRead: false,
    );
  }
}

/// Notification subscription configuration
class NotificationSubscription {
  final String topic;
  final String entityId;
  final String entityType; // 'match', 'friendly' (tournament hidden)
  final DateTime subscribedAt;

  NotificationSubscription({
    required this.topic,
    required this.entityId,
    required this.entityType,
    DateTime? subscribedAt,
  }) : subscribedAt = subscribedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'topic': topic,
    'entityId': entityId,
    'entityType': entityType,
    'subscribedAt': subscribedAt.toIso8601String(),
  };

  factory NotificationSubscription.fromJson(Map<String, dynamic> json) {
    return NotificationSubscription(
      topic: json['topic'] as String,
      entityId: json['entityId'] as String,
      entityType: json['entityType'] as String,
      subscribedAt: DateTime.parse(json['subscribedAt'] as String),
    );
  }
}

/// Main notification service for managing Firebase Cloud Messaging
class NotificationService {
    /// Envía notificación de convocatoria a jugadores o padres
    void sendConvocatoriaNotification(
      String matchId,
      List<String> playerNames, {
      String? location,
      String? uniform,
      String? notes,
      String? arrival,
    }) {
      final title = 'Convocatoria para partido';
      final body = 'Has sido convocado para el partido $matchId.' +
        (location != null ? '\nUbicación: $location' : '') +
        (uniform != null ? '\nUniforme: $uniform' : '') +
        (notes != null ? '\nNotas: $notes' : '') +
        (arrival != null ? '\nLlegar: $arrival antes' : '');
      for (final name in playerNames) {
        // En real: buscar userId/padre y enviar por FCM
        _showLocal(title: title, body: '$body\nJugador: $name');
      }
    }
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  static NotificationService get instance => _instance;

  late FirebaseMessaging _firebaseMessaging;
  late FlutterLocalNotificationsPlugin _localNotifications;
  late SharedPreferences _preferences;

  // State management
  String? _fcmToken;
  bool _isInitialized = false;
  final Set<String> _subscribedTopics = {};
  final List<PushNotification> _notifications = [];

  // Streams
  final _notificationStreamController = StreamController<PushNotification>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();

  // Getters
  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;
  bool get isConnected => _isInitialized;
  Stream<PushNotification> get notificationStream => _notificationStreamController.stream;
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;
  List<PushNotification> get notifications => List.unmodifiable(_notifications);
  int get unseenAnnouncementsCount => _notifications.where((n) => n.isAnnouncement && !n.isRead).length;
    // Store notification in inbox (read/unread)
    Future<void> storeNotification(PushNotification n) async {
      _notifications.add(n);
      if (_notifications.length > 200) {
        _notifications.removeAt(0);
      }
      _notificationStreamController.add(n);
      await _persistInbox();
    }

    Future<void> markEventSeen(String eventId) async {
      for (final n in _notifications) {
        if (n.data['eventId'] == eventId) {
          n.data['seen'] = 'true';
        }
      }
      await _persistInbox();
    }

    int unreadCountByType(String type) {
      return _notifications.where((n) => n.type == type && (n.data['seen'] != 'true')).length;
    }

    Future<void> _persistInbox() async {
      try {
        final list = _notifications.map((n) => {
          'title': n.title,
          'body': n.body,
          'imageUrl': n.imageUrl,
          'data': n.data,
          'timestamp': n.timestamp.toIso8601String(),
          'type': n.type,
          'entityId': n.entityId,
          'isAnnouncement': n.isAnnouncement,
          'isRead': n.isRead,
        }).toList();
        await _preferences.setString('inbox', jsonEncode(list));
      } catch (_) {}
    }

    Future<void> _loadPersistedInbox() async {
      try {
        final raw = _preferences.getString('inbox');
        if (raw == null) return;
        final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
        _notifications.clear();
        for (final m in list) {
          _notifications.add(PushNotification(
            title: m['title'] as String,
            body: m['body'] as String,
            imageUrl: m['imageUrl'] as String?,
            data: (m['data'] as Map).cast<String, dynamic>(),
            timestamp: DateTime.parse(m['timestamp'] as String),
            type: m['type'] as String,
            entityId: m['entityId'] as String?,
            isAnnouncement: (m['isAnnouncement'] as bool?) ?? false,
            isRead: (m['isRead'] as bool?) ?? false,
          ));
        }
      } catch (_) {}
    }
  Set<String> get subscribedTopics => Set.unmodifiable(_subscribedTopics);

  // Simple stubs for club events pipeline (server-side typically handles dispatch)
  void registerDeviceToken(String userId, String token) {
    // In a full impl, associate token with user in backend.
    print('Register token for $userId: $token');
  }

  void sendEventCreatedNotification(ClubEvent event, List<String> userIds) {
    _emitLocalHeadsUp('Nuevo evento', event, userIds);
  }

  void sendEventUpdatedNotification(ClubEvent event, List<String> userIds) {
    _emitLocalHeadsUp('Evento actualizado', event, userIds);
  }

  void sendEventCancelledNotification(ClubEvent event, List<String> userIds) {
    _emitLocalHeadsUp('Evento cancelado', event, userIds);
  }

  Future<void> _emitLocalHeadsUp(String prefix, ClubEvent event, List<String> userIds) async {
    final title = '$prefix: ${event.title}';
    final startLabel = '${event.start.hour.toString().padLeft(2,'0')}:${event.start.minute.toString().padLeft(2,'0')}';
    final body = '${event.teamId ?? 'Club'} • $startLabel';
    // Build payload with non-null values
    final Map<String, String> payload = {'eventId': event.id};
    if (event.teamId != null) {
      payload['teamId'] = event.teamId!;
    }
    // Show local notification for current device only
    await _showLocal(title: title, body: body, payload: payload);
    // In a full app, backend sends to userIds via FCM.
  }

  Future<void> _showLocal({required String title, required String body, Map<String, String>? payload}) async {
    if (kIsWeb) return; // skip on web
    const details = NotificationDetails(
      android: AndroidNotificationDetails('club_events', 'Club Events', importance: Importance.high, priority: Priority.high),
      iOS: DarwinNotificationDetails(),
    );
    await _localNotifications.show(DateTime.now().millisecondsSinceEpoch % 100000, title, body, details, payload: payload == null ? null : jsonEncode(payload));
  }

  /// Initialize the notification service
  /// Call this during app startup
  Future<void> init({bool requestPermission = true}) async {
    if (_isInitialized) return;

    try {
      // Initialize local notifications
      _localNotifications = FlutterLocalNotificationsPlugin();
      await _initLocalNotifications();

      // Get Firebase Messaging instance
      _firebaseMessaging = FirebaseMessaging.instance;

      // Request permissions (iOS specific)
      if (requestPermission && !kIsWeb && Platform.isIOS) {
        final notificationSettings = await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
          criticalAlert: false,
          announcement: false,
        );

        if (notificationSettings.authorizationStatus != AuthorizationStatus.authorized) {
          print('User denied notification permissions');
        }
      } else if (requestPermission && !kIsWeb && Platform.isAndroid) {
        // Android 13+ requires runtime permission
        // Handle via permission_service
      }

      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      print('FCM Token: $_fcmToken');

      // Set up message handlers
      _setupMessageHandlers();

      // Load persisted subscriptions
      await _loadPersistedSubscriptions();
      await _loadPersistedInbox();

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _handleTokenRefresh(newToken);
      });

      _isInitialized = true;
      _connectionStatusController.add(true);
      print('NotificationService initialized successfully');
    } catch (e) {
      print('Error initializing NotificationService: $e');
      _connectionStatusController.add(false);
      // Don't rethrow on web, just log the error
      if (!kIsWeb) {
        rethrow;
      }
    }
  }

  /// Initialize local notifications
  Future<void> _initLocalNotifications() async {
    // Skip local notifications on web
    if (kIsWeb) {
      print('Skipping local notifications on web platform');
      return;
    }
    
    const androidSettings = AndroidInitializationSettings('app_icon');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleLocalNotificationTap,
    );
  }

  /// Set up Firebase message handlers for different app states
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });

    // Handle background message tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessageOpenedApp(message);
    });

    // Handle terminated state message tap
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleMessageOpenedApp(message);
      }
    });
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = PushNotification.fromRemoteMessage(message);

    // Check RBAC before displaying
    if (!_shouldReceiveNotification(notification)) {
      print('User does not have permission to receive this notification');
      return;
    }

    // Add to list
    _notifications.add(notification);
    if (_notifications.length > 100) {
      _notifications.removeAt(0); // Keep only last 100 notifications
    }

    // Emit to stream
    _notificationStreamController.add(notification);

    // Show local notification
    _showLocalNotification(notification);
  }

  /// Handle message tap (both background and terminated)
  void _handleMessageOpenedApp(RemoteMessage message) {
    final notification = PushNotification.fromRemoteMessage(message);

    // Navigate based on type
    _handleNotificationNavigation(notification);
  }

  /// Handle local notification tap
  void _handleLocalNotificationTap(NotificationResponse response) {
    // Parse payload if needed
    if (response.payload != null && response.payload!.isNotEmpty) {
      // Handle navigation
    }
  }

  /// Show local notification (Material 3 styled)
  Future<void> _showLocalNotification(PushNotification notification) async {
    const androidDetails = AndroidNotificationDetails(
      'football_coaches_channel',
      'Football Coaches Notifications',
      channelDescription: 'Notifications for matches and friendlies',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      enableLights: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      threadIdentifier: 'football_coaches_notifications',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      notificationDetails,
      payload: notification.entityId,
    );
  }

  /// Subscribe to match notifications
  /// Topic: matches_{matchId}
  Future<void> subscribeToMatch(String matchId) async {
    final topic = 'matches_$matchId';
    await _subscribeToTopic(
      topic: topic,
      entityId: matchId,
      entityType: 'match',
    );
  }

  /// Unsubscribe from match notifications
  Future<void> unsubscribeFromMatch(String matchId) async {
    final topic = 'matches_$matchId';
    await _unsubscribeFromTopic(topic);
  }

  /// Subscribe to tournament notifications
  /// Topic: tournaments_{tournamentId}
  Future<void> subscribeToTournament(String tournamentId) async {
    final topic = 'tournaments_$tournamentId';
    await _subscribeToTopic(
      topic: topic,
      entityId: tournamentId,
      entityType: 'tournament',
    );
  }

  // Tournament notification methods hidden by feature flag
  Future<void> unsubscribeFromFriendly(String friendlyId) async {
    final topic = 'friendlies_$friendlyId';
    await _unsubscribeFromTopic(topic);
  }

  /// Subscribe to club notifications
  /// Topic: clubs_{clubId}
  Future<void> subscribeToClub(String clubId) async {
    final topic = 'clubs_$clubId';
    await _subscribeToTopic(
      topic: topic,
      entityId: clubId,
      entityType: 'club',
    );
  }

  /// Unsubscribe from club notifications
  Future<void> unsubscribeFromClub(String clubId) async {
    final topic = 'clubs_$clubId';
    await _unsubscribeFromTopic(topic);
  }

  /// Internal topic subscription
  Future<void> _subscribeToTopic({
    required String topic,
    required String entityId,
    required String entityType,
  }) async {
    try {
      if (_subscribedTopics.contains(topic)) {
        print('Already subscribed to $topic');
        return;
      }

      await _firebaseMessaging.subscribeToTopic(topic);
      _subscribedTopics.add(topic);

      // Persist subscription
      final subscription = NotificationSubscription(
        topic: topic,
        entityId: entityId,
        entityType: entityType,
      );
      await _persistSubscription(subscription);

      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic $topic: $e');
      rethrow;
    }
  }

  /// Internal topic unsubscription
  Future<void> _unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      _subscribedTopics.remove(topic);

      // Remove persisted subscription
      await _removePersistedSubscription(topic);

      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic $topic: $e');
      rethrow;
    }
  }

  /// Persist subscription to local storage
  Future<void> _persistSubscription(NotificationSubscription subscription) async {
    final subscriptions = _getPersistedSubscriptions();
    subscriptions.add(subscription);

    final jsonList = subscriptions.map((s) => s.toJson()).toList();
    await _preferences.setString('notification_subscriptions', _encodeJson(jsonList));
  }

  /// Remove persisted subscription
  Future<void> _removePersistedSubscription(String topic) async {
    final subscriptions = _getPersistedSubscriptions();
    subscriptions.removeWhere((s) => s.topic == topic);

    final jsonList = subscriptions.map((s) => s.toJson()).toList();
    await _preferences.setString('notification_subscriptions', _encodeJson(jsonList));
  }

  /// Load persisted subscriptions from local storage
  Future<void> _loadPersistedSubscriptions() async {
    final subscriptions = _getPersistedSubscriptions();
    for (final subscription in subscriptions) {
      try {
        await _firebaseMessaging.subscribeToTopic(subscription.topic);
        _subscribedTopics.add(subscription.topic);
      } catch (e) {
        print('Error resubscribing to ${subscription.topic}: $e');
      }
    }

    print('Resubscribed to ${subscriptions.length} topics');
  }

  /// Get all persisted subscriptions
  List<NotificationSubscription> _getPersistedSubscriptions() {
    final encoded = _preferences.getString('notification_subscriptions');
    if (encoded == null || encoded.isEmpty) return [];

    try {
      final decoded = _decodeJson(encoded);
      return (decoded as List)
          .cast<Map<String, dynamic>>()
          .map((json) => NotificationSubscription.fromJson(json))
          .toList();
    } catch (e) {
      print('Error decoding subscriptions: $e');
      return [];
    }
  }

  /// Handle token refresh
  void _handleTokenRefresh(String newToken) {
    print('FCM Token refreshed: $newToken');
    // TODO: Send new token to backend if needed
  }

  /// Check RBAC: whether user should receive this notification
  bool _shouldReceiveNotification(PushNotification notification) {
    final user = AuthService.instance.currentUser;
    if (user == null) return false;

    // All authenticated users can receive notifications for subscribed topics
    // Additional RBAC checks can be added here based on specific notification types

    // Example: Only coaches can receive match management notifications
    if (notification.type == 'match_management' && user.role != 'coach') {
      return false;
    }

    // All roles can receive updates for entities they're subscribed to
    return true;
  }

  /// Navigate based on notification type
  void _handleNotificationNavigation(PushNotification notification) {
    // This will be integrated with navigation in UI layer
    print('Navigating to ${notification.type}: ${notification.entityId}');
    // Example:
    // if (notification.type == 'match') {
    //   navigatorKey.currentState?.pushNamed('/match', arguments: notification.entityId);
    // }
  }

  /// Clear all notifications
  void clearAllNotifications() {
    _notifications.clear();
    _localNotifications.cancelAll();
  }

  /// Clear specific notification
  void clearNotification(PushNotification notification) {
    _notifications.remove(notification);
    _localNotifications.cancel(notification.hashCode);
  }

  /// Get notification count
  int getNotificationCount() => _notifications.length;

  /// Get recent notifications (limit)
  List<PushNotification> getRecentNotifications({int limit = 10}) {
    return _notifications.reversed.toList().take(limit).toList();
  }

  /// Disconnect and cleanup
  Future<void> disconnect() async {
    try {
      // Unsubscribe from all topics
      for (final topic in _subscribedTopics.toList()) {
        await _firebaseMessaging.unsubscribeFromTopic(topic);
      }
      _subscribedTopics.clear();

      // Cancel local notifications
      await _localNotifications.cancelAll();

      // Close streams
      await _notificationStreamController.close();
      await _connectionStatusController.close();

      _isInitialized = false;
      print('NotificationService disconnected');
    } catch (e) {
      print('Error disconnecting NotificationService: $e');
    }
  }

  /// Utility: JSON encoding (safe)
  static String _encodeJson(dynamic data) {
    try {
      return jsonEncode(data);
    } catch (_) {
      return '[]';
    }
  }

  static dynamic _decodeJson(String data) {
    try {
      return jsonDecode(data);
    } catch (_) {
      return [];
    }
  }
}
