import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Represents a real-time event received from the backend (WebSocket/Socket.io)
class RealtimeEvent {
  final String id;
  final String type; // 'goal', 'yellow_card', 'red_card', 'sub', 'score_update', 'match_status'
  final String matchId;
  final String team; // 'home' | 'away'
  final int? minute;
  final String? player;
  final String? description;
  final Map<String, dynamic> data; // Additional event-specific data
  final DateTime timestamp;
  final String? recordedById;
  final String? recordedByName;

  RealtimeEvent({
    required this.id,
    required this.type,
    required this.matchId,
    required this.team,
    this.minute,
    this.player,
    this.description,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    this.recordedById,
    this.recordedByName,
  })  : data = data ?? {},
        timestamp = timestamp ?? DateTime.now();

  /// Parse JSON from WebSocket message
  factory RealtimeEvent.fromJson(Map<String, dynamic> json) {
    return RealtimeEvent(
      id: json['id'] as String? ?? 'event_${DateTime.now().millisecondsSinceEpoch}',
      type: json['type'] as String? ?? 'unknown',
      matchId: json['matchId'] as String? ?? '',
      team: json['team'] as String? ?? 'home',
      minute: json['minute'] as int?,
      player: json['player'] as String?,
      description: json['description'] as String?,
      data: json['data'] as Map<String, dynamic>? ?? {},
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      recordedById: json['recordedById'] as String?,
      recordedByName: json['recordedByName'] as String?,
    );
  }

  /// Convert to JSON for sending to backend
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'matchId': matchId,
        'team': team,
        'minute': minute,
        'player': player,
        'description': description,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
        'recordedById': recordedById,
        'recordedByName': recordedByName,
      };

  @override
  String toString() => 'RealtimeEvent(type: $type, match: $matchId, team: $team)';
}

/// Singleton service for WebSocket/real-time match updates
/// Handles connection, event subscription, reconnection, and debouncing
class RealtimeService {
  static final RealtimeService instance = RealtimeService._internal();
  RealtimeService._internal();

  // WebSocket simulation (will be replaced with real socket.io/web_socket_channel)
  late WebSocketSimulator _webSocket;

  // Event streams per match
  final Map<String, StreamController<RealtimeEvent>> _matchSubscriptions = {};

  // Event queue for debouncing to prevent UI flooding
  final List<RealtimeEvent> _eventQueue = [];
  Timer? _debounceTimer;

  // Connection state
  bool _isConnected = false;
  bool _isInitialized = false;
  bool _manuallyDisconnected = false;
  late String _currentUserId;
  late String _currentUserRole;

  // Reconnection configuration
  final Duration _reconnectDelay = const Duration(seconds: 3);
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;

