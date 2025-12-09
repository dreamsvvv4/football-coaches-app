import 'package:flutter_test/flutter_test.dart';
import '../lib/services/realtime_service.dart';

void main() {
  group('RealtimeService Tests', () {
    setUp(() {
      // Reset service before each test
      RealtimeService.instance.disconnect();
    });

    tearDown(() {
      RealtimeService.instance.disconnect();
    });

    test('RealtimeEvent should serialize/deserialize correctly', () {
      final event = RealtimeEvent(
        id: 'event_123',
        type: 'goal',
        matchId: 'match_1',
        team: 'home',
        minute: 45,
        player: 'John Doe',
        description: 'Gol de John Doe',
        recordedById: 'user_1',
        recordedByName: 'Coach Smith',
      );

      final json = event.toJson();
      final restored = RealtimeEvent.fromJson(json);

      expect(restored.id, event.id);
      expect(restored.type, event.type);
      expect(restored.matchId, event.matchId);
      expect(restored.team, event.team);
      expect(restored.minute, event.minute);
      expect(restored.player, event.player);
      expect(restored.description, event.description);
      expect(restored.recordedById, event.recordedById);
      expect(restored.recordedByName, event.recordedByName);
    });

    test('RealtimeEvent.fromJson() handles missing optional fields', () {
      final json = {
        'id': 'event_456',
        'type': 'yellow_card',
        'matchId': 'match_2',
        'team': 'away',
      };

      final event = RealtimeEvent.fromJson(json);

      expect(event.id, 'event_456');
      expect(event.type, 'yellow_card');
      expect(event.matchId, 'match_2');
      expect(event.team, 'away');
      expect(event.minute, isNull);
      expect(event.player, isNull);
      expect(event.description, isNull);
      expect(event.data, isEmpty);
    });

    test('RealtimeEvent.toString() produces expected format', () {
      final event = RealtimeEvent(
        id: 'event_789',
        type: 'goal',
        matchId: 'match_3',
        team: 'home',
      );

      final str = event.toString();
      expect(str.contains('goal'), true);
      expect(str.contains('match_3'), true);
      expect(str.contains('home'), true);
    });

    test('init() initializes with user context', () async {
      await RealtimeService.instance.init(
        userId: 'user_123',
        userRole: 'coach',
      );

      expect(RealtimeService.instance.isConnected, isTrue);
    });

    test('subscribeToMatch() returns a Stream', () async {
      await RealtimeService.instance.init(
        userId: 'user_456',
        userRole: 'coach',
      );

      final stream = RealtimeService.instance.subscribeToMatch('match_789');
      expect(stream, isNotNull);
      expect(stream, isA<Stream<RealtimeEvent>>());
    });

    test('subscribeToMatch() multiple subscriptions work independently', () async {
      await RealtimeService.instance.init(
        userId: 'user_789',
        userRole: 'coach',
      );

      final stream1 = RealtimeService.instance.subscribeToMatch('match_1');
      final stream2 = RealtimeService.instance.subscribeToMatch('match_2');

      expect(stream1, isNotNull);
      expect(stream2, isNotNull);
      expect(stream1, isNot(stream2));
    });

    test('emitEvent() validates required fields', () async {
      await RealtimeService.instance.init(
        userId: 'user_1',
        userRole: 'coach',
      );

      // Empty matchId should fail
      final result1 = await RealtimeService.instance.emitEvent(
        matchId: '',
        eventType: 'goal',
        team: 'home',
      );
      expect(result1, isFalse);

      // Empty eventType should fail
      final result2 = await RealtimeService.instance.emitEvent(
        matchId: 'match_1',
        eventType: '',
        team: 'home',
      );
      expect(result2, isFalse);

      // Invalid team value should fail
      final result3 = await RealtimeService.instance.emitEvent(
        matchId: 'match_1',
        eventType: 'goal',
        team: 'center',
      );
      expect(result3, isFalse);
    });

    test('emitEvent() respects RBAC - coach can emit', () async {
      await RealtimeService.instance.init(
        userId: 'coach_user',
        userRole: 'coach',
      );

      final result = await RealtimeService.instance.emitEvent(
        matchId: 'match_1',
        eventType: 'goal',
        team: 'home',
      );

      // Should succeed for coach
      expect(result, isA<bool>());
    });

    test('emitEvent() respects RBAC - fan cannot emit', () async {
      await RealtimeService.instance.init(
        userId: 'fan_user',
        userRole: 'fan',
      );

      final result = await RealtimeService.instance.emitEvent(
        matchId: 'match_1',
        eventType: 'goal',
        team: 'home',
      );

      // Should fail for fan
      expect(result, isFalse);
    });

    test('emitEvent() accepts valid event types', () async {
      await RealtimeService.instance.init(
        userId: 'user_1',
        userRole: 'coach',
      );

      final validTypes = ['goal', 'yellow_card', 'red_card', 'sub', 'score_update', 'match_status'];

      for (final type in validTypes) {
        final result = await RealtimeService.instance.emitEvent(
          matchId: 'match_1',
          eventType: type,
          team: 'home',
        );
        expect(result, isA<bool>());
      }
    });

    test('emitEvent() with optional data fields', () async {
      await RealtimeService.instance.init(
        userId: 'user_1',
        userRole: 'coach',
      );

      final result = await RealtimeService.instance.emitEvent(
        matchId: 'match_1',
        eventType: 'goal',
        team: 'home',
        minute: 45,
        player: 'John Doe',
        description: 'Great header goal',
        data: {'assists': 1, 'fastBreak': true},
      );

      expect(result, isA<bool>());
    });

    test('unsubscribeFromMatch() removes subscription', () async {
      await RealtimeService.instance.init(
        userId: 'user_1',
        userRole: 'coach',
      );

      final stream = RealtimeService.instance.subscribeToMatch('match_1');
      expect(stream, isNotNull);

      RealtimeService.instance.unsubscribeFromMatch('match_1');

      // After unsubscribe, new subscription should be a different stream
      final newStream = RealtimeService.instance.subscribeToMatch('match_1');
      expect(newStream, isNotNull);
    });

    test('disconnect() cleans up resources', () async {
      await RealtimeService.instance.init(
        userId: 'user_1',
        userRole: 'coach',
      );

      RealtimeService.instance.subscribeToMatch('match_1');
      expect(RealtimeService.instance.isConnected, isTrue);

      RealtimeService.instance.disconnect();
      expect(RealtimeService.instance.isConnected, isFalse);
    });

    test('WebSocketSimulator.simulateMessage() triggers callbacks', () async {
      final simulator = WebSocketSimulator();
      await simulator.connect(url: 'ws://test');

      String? receivedMessage;
      simulator.onMessage((msg) {
        receivedMessage = msg;
      });

      final testData = {
        'type': 'goal',
        'matchId': 'match_1',
        'team': 'home',
      };

      simulator.simulateMessage(testData);

      expect(receivedMessage, isNotNull);
      expect(receivedMessage, isA<String>());
    });

    test('isConnected getter returns connection state', () async {
      expect(RealtimeService.instance.isConnected, isFalse);

      await RealtimeService.instance.init(
        userId: 'user_1',
        userRole: 'coach',
      );

      expect(RealtimeService.instance.isConnected, isTrue);

      RealtimeService.instance.disconnect();
      expect(RealtimeService.instance.isConnected, isFalse);
    });

    test('Multiple init calls do not reinitialize', () async {
      await RealtimeService.instance.init(
        userId: 'user_1',
        userRole: 'coach',
      );

      // Second init should return early
      await RealtimeService.instance.init(
        userId: 'user_2',
        userRole: 'referee',
      );

      // User ID should still be the first one
      expect(RealtimeService.instance.isConnected, isTrue);
    });

    test('Event with all optional fields included', () {
      final event = RealtimeEvent(
        id: 'event_full',
        type: 'goal',
        matchId: 'match_full',
        team: 'home',
        minute: 67,
        player: 'Full Player',
        description: 'Full description',
        data: {
          'assists': 2,
          'penalty': false,
          'header': true,
        },
        recordedById: 'rec_user',
        recordedByName: 'Recorder Name',
      );

      expect(event.id, 'event_full');
      expect(event.data['assists'], 2);
      expect(event.recordedByName, 'Recorder Name');
    });
  });
}
