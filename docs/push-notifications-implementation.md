# Push Notifications Implementation Guide

## Overview

This document describes the complete push notification system for the Football Coaches App MVP using Firebase Cloud Messaging (FCM). The implementation follows Material 3 design guidelines, secure practices, and clean architecture principles.

## Table of Contents

1. [Architecture](#architecture)
2. [Firebase Setup](#firebase-setup)
3. [Core Components](#core-components)
4. [Integration Guide](#integration-guide)
5. [Notification Types](#notification-types)
6. [Testing](#testing)
7. [Deployment](#deployment)
8. [Security](#security)
9. [Troubleshooting](#troubleshooting)

---

## Architecture

### System Design

```
┌─────────────────────────────────────────────────────────────┐
│                     Firebase Cloud Messaging                │
│                   (FCM Backend Service)                      │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    NotificationService                       │
│           (Singleton - App-wide Access Point)                │
│                                                               │
│  ┌─────────────────┐  ┌──────────────────┐  ┌────────────┐ │
│  │ Firebase Setup  │  │  Topic Mgmt      │  │  Local     │ │
│  │ & Token Mgmt    │  │  (Subscribe/     │  │  Notif     │ │
│  │                 │  │   Unsubscribe)   │  │  Display   │ │
│  └─────────────────┘  └──────────────────┘  └────────────┘ │
│                                                               │
│  ┌─────────────────┐  ┌──────────────────┐  ┌────────────┐ │
│  │ RBAC Check      │  │  Message         │  │  Local     │ │
│  │                 │  │  Handler         │  │  Storage   │ │
│  └─────────────────┘  └──────────────────┘  └────────────┘ │
└──────────────────────────┬──────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
┌─────────────────┐ ┌──────────────┐ ┌─────────────────┐
│  UI Components  │ │   Services   │ │  Local Storage  │
│  - Indicators   │ │  - Triggers  │ │  - Preferences  │
│  - SnackBars    │ │  - Listeners │ │  - Subscriptions│
│  - Bottom Sheet │ │              │ │                 │
└─────────────────┘ └──────────────┘ └─────────────────┘
```

### Data Flow

```
Backend Event
    │
    ├─→ FCM Server
    │
    ├─→ Firebase (Device)
    │
    ├─→ NotificationService
    │   ├─→ RBAC Check
    │   ├─→ Local Notification
    │   └─→ Stream emit
    │
    └─→ UI Components
        ├─→ SnackBar
        └─→ Badge Update
```

---

## Firebase Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project: "football-coaches-app"
3. Enable Firebase Cloud Messaging

### Step 2: Android Configuration

1. Add Google Services JSON:
   - Download `google-services.json` from Firebase Console
   - Place in `android/app/google-services.json`

2. Update `android/build.gradle`:
```gradle
buildscript {
  dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
  }
}
```

3. Update `android/app/build.gradle`:
```gradle
plugins {
  id 'com.google.gms.google-services'
}

dependencies {
  implementation 'com.google.firebase:firebase-messaging'
}
```

### Step 3: iOS Configuration

1. Add GoogleService-Info.plist:
   - Download from Firebase Console
   - Add to Xcode project: `ios/Runner`

2. Update `ios/Podfile`:
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_NOTIFICATIONS=1',
      ]
    end
  end
end
```

3. Enable capabilities in Xcode:
   - Select Runner target
   - Signing & Capabilities
   - Add "Push Notifications" capability

### Step 4: Flutter Dependencies

Already added in `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.13
  flutter_local_notifications: ^16.3.2
```

---

## Core Components

### 1. NotificationService

**Location:** `lib/services/notification_service.dart`

**Responsibilities:**
- Initialize Firebase and request permissions
- Manage FCM token lifecycle
- Handle topic subscriptions (matches, tournaments, friendlies, clubs)
- Process incoming notifications
- Display local notifications
- Implement RBAC

**Key Methods:**

```dart
// Initialization
Future<void> init({bool requestPermission = true})

// Subscriptions
Future<void> subscribeToMatch(String matchId)
Future<void> unsubscribeFromMatch(String matchId)
Future<void> subscribeToTournament(String tournamentId)
Future<void> unsubscribeFromTournament(String tournamentId)
Future<void> subscribeToFriendly(String friendlyId)
Future<void> unsubscribeFromFriendly(String friendlyId)
Future<void> subscribeToClub(String clubId)
Future<void> unsubscribeFromClub(String clubId)

// Getters
String? get fcmToken
Stream<PushNotification> get notificationStream
List<PushNotification> get notifications
Set<String> get subscribedTopics

// Management
void clearAllNotifications()
int getNotificationCount()
List<PushNotification> getRecentNotifications({int limit = 10})
Future<void> disconnect()
```

### 2. NotificationMixin

**Location:** `lib/services/notification_mixin.dart`

**Provides:**
- Easy notification triggering in any service
- Batch notification support
- RBAC helpers

**Usage:**

```dart
class MyService with NotificationMixin {
  Future<void> scoreGoal(String matchId) async {
    // ... score goal logic ...
    
    await notifyMatchEvent(
      matchId: matchId,
      type: 'goal',
      title: 'Goal Scored!',
      body: 'Your team scored a goal',
    );
  }
}
```

### 3. NotificationIndicator Widget

**Location:** `lib/widgets/notification_indicator.dart`

**Components:**
- **NotificationIndicator**: App bar badge with count
- **NotificationBottomSheet**: List of recent notifications
- **_NotificationTile**: Individual notification display

**Features:**
- Material 3 design
- Unread count badge
- Quick access to notifications
- Type-based color coding

### 4. PushNotification Model

```dart
class PushNotification {
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String type; // 'match', 'tournament', 'friendly', 'system'
  final String? entityId; // matchId, tournamentId, etc.
}
```

### 5. NotificationSubscription Model

```dart
class NotificationSubscription {
  final String topic;
  final String entityId;
  final String entityType; // 'match', 'tournament', 'friendly', 'club'
  final DateTime subscribedAt;
  
  // Persistence support
  Map<String, dynamic> toJson()
  factory NotificationSubscription.fromJson(Map<String, dynamic> json)
}
```

---

## Integration Guide

### 1. Initialize in main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize NotificationService
  await NotificationService.instance.init(requestPermission: true);

  // ... rest of initialization ...
}
```

### 2. Add NotificationIndicator to AppBar

```dart
AppBar(
  title: const Text('Football Coaches'),
  actions: [
    NotificationIndicator(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => const NotificationBottomSheet(),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          isScrollControlled: true,
        );
      },
    ),
  ],
)
```

### 3. Subscribe to Notifications

```dart
// In a service or screen
final user = AuthService.instance.currentUser;
if (user?.activeClubId != null) {
  await NotificationService.instance
      .subscribeToClub(user!.activeClubId!);
}

// When viewing a match
await NotificationService.instance.subscribeToMatch(matchId);

// When viewing a tournament
await NotificationService.instance.subscribeToTournament(tournamentId);
```

### 4. Listen to Notifications

```dart
@override
void initState() {
  super.initState();
  
  NotificationService.instance.notificationStream.listen((notification) {
    // Handle notification
    print('Received: ${notification.title}');
    
    // Update UI, navigate, etc.
    _handleNotification(notification);
  });
}
```

---

## Notification Types

### Match Events

**Topic:** `matches_{matchId}`

Trigger on:
- Goal scored
- Yellow card issued
- Red card issued
- Substitution made
- Match started
- Match finished

Example:

```dart
// In MatchService
await notifyMatchEvent(
  matchId: 'match_123',
  type: 'goal',
  title: 'Goal! 🎯',
  body: 'Juan scored - Home 1-0',
  additionalData: {
    'player': 'Juan',
    'minute': '45',
    'score': '1-0'
  },
);
```

### Tournament Events

**Topic:** `tournaments_{tournamentId}`

Trigger on:
- Standings updated
- Phase advanced
- New match scheduled
- Tournament started
- Tournament finished

Example:

```dart
await notifyTournamentEvent(
  tournamentId: 'tournament_456',
  type: 'standings_updated',
  title: 'Tournament Update',
  body: 'Standings updated - Check your position',
  additionalData: {
    'position': 1,
    'points': 9
  },
);
```

### Friendly Match Events

**Topic:** `friendlies_{friendlyId}`

Trigger on:
- Friendly proposed
- Friendly accepted
- Friendly declined
- Friendly started
- Friendly finished

Example:

```dart
await notifyFriendlyEvent(
  friendlyId: 'friendly_789',
  type: 'proposed',
  title: 'Friendly Match Proposed',
  body: 'City FC wants to play a friendly match',
  additionalData: {
    'opponent': 'City FC',
    'date': '2024-01-15'
  },
);
```

### Club Events

**Topic:** `clubs_{clubId}`

Trigger on:
- Team roster updated
- Player added/removed
- Tournament joined
- Club announcement

Example:

```dart
await notifyClubEvent(
  clubId: 'club_101',
  type: 'player_added',
  title: 'New Player',
  body: 'Carlos has joined your club',
  additionalData: {
    'player': 'Carlos',
    'position': 'Striker'
  },
);
```

---

## Testing

### Unit Tests

**Location:** `test/notification_service_test.dart`

Test coverage:
- Service initialization
- FCM token retrieval
- Topic subscription/unsubscription
- Notification stream emission
- RBAC enforcement
- Token refresh handling
- Persistence across app sessions

Run tests:

```bash
flutter test test/notification_service_test.dart
```

### Widget Tests

**Location:** `test/notification_widget_test.dart`

Test coverage:
- Notification UI rendering
- Material 3 design compliance
- SnackBar display
- Badge count updates
- Empty state display
- Notification tile styling

Run tests:

```bash
flutter test test/notification_widget_test.dart
```

### Manual Testing (MVP with Mock FCM)

For MVP development without full FCM backend:

```dart
// Simulate FCM event in NotificationService
await notificationService.simulateFCMEvent(
  title: 'Goal Scored!',
  body: 'Your team scored',
  type: 'match',
  entityId: 'match_123',
);
```

### End-to-End Testing

1. **Subscribe to a match:**
   ```dart
   await NotificationService.instance.subscribeToMatch('match_123');
   ```

2. **Verify subscription:**
   ```dart
   print(NotificationService.instance.subscribedTopics);
   // Output: {matches_match_123}
   ```

3. **Send notification from backend:**
   ```bash
   curl -X POST https://fcm.googleapis.com/fcm/send \
     -H "Authorization: key=YOUR_SERVER_KEY" \
     -H "Content-Type: application/json" \
     -d '{
       "to": "/topics/matches_match_123",
       "notification": {
         "title": "Goal Scored!",
         "body": "Your team scored",
       },
       "data": {
         "type": "match",
         "entityId": "match_123",
         "eventType": "goal"
       }
     }'
   ```

4. **Verify notification received:**
   - Should see Material 3 SnackBar
   - Badge count increases
   - Notification appears in bottom sheet

---

## Deployment

### Firebase Console Setup

1. **Enable Notifications:**
   - Project Settings
   - Cloud Messaging tab
   - Copy Server Key and Sender ID

2. **Create Service Account:**
   - Project Settings
   - Service Accounts
   - Generate new key (JSON)
   - Use for backend authentication

3. **Configure Notification Channels (Android):**
   ```dart
   const androidDetails = AndroidNotificationDetails(
     'football_coaches_channel',
     'Football Coaches Notifications',
     channelDescription: 'Notifications for matches and tournaments',
     importance: Importance.max,
     priority: Priority.high,
   );
   ```

### Production Checklist

- [ ] Firebase project created and configured
- [ ] google-services.json added (Android)
- [ ] GoogleService-Info.plist added (iOS)
- [ ] Push Notifications capability enabled (iOS)
- [ ] FCM permissions requested
- [ ] NotificationService initialized in main.dart
- [ ] Backend configured to send FCM messages
- [ ] RBAC rules implemented
- [ ] Notification UI integrated
- [ ] Tests passing
- [ ] Error handling implemented
- [ ] Offline message storage verified

---

## Security

### Authentication & Authorization

1. **Token Management:**
   - FCM token obtained after Firebase initialization
   - Token automatically refreshed by Firebase
   - Token validated by backend before sending

2. **RBAC Implementation:**
   ```dart
   bool _shouldReceiveNotification(PushNotification notification) {
     final user = AuthService.instance.currentUser;
     if (user == null) return false;

     // Admin/Coach can receive all notifications
     // Fans can receive subscribed entity updates only
     
     if (notification.type == 'match_management' && 
         user.role != 'coach') {
       return false;
     }
     
     return true;
   }
   ```

3. **Backend Validation:**
   - Verify user has access to entity (match, tournament, etc.)
   - Check user role for notification type
   - Validate topic subscription

### Data Privacy

1. **Sensitive Data:**
   - Don't include sensitive info in notification body
   - Use data payload for sensitive content
   - Decrypt on client if needed

2. **Storage:**
   - Notifications stored in memory (list of last 100)
   - Subscriptions persisted in SharedPreferences
   - No sensitive data in persistence

### Network Security

1. **Encryption:**
   - FCM uses TLS/SSL for message delivery
   - Use HTTPS for backend API calls
   - Enable certificate pinning if needed

2. **Validation:**
   - Validate FCM message signature
   - Check timestamp to prevent replay attacks
   - Validate topic format

---

## Troubleshooting

### FCM Token Issues

**Problem:** Token is null
- **Solution:** 
  1. Ensure Firebase is initialized before NotificationService
  2. Check Google Services configuration
  3. Verify device has internet connection

**Problem:** Token keeps refreshing
- **Solution:**
  - This is normal behavior
  - Implement exponential backoff for backend sync
  - Log token refreshes for debugging

### Permission Issues

**Problem:** Notifications not showing (iOS)
- **Solution:**
  1. Check User Notifications permission in Settings
  2. Verify Push Notifications capability is enabled
  3. Ensure GoogleService-Info.plist is correctly configured

**Problem:** Notifications not showing (Android)
- **Solution:**
  1. Check app notification settings
  2. Verify notification channel is created
  3. Check doze mode and battery optimization settings

### Subscription Issues

**Problem:** Not receiving notifications after subscribing
- **Solution:**
  1. Verify subscription successful in logs
  2. Check backend is sending to correct topic
  3. Verify RBAC allows notification
  4. Check network connectivity

**Problem:** Subscriptions lost after app restart
- **Solution:**
  1. Subscriptions are persisted automatically
  2. Check SharedPreferences is working
  3. Re-subscribe to topics on app start if needed

### UI Issues

**Problem:** Badge count not updating
- **Solution:**
  1. Verify notification stream is being listened to
  2. Check setState() is being called
  3. Ensure widget is still mounted

**Problem:** SnackBar not appearing
- **Solution:**
  1. Check ScaffoldMessenger is available
  2. Verify notification is being emitted
  3. Check for other SnackBars blocking

### Backend Integration

**Problem:** App receives FCM messages but doesn't process
- **Solution:**
  1. Verify message handlers are set up
  2. Check notification data format matches
  3. Verify RBAC check isn't blocking

**Problem:** FCM message format issues
- **Solution:**
  - Check required fields: title, body, type, entityId
  - Verify data payload is JSON
  - Test with Firebase Console test notification

---

## API Reference

### NotificationService

```dart
// Static getter
static NotificationService get instance

// Properties
String? get fcmToken
bool get isInitialized
bool get isConnected
Stream<PushNotification> get notificationStream
Stream<bool> get connectionStatusStream
List<PushNotification> get notifications
Set<String> get subscribedTopics

// Methods
Future<void> init({bool requestPermission = true})
Future<void> subscribeToMatch(String matchId)
Future<void> unsubscribeFromMatch(String matchId)
Future<void> subscribeToTournament(String tournamentId)
Future<void> unsubscribeFromTournament(String tournamentId)
Future<void> subscribeToFriendly(String friendlyId)
Future<void> unsubscribeFromFriendly(String friendlyId)
Future<void> subscribeToClub(String clubId)
Future<void> unsubscribeFromClub(String clubId)
void clearAllNotifications()
void clearNotification(PushNotification notification)
int getNotificationCount()
List<PushNotification> getRecentNotifications({int limit = 10})
Future<void> disconnect()
```

### PushNotification

```dart
class PushNotification {
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String type;
  final String? entityId;
  
  factory PushNotification.fromRemoteMessage(RemoteMessage message)
}
```

### NotificationMixin

```dart
// Properties
NotificationService get notificationService
AuthService get authService

// Methods
Future<void> notifyMatchEvent({
  required String matchId,
  required String type,
  required String title,
  required String body,
  Map<String, dynamic>? additionalData,
})

Future<void> notifyTournamentEvent({
  required String tournamentId,
  required String type,
  required String title,
  required String body,
  Map<String, dynamic>? additionalData,
})

Future<void> notifyFriendlyEvent({
  required String friendlyId,
  required String type,
  required String title,
  required String body,
  Map<String, dynamic>? additionalData,
})

Future<void> notifyClubEvent({
  required String clubId,
  required String type,
  required String title,
  required String body,
  Map<String, dynamic>? additionalData,
})

Future<void> notifySystem({
  required String title,
  required String body,
  String? actionUrl,
})

Future<void> notifyBatch(List<Map<String, dynamic>> notifications)

bool shouldNotifyUser()
bool canTriggerNotifications()

Future<void> simulateFCMEvent({
  required String title,
  required String body,
  required String type,
  required String entityId,
  Map<String, dynamic>? data,
})
```

---

## MVP Status

### ✅ Completed

- [x] Firebase Core integration
- [x] Firebase Messaging setup
- [x] NotificationService with singleton pattern
- [x] Topic-based subscriptions (matches, tournaments, friendlies, clubs)
- [x] Local notification display (Material 3)
- [x] Notification UI components
- [x] RBAC enforcement
- [x] Token management
- [x] Subscription persistence
- [x] Unit tests
- [x] Widget tests
- [x] Mock FCM support for testing
- [x] Complete documentation

### 🔄 Ready for Backend Integration

- [ ] Backend FCM sender implementation
- [ ] Real-time notification delivery
- [ ] Deep linking to notification entities
- [ ] Analytics tracking
- [ ] A/B testing notifications
- [ ] User notification preferences

---

## Next Steps

1. **Backend Integration:**
   - Configure FCM server key
   - Implement notification sending logic
   - Set up notification permissions API

2. **Enhanced Features:**
   - User notification preferences
   - Notification grouping
   - Rich notifications with images
   - Custom notification sounds

3. **Analytics:**
   - Track notification delivery
   - User engagement metrics
   - Notification performance

4. **Advanced Features:**
   - Scheduled notifications
   - Notification scheduling
   - Smart notification timing
   - Machine learning for optimal delivery

