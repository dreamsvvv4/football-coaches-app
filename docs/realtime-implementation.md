# Real-Time Match Updates - Implementation Guide

## Overview

This document describes the complete real-time match updates implementation for the Football Coaches App. The system uses WebSocket connections to provide live updates for matches, tournaments, and clubs across all platforms (mobile, web, and backend).

## Table of Contents

1. [Architecture](#architecture)
2. [Backend Implementation](#backend-implementation)
3. [Frontend Implementation](#frontend-implementation)
4. [Mobile Implementation](#mobile-implementation)
5. [Testing Strategy](#testing-strategy)
6. [Deployment](#deployment)
7. [Troubleshooting](#troubleshooting)

---

## Architecture

### High-Level Design

```
┌─────────────────────────────────────────────────────────────────┐
│                        Client Applications                        │
│  ┌──────────────────┬──────────────────┬──────────────────┐     │
│  │   Web Admin      │  Mobile (React)  │ Mobile (Flutter) │     │
│  └────────┬─────────┴────────┬─────────┴────────┬─────────┘     │
│           │                  │                  │                │
│           └──────────────────┼──────────────────┘                │
│                              │ WebSocket                         │
│                              ▼                                    │
│                    ┌─────────────────────┐                       │
│                    │  RealtimeService    │                       │
│                    │  (Broker/Gateway)   │                       │
│                    └─────────┬───────────┘                       │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
                ┌────────────────────────────┐
                │   Backend Services         │
                │ ┌──────────────────────┐  │
                │ │ WebSocket Server     │  │
                │ ├──────────────────────┤  │
                │ │ Event Emitter        │  │
                │ ├──────────────────────┤  │
                │ │ Database Changes     │  │
                │ ├──────────────────────┤  │
                │ │ Authentication       │  │
                │ └──────────────────────┘  │
                └────────────────────────────┘
```

### Event Flow

1. **Event Trigger**: A change occurs in the system (goal scored, card issued, match status changed)
2. **Event Emission**: Backend service emits the event via the RealtimeService
3. **Broadcasting**: The event is broadcast to all connected clients subscribed to the relevant entity
4. **Client Update**: Frontend/mobile applications receive and process the event
5. **UI Update**: The UI is updated to reflect the new state

---

## Backend Implementation

### RealtimeService (Backend)

Located in `backend/src/services/realtime.service.ts`

#### Key Features:

- WebSocket server using Socket.io
- Authentication and authorization
- Event broadcasting based on subscriptions
- Connection pooling and resource management
- Error handling and reconnection logic

#### Usage Example:

```typescript
import { RealtimeService } from './services/realtime.service';

// Initialize
const realtime = new RealtimeService();
await realtime.init();

// Broadcast a goal event
realtime.broadcastMatchEvent('match_123', {
  type: 'goal',
  minute: 45,
  team: 'home',
  player: 'player_456',
  timestamp: new Date()
});

// Broadcast tournament update
realtime.broadcastTournamentEvent('tournament_789', {
  type: 'match_finished',
  matchId: 'match_123',
  finalScore: { home: 2, away: 1 }
});
```

### Event Types

#### Match Events
- `goal` - A goal was scored
- `yellow_card` - Player received yellow card
- `red_card` - Player received red card
- `substitution` - Player substitution
- `injury` - Injury timeout
- `match_started` - Match started
- `match_finished` - Match finished
- `match_cancelled` - Match cancelled
- `status_changed` - Match status changed

#### Tournament Events
- `match_scheduled` - New match scheduled
- `match_finished` - Match completed
- `standings_updated` - Tournament standings changed
- `phase_advanced` - Tournament advanced to next phase

#### Club Events
- `team_updated` - Team roster changed
- `player_added` - New player added
- `player_removed` - Player removed
- `tournament_joined` - Team joined tournament

### Database Triggers

For real-time updates from database changes, implement triggers:

```sql
-- Example: Auto-broadcast when match_events table is updated
CREATE TRIGGER broadcast_match_event
AFTER INSERT ON match_events
FOR EACH ROW
BEGIN
  -- Trigger backend service to broadcast event
  SELECT notify('match_' || NEW.match_id, json_build_object(
    'type', NEW.event_type,
    'data', row_to_json(NEW)
  )::text);
END;
```

---

## Frontend Implementation

### RealtimeService (Web)

Located in `web-admin/src/services/RealtimeService.ts`

#### Key Features:

- Socket.io client
- Automatic reconnection
- Event subscription management
- Memory-efficient resource cleanup

#### Usage Example:

```typescript
import { RealtimeService } from './services/RealtimeService';

// Initialize and connect
const realtime = RealtimeService.getInstance();
await realtime.connect(userId, authToken);

// Subscribe to match events
realtime.subscribeToMatch('match_123', (event) => {
  console.log('Match event:', event);
  // Update UI
});

// Subscribe to tournament events
realtime.subscribeToTournament('tournament_456', (event) => {
  console.log('Tournament event:', event);
  // Update UI
});

// Handle connection status
realtime.onStatusChange((status) => {
  console.log('Connection status:', status);
  // Show/hide connection indicator
});

// Clean up when leaving
realtime.unsubscribeFromMatch('match_123');
```

### React Integration

#### Example Component:

```typescript
import React, { useEffect, useState } from 'react';
import { RealtimeService } from './services/RealtimeService';
import { Match } from './types';

interface MatchDetailProps {
  matchId: string;
}

export const MatchDetail: React.FC<MatchDetailProps> = ({ matchId }) => {
  const [match, setMatch] = useState<Match | null>(null);
  const [connectionStatus, setConnectionStatus] = useState<string>('connecting');

  useEffect(() => {
    const realtime = RealtimeService.getInstance();

    // Subscribe to real-time updates
    const unsubscribe = realtime.subscribeToMatch(matchId, (event) => {
      setMatch((prevMatch) => {
        if (!prevMatch) return prevMatch;

        // Update match based on event
        switch (event.type) {
          case 'goal':
            return {
              ...prevMatch,
              score: {
                ...prevMatch.score,
                [event.team]: prevMatch.score[event.team] + 1
              },
              timeline: [...prevMatch.timeline, event]
            };
          case 'match_finished':
            return {
              ...prevMatch,
              status: 'finished',
              finalScore: event.finalScore
            };
          default:
            return prevMatch;
        }
      });
    });

    // Monitor connection status
    realtime.onStatusChange(setConnectionStatus);

    return () => {
      unsubscribe();
    };
  }, [matchId]);

  return (
    <div>
      <div className="connection-status">
        Status: {connectionStatus}
      </div>
      {match && (
        <div className="match-detail">
          {/* Render match details */}
        </div>
      )}
    </div>
  );
};
```

---

## Mobile Implementation

### Flutter RealtimeService

Located in `mobile_flutter/lib/services/realtime_service.dart`

#### Key Features:

- WebSocket client using `web_socket_channel`
- Event stream management
- Singleton pattern for single connection
- Clean disconnect handling

#### Usage Example:

```dart
import 'package:football_coaches_app/services/realtime_service.dart';
import 'package:football_coaches_app/services/auth_service.dart';

// Initialize
final realtime = RealtimeService.instance;
final auth = AuthService.instance;

await realtime.init(
  userId: auth.currentUser!.id,
  userRole: auth.currentUser!.role,
);

// Subscribe to match events
final subscription = realtime.subscribeToMatch('match_123');

subscription?.listen((event) {
  print('Match event: $event');
  // Update UI state
});

// Unsubscribe
subscription?.cancel();

// Disconnect
realtime.disconnect();
```

### Flutter Widget Integration

#### Example Screen:

```dart
import 'package:flutter/material.dart';
import 'package:football_coaches_app/services/realtime_service.dart';

class MatchDetailScreen extends StatefulWidget {
  final String matchId;

  const MatchDetailScreen({required this.matchId});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  late StreamSubscription _realtimeSubscription;
  late RealtimeService _realtime;

  @override
  void initState() {
    super.initState();
    _realtime = RealtimeService.instance;

    // Subscribe to real-time updates
    _realtimeSubscription = _realtime.subscribeToMatch(widget.matchId)!.listen(
      (event) {
        setState(() {
          // Update match state
          _handleMatchEvent(event);
        });
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection error: $error')),
        );
      },
    );
  }

  void _handleMatchEvent(Map<String, dynamic> event) {
    switch (event['type']) {
      case 'goal':
        // Handle goal
        break;
      case 'yellow_card':
        // Handle yellow card
        break;
      case 'red_card':
        // Handle red card
        break;
      case 'match_finished':
        // Handle match finished
        break;
    }
  }

  @override
  void dispose() {
    _realtimeSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match Details')),
      body: _buildMatchContent(),
    );
  }

  Widget _buildMatchContent() {
    // Build UI
    return Container();
  }
}
```

---

## Testing Strategy

### Unit Tests

#### Backend Tests (`backend/test/realtime.service.test.ts`)

```typescript
describe('RealtimeService', () => {
  let service: RealtimeService;

  beforeEach(async () => {
    service = new RealtimeService();
    await service.init();
  });

  test('should broadcast match events', async () => {
    const mockEvent = {
      type: 'goal',
      matchId: 'match_123',
      data: { player: 'John Doe', minute: 45 }
    };

    const listener = jest.fn();
    service.on('match_match_123', listener);

    service.broadcastMatchEvent('match_123', mockEvent);

    expect(listener).toHaveBeenCalledWith(mockEvent);
  });

  test('should handle multiple subscribers', async () => {
    const listener1 = jest.fn();
    const listener2 = jest.fn();

    service.on('match_123', listener1);
    service.on('match_123', listener2);

    const event = { type: 'goal' };
    service.broadcastMatchEvent('match_123', event);

    expect(listener1).toHaveBeenCalledWith(event);
    expect(listener2).toHaveBeenCalledWith(event);
  });
});
```

#### Frontend Tests (`web-admin/src/services/RealtimeService.test.ts`)

```typescript
describe('RealtimeService', () => {
  let service: RealtimeService;

  beforeEach(() => {
    service = RealtimeService.getInstance();
  });

  test('should connect to WebSocket', async () => {
    await service.connect('user123', 'token123');
    expect(service.isConnected).toBe(true);
  });

  test('should subscribe to match events', () => {
    const callback = jest.fn();
    service.subscribeToMatch('match_123', callback);

    // Simulate event
    const event = { type: 'goal', minute: 45 };
    service.emit('match_match_123', event);

    expect(callback).toHaveBeenCalledWith(event);
  });
});
```

#### Flutter Tests (`mobile_flutter/test/realtime_integration_test.dart`)

```dart
void main() {
  group('RealtimeService Tests', () {
    test('RealtimeService connects successfully', () async {
      final realtime = RealtimeService.instance;
      final user = User(
        id: 'test_user',
        name: 'Test',
        email: 'test@example.com',
        role: 'coach',
      );

      await realtime.init(userId: user.id, userRole: user.role);
      expect(realtime.isConnected, isTrue);

      realtime.disconnect();
    });

    test('RealtimeService subscribes to match events', () async {
      final realtime = RealtimeService.instance;
      final subscription = realtime.subscribeToMatch('match_123');

      expect(subscription, isNotNull);

      subscription?.cancel();
    });
  });
}
```

### Integration Tests

#### Full Flow Test

```bash
# Start backend
npm run dev --prefix backend

# Start test server
npm test --prefix backend

# Run integration tests
npm run test:integration
```

#### End-to-End Test

```bash
# Run full stack tests
npm run test:e2e

# Specific test for real-time updates
npm run test:e2e -- --grep="real-time"
```

### Performance Tests

```typescript
// backend/test/performance.test.ts
describe('RealtimeService Performance', () => {
  test('should handle 1000 concurrent connections', async () => {
    const service = new RealtimeService();
    await service.init();

    const connections = Array(1000)
      .fill(null)
      .map((_, i) => service.handleClientConnection(`client_${i}`));

    expect(connections.length).toBe(1000);
  });

  test('should broadcast to 1000 subscribers in <100ms', async () => {
    const service = new RealtimeService();
    const event = { type: 'goal' };

    const start = Date.now();
    service.broadcastMatchEvent('match_123', event);
    const duration = Date.now() - start;

    expect(duration).toBeLessThan(100);
  });
});
```

---

## Deployment

### Environment Variables

```bash
# Backend (.env)
WEBSOCKET_PORT=3001
WEBSOCKET_PROTOCOL=ws
REDIS_URL=redis://localhost:6379
DATABASE_URL=postgresql://user:password@localhost/db
JWT_SECRET=your_secret_key

# Frontend (.env.local)
REACT_APP_WEBSOCKET_URL=wss://api.example.com
REACT_APP_API_BASE_URL=https://api.example.com/api
```

### Docker Deployment

```yaml
# docker-compose.yml
version: '3.8'

services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
      - "3001:3001"  # WebSocket port
    environment:
      - WEBSOCKET_PORT=3001
      - REDIS_URL=redis://redis:6379
      - DATABASE_URL=postgresql://postgres:password@db:5432/football_app

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=football_app
      - POSTGRES_PASSWORD=password
```

### Kubernetes Deployment

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: realtime-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: realtime-service
  template:
    metadata:
      labels:
        app: realtime-service
    spec:
      containers:
      - name: realtime
        image: football-coaches-app/backend:latest
        ports:
        - containerPort: 3001
        env:
        - name: WEBSOCKET_PORT
          value: "3001"
        - name: REDIS_URL
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: redis-url
        livenessProbe:
          tcpSocket:
            port: 3001
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          tcpSocket:
            port: 3001
          initialDelaySeconds: 10
          periodSeconds: 5
```

---

## Troubleshooting

### Connection Issues

#### Problem: WebSocket connection fails

**Solution:**
1. Check if backend is running: `curl http://localhost:3000/health`
2. Verify WebSocket port: `netstat -an | grep 3001`
3. Check firewall rules
4. Verify authentication token is valid

#### Problem: Events not being received

**Solution:**
1. Check subscription: `console.log(isSubscribed)` in browser console
2. Verify event is being broadcast on backend
3. Check network tab for WebSocket messages
4. Verify user has permission to receive events

### Performance Issues

#### Problem: High latency in real-time updates

**Solution:**
1. Check Redis connection
2. Monitor backend CPU/memory usage
3. Check network latency: `ping api.example.com`
4. Review logs for bottlenecks

#### Problem: Memory leaks in frontend

**Solution:**
1. Ensure subscriptions are cancelled in cleanup
2. Use React DevTools Profiler to identify re-renders
3. Check for circular references in state management
4. Implement garbage collection in long-running services

### Authentication Issues

#### Problem: "Unauthorized" error on connection

**Solution:**
1. Verify JWT token is valid: `jwt.decode(token)`
2. Check token expiration
3. Verify user role has permission
4. Check token in Authorization header

### Browser-Specific Issues

#### Safari: WebSocket connection drops

**Solution:**
1. Enable WebSocket proxy in development
2. Increase idle timeout
3. Implement automatic reconnection with exponential backoff

#### Firefox: Events not updating UI

**Solution:**
1. Verify Dart DevTools Debugger is not paused
2. Check if hot reload is interfering with subscriptions
3. Rebuild Flutter app fresh: `flutter clean && flutter run`

---

## Monitoring and Logging

### Backend Logging

```typescript
// Log all events
realtime.on('match_event', (event) => {
  logger.info('Match event received', {
    matchId: event.matchId,
    type: event.type,
    timestamp: new Date()
  });
});

// Monitor connection count
setInterval(() => {
  logger.info('Active connections', {
    count: realtime.getConnectionCount(),
    subscriptions: realtime.getSubscriptionCount()
  });
}, 60000);
```

### Metrics to Track

- Connection count (current/peak)
- Event throughput (events/second)
- Event latency (milliseconds)
- Error rate (errors/minute)
- Memory usage (MB)
- CPU usage (percentage)

### Alerting

```typescript
// Alert if connection count exceeds threshold
if (realtime.getConnectionCount() > 10000) {
  alerts.send('High connection count', {
    severity: 'warning',
    count: realtime.getConnectionCount()
  });
}

// Alert if error rate is high
if (errorRate > 0.05) {
  alerts.send('High error rate', {
    severity: 'critical',
    rate: errorRate
  });
}
```

---

## Security Considerations

1. **Authentication**: All WebSocket connections must be authenticated with JWT
2. **Authorization**: Users can only subscribe to events for their clubs/tournaments
3. **Rate Limiting**: Implement rate limiting to prevent abuse
4. **Input Validation**: Validate all event data before broadcasting
5. **Encryption**: Use WSS (WebSocket Secure) in production
6. **CORS**: Configure appropriate CORS headers

---

## Performance Optimization

1. **Connection Pooling**: Reuse WebSocket connections
2. **Message Batching**: Batch multiple events into single message
3. **Compression**: Enable message compression
4. **Caching**: Cache frequently accessed data
5. **Load Balancing**: Distribute connections across multiple servers using Redis

---

## Future Enhancements

1. **Offline Support**: Queue events when offline, sync when online
2. **Selective Updates**: Subscribe to specific event types only
3. **Message History**: Replay recent events for new subscribers
4. **Analytics**: Track which events are most valuable to users
5. **Push Notifications**: Integrate with push notification service for mobile

