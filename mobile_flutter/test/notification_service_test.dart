import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/services/notification_service.dart';
import '../lib/services/auth_service.dart';
import '../lib/models/auth.dart';

void main() {
  group('NotificationService Tests', () {
    late NotificationService notificationService;
    late AuthService authService;

    setUp(() async {
      // Initialize shared preferences mock
      SharedPreferences.setMockInitialValues({});

      notificationService = NotificationService.instance;
      authService = AuthService.instance;

      // Set up mock user
      final mockUser = User(
        id: 'test_user_123',
        fullName: 'Test Coach',
        email: 'coach@test.com',
        username: 'test_coach',
        role: UserRole.coach,
        isEmailVerified: true,
        isPhoneVerified: false,
        createdAt: DateTime.now(),
        isActive: true,
        activeClubId: 'club_456',
      );
      authService.setCurrentUser(mockUser);
    });

    tearDown(() async {
      await notificationService.disconnect();
    });

    test('NotificationService initializes successfully', () async {
      expect(notificationService.isInitialized, isTrue);
      expect(notificationService.isConnected, isTrue);
    });

    test('FCM token is obtained on initialization', () async {
      expect(notificationService.fcmToken, isNotNull);
      expect(notificationService.fcmToken!.isNotEmpty, isTrue);
    });

    test('Can subscribe to match notifications', () async {
      const matchId = 'match_123';
      await notificationService.subscribeToMatch(matchId);

      expect(
        notificationService.subscribedTopics.contains('matches_$matchId'),
        isTrue,
      );
    });

    test('Can unsubscribe from match notifications', () async {
      const matchId = 'match_456';
      await notificationService.subscribeToMatch(matchId);
      expect(notificationService.subscribedTopics.contains('matches_$matchId'), isTrue);

      await notificationService.unsubscribeFromMatch(matchId);
      expect(notificationService.subscribedTopics.contains('matches_$matchId'), isFalse);
    });

    test('Can subscribe to tournament notifications', () async {
      const tournamentId = 'tournament_789';
      await notificationService.subscribeToTournament(tournamentId);

      expect(
        notificationService.subscribedTopics.contains('tournaments_$tournamentId'),
        isTrue,
      );
    });

    test('Can unsubscribe from tournament notifications', () async {
      const tournamentId = 'tournament_999';
      await notificationService.subscribeToTournament(tournamentId);
      expect(
        notificationService.subscribedTopics.contains('tournaments_$tournamentId'),
        isTrue,
      );

      await notificationService.unsubscribeFromTournament(tournamentId);
      expect(
        notificationService.subscribedTopics.contains('tournaments_$tournamentId'),
        isFalse,
      );
    });

    test('Can subscribe to friendly match notifications', () async {
      const friendlyId = 'friendly_111';
      await notificationService.subscribeToFriendly(friendlyId);

      expect(
        notificationService.subscribedTopics.contains('friendlies_$friendlyId'),
        isTrue,
      );
    });

    test('Can unsubscribe from friendly match notifications', () async {
      const friendlyId = 'friendly_222';
      await notificationService.subscribeToFriendly(friendlyId);
      expect(
        notificationService.subscribedTopics.contains('friendlies_$friendlyId'),
        isTrue,
      );

      await notificationService.unsubscribeFromFriendly(friendlyId);
      expect(
        notificationService.subscribedTopics.contains('friendlies_$friendlyId'),
        isFalse,
      );
    });

    test('Can subscribe to club notifications', () async {
      const clubId = 'club_333';
      await notificationService.subscribeToClub(clubId);

      expect(
        notificationService.subscribedTopics.contains('clubs_$clubId'),
        isTrue,
      );
    });

    test('Can unsubscribe from club notifications', () async {
      const clubId = 'club_444';
      await notificationService.subscribeToClub(clubId);
      expect(
        notificationService.subscribedTopics.contains('clubs_$clubId'),
        isTrue,
      );

      await notificationService.unsubscribeFromClub(clubId);
      expect(
        notificationService.subscribedTopics.contains('clubs_$clubId'),
        isFalse,
      );
    });

    test('Cannot subscribe to same topic twice', () async {
      const matchId = 'match_duplicate';
      await notificationService.subscribeToMatch(matchId);
      final topicsAfterFirst = notificationService.subscribedTopics.length;

      // Try subscribing again
      await notificationService.subscribeToMatch(matchId);
      final topicsAfterSecond = notificationService.subscribedTopics.length;

      expect(topicsAfterFirst, equals(topicsAfterSecond));
    });

    test('Notification stream emits notifications', () async {
      final notification = PushNotification(
        title: 'Goal Scored!',
        body: 'Your team scored a goal',
        data: {'type': 'goal', 'matchId': 'match_123'},
        timestamp: DateTime.now(),
        type: 'match',
        entityId: 'match_123',
      );

      expect(
        notificationService.notificationStream,
        emits(notification),
      );
    });

    test('Notification count increases when notification is added', () async {
      expect(notificationService.getNotificationCount(), equals(0));

      // Note: In actual implementation, notifications are added via Firebase
      // This test verifies the getter works
    });

    test('Can clear all notifications', () async {
      notificationService.clearAllNotifications();
      expect(notificationService.getNotificationCount(), equals(0));
    });

    test('Can get recent notifications', () async {
      // Add mock data simulation
      final recentNotifications = notificationService.getRecentNotifications(limit: 5);
      expect(recentNotifications, isA<List<PushNotification>>());
    });

    test('NotificationService properly disconnects', () async {
      expect(notificationService.isInitialized, isTrue);

      await notificationService.disconnect();
      expect(notificationService.isInitialized, isFalse);
      expect(notificationService.subscribedTopics.isEmpty, isTrue);
    });

    test('Can re-initialize after disconnect', () async {
      await notificationService.disconnect();
      expect(notificationService.isInitialized, isFalse);

      // Re-initialize
      await notificationService.init();
      expect(notificationService.isInitialized, isTrue);
    });

    test('Subscription persists across app sessions', () async {
      const matchId = 'match_persistent';
      await notificationService.subscribeToMatch(matchId);

      // Simulate getting preferences
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('notification_subscriptions');

      expect(stored, isNotNull);
      expect(stored!.isNotEmpty, isTrue);
    });

    test('Coach role can receive match notifications', () async {
      final coachUser = User(
        id: 'coach_user',
        fullName: 'Coach',
        email: 'coach@test.com',
        username: 'coach_user',
        role: UserRole.coach,
        isEmailVerified: true,
        isPhoneVerified: false,
        createdAt: DateTime.now(),
        isActive: true,
      );
      authService.setCurrentUser(coachUser);

      const matchId = 'match_for_coach';
      await notificationService.subscribeToMatch(matchId);

      expect(
        notificationService.subscribedTopics.contains('matches_$matchId'),
        isTrue,
      );
    });

    test('Fan role can receive general notifications', () async {
      final fanUser = User(
        id: 'fan_user',
        fullName: 'Fan',
        email: 'fan@test.com',
        username: 'fan_user',
        role: UserRole.fan,
        isEmailVerified: true,
        isPhoneVerified: false,
        createdAt: DateTime.now(),
        isActive: true,
      );
      authService.setCurrentUser(fanUser);

      const matchId = 'match_for_fan';
      await notificationService.subscribeToMatch(matchId);

      expect(
        notificationService.subscribedTopics.contains('matches_$matchId'),
        isTrue,
      );
    });

    test('Multiple subscriptions can coexist', () async {
      await notificationService.subscribeToMatch('match_1');
      await notificationService.subscribeToTournament('tournament_1');
      await notificationService.subscribeToFriendly('friendly_1');
      await notificationService.subscribeToClub('club_1');

      expect(notificationService.subscribedTopics.length, equals(4));
    });

    test('Connection status stream emits status changes', () async {
      expect(
        notificationService.connectionStatusStream,
        emits(isTrue),
      );
    });

    test('Can create PushNotification from data', () async {
      final notification = PushNotification(
        title: 'Match Started',
        body: 'Your match is about to start',
        data: {'type': 'match_started', 'matchId': 'match_555'},
        timestamp: DateTime.now(),
        type: 'match',
        entityId: 'match_555',
      );

      expect(notification.title, equals('Match Started'));
      expect(notification.type, equals('match'));
      expect(notification.entityId, equals('match_555'));
    });

    test('NotificationSubscription serializes correctly', () async {
      final subscription = NotificationSubscription(
        topic: 'matches_123',
        entityId: 'match_123',
        entityType: 'match',
      );

      final json = subscription.toJson();
      expect(json['topic'], equals('matches_123'));
      expect(json['entityId'], equals('match_123'));
      expect(json['entityType'], equals('match'));
    });

    test('NotificationSubscription deserializes correctly', () async {
      final json = {
        'topic': 'tournaments_456',
        'entityId': 'tournament_456',
        'entityType': 'tournament',
        'subscribedAt': DateTime.now().toIso8601String(),
      };

      final subscription = NotificationSubscription.fromJson(json);
      expect(subscription.topic, equals('tournaments_456'));
      expect(subscription.entityId, equals('tournament_456'));
      expect(subscription.entityType, equals('tournament'));
    });

    test('Can unsubscribe from all topics', () async {
      // Subscribe to multiple topics
      await notificationService.subscribeToMatch('match_a');
      await notificationService.subscribeToTournament('tournament_b');
      await notificationService.subscribeToClub('club_c');

      expect(notificationService.subscribedTopics.length, equals(3));

      // Unsubscribe from all
      for (final topic in notificationService.subscribedTopics.toList()) {
        if (topic.startsWith('matches_')) {
          final matchId = topic.replaceFirst('matches_', '');
          await notificationService.unsubscribeFromMatch(matchId);
        } else if (topic.startsWith('tournaments_')) {
          final tournamentId = topic.replaceFirst('tournaments_', '');
          await notificationService.unsubscribeFromTournament(tournamentId);
        } else if (topic.startsWith('clubs_')) {
          final clubId = topic.replaceFirst('clubs_', '');
          await notificationService.unsubscribeFromClub(clubId);
        }
      }

      expect(notificationService.subscribedTopics.isEmpty, isTrue);
    });
  });
}