  /// Initialize WebSocket connection with user context
  /// Must be called once at app startup
  Future<void> init({required String userId, required String userRole}) async {
    if (_isInitialized) return;

    _currentUserId = userId;
    _currentUserRole = userRole;
    _manuallyDisconnected = false;

    // Initialize mock WebSocket (will be replaced with real implementation)
    _webSocket = WebSocketSimulator();

    try {
      await _connect();
      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) print('RealtimeService init failed: $e');
      _scheduleReconnect();
    }
  }

  /// Connect to WebSocket server
  Future<void> _connect() async {
    try {
      if (kDebugMode) print('[Realtime] Connecting to WebSocket...');

      // In MVP: simulate connection. In production: use socket.io or web_socket_channel
      await _webSocket.connect(
        url: 'ws://localhost:3000/live', // Mock URL for MVP
      );

      // Send authentication
      _webSocket.send({
        'type': 'auth',
        'userId': _currentUserId,
        'role': _currentUserRole,
      });

      // Listen to incoming messages
      _webSocket.onMessage((dynamic message) {
        try {
          final json = jsonDecode(message as String) as Map<String, dynamic>;
          final event = RealtimeEvent.fromJson(json);
          _handleIncomingEvent(event);
        } catch (e) {
          if (kDebugMode) print('[Realtime] Message parse error: $e');
        }
      });

      // Handle disconnection
      _webSocket.onDisconnect(() {
        if (kDebugMode) print('[Realtime] Disconnected from server');
        _isConnected = false;
        if (!_manuallyDisconnected) {
          _scheduleReconnect();
        }
      });

      _isConnected = true;
      _reconnectAttempts = 0;
      if (kDebugMode) print('[Realtime] Connected successfully');
    } catch (e) {
      if (kDebugMode) print('[Realtime] Connection error: $e');
      rethrow;
    }
  }

  /// Subscribe to events for a specific match
  /// Returns a Stream of real-time events
  Stream<RealtimeEvent> subscribeToMatch(String matchId) {
    final controller = _matchSubscriptions.putIfAbsent(
      matchId,
      () => StreamController<RealtimeEvent>.broadcast(),
    );

    // Send subscription request to server
    if (_isConnected) {
      _webSocket.send({
        'type': 'subscribe',
        'matchId': matchId,
      });
    }

    return controller.stream;
  }

  /// Unsubscribe from a match
  void unsubscribeFromMatch(String matchId) {
    if (_isConnected) {
      _webSocket.send({
        'type': 'unsubscribe',
        'matchId': matchId,
      });
    }
    _matchSubscriptions[matchId]?.close();
    _matchSubscriptions.remove(matchId);
  }

  /// Emit an event (only if authorized)
  /// Returns true if successful, false otherwise
  Future<bool> emitEvent({
    required String matchId,
    required String eventType,
    required String team,
    int? minute,
    String? player,
    String? description,
    Map<String, dynamic>? data,
  }) async {
    // RBAC Check: only coach, staff, referee, admin can emit events
    final allowedRoles = {'coach', 'staff', 'referee', 'club_admin', 'superadmin'};
    if (!allowedRoles.contains(_currentUserRole)) {
      if (kDebugMode) print('[Realtime] User role "$_currentUserRole" not authorized to emit events');
      return false;
    }

    // Validate event data
    if (matchId.isEmpty || eventType.isEmpty || team.isEmpty) {
      if (kDebugMode) print('[Realtime] Invalid event data: missing required fields');
      return false;
    }

    if (team != 'home' && team != 'away') {
      if (kDebugMode) print('[Realtime] Invalid team value: must be "home" or "away"');
      return false;
    }

    try {
      final event = RealtimeEvent(
        id: 'event_${DateTime.now().millisecondsSinceEpoch}',
        type: eventType,
        matchId: matchId,
        team: team,
        minute: minute,
        player: player,
        description: description,
        data: data,
        recordedById: _currentUserId,
      );

      if (!_isConnected) {
        if (kDebugMode) print('[Realtime] Not connected, queuing event');
        _eventQueue.add(event);
        return false;
      }

      // Send to server
      _webSocket.send(event.toJson());

      if (kDebugMode) print('[Realtime] Event emitted: $event');
      return true;
    } catch (e) {
      if (kDebugMode) print('[Realtime] Error emitting event: $e');
      return false;
    }
  }

  /// Handle incoming event from server
  void _handleIncomingEvent(RealtimeEvent event) {
    // Validate event before processing
    if (event.matchId.isEmpty || event.type.isEmpty) {
      if (kDebugMode) print('[Realtime] Discarding invalid event');
      return;
    }

    // Add to queue for debouncing
    _eventQueue.add(event);

    // Debounce: flush queue after 100ms of inactivity
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      _flushEventQueue();
    });
  }

  /// Flush event queue to subscribers
  void _flushEventQueue() {
    for (final event in _eventQueue) {
      final controller = _matchSubscriptions[event.matchId];
      if (controller != null && !controller.isClosed) {
        controller.add(event);
      }
    }
    _eventQueue.clear();
  }

  /// Schedule automatic reconnection
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      if (kDebugMode) print('[Realtime] Max reconnection attempts reached');
      return;
    }

    _reconnectAttempts++;
    if (kDebugMode) {
      print('[Realtime] Reconnecting in ${_reconnectDelay.inSeconds}s (attempt $_reconnectAttempts)');
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      try {
        _connect();
      } catch (_) {
        _scheduleReconnect();
      }
    });
  }

  /// Check if connected
  bool get isConnected => _isConnected;

  /// Force disconnect and cleanup
  void disconnect() {
    _manuallyDisconnected = true;
    _debounceTimer?.cancel();
    _reconnectTimer?.cancel();
    try {
      if (_isInitialized) {
        _webSocket.disconnect();
      }
    } catch (_) {
      // Ignore: disconnect should be safe to call even if init failed.
    }
    _isConnected = false;
    _isInitialized = false;

    for (final controller in _matchSubscriptions.values) {
      if (!controller.isClosed) controller.close();
    }
    _matchSubscriptions.clear();
    _eventQueue.clear();
  }
}

/// Mock WebSocket implementation for MVP testing
/// In production, replace with socket.io or web_socket_channel
class WebSocketSimulator {
  late Function(dynamic) _onMessageCallback;
  late Function() _onDisconnectCallback;
  bool _connected = false;

  Future<void> connect({required String url}) async {
    _connected = true;
  }

  void send(Map<String, dynamic> data) {
    if (!_connected) return;
    // In MVP, just simulate: in production, send via socket.io
    if (kDebugMode) print('[WebSocket] Sending: $data');
  }

  void onMessage(Function(dynamic) callback) {
    _onMessageCallback = callback;
  }

  void onDisconnect(Function() callback) {
    _onDisconnectCallback = callback;
  }

  void disconnect() {
    _connected = false;
    try {
      _onDisconnectCallback();
    } catch (_) {
      // Ignore: callbacks may be unset if connect/init never completed.
    }
  }

  // Simulate receiving a message (for testing)
  void simulateMessage(Map<String, dynamic> data) {
    _onMessageCallback(jsonEncode(data));
  }
}
