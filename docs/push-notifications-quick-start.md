# Push Notifications Quick Start Guide

## 5-Minute Setup

### 1. Verify Dependencies

All required dependencies are already in `pubspec.yaml`:

```bash
cd mobile_flutter
flutter pub get
```

### 2. Initialize in App

Already configured in `main.dart`:

```dart
// Initialize Firebase
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

// Initialize NotificationService
await NotificationService.instance.init(requestPermission: true);
```

### 3. Start Receiving Notifications

**Option A: Manual Subscription**

```dart
// In any screen or service
await NotificationService.instance.subscribeToMatch('match_123');
await NotificationService.instance.subscribeToTournament('tournament_456');
await NotificationService.instance.subscribeToClub('club_789');
```

**Option B: Automatic on Login**

```dart
// In auth_service.dart after successful login
if (user.activeClubId != null) {
  await NotificationService.instance.subscribeToClub(user.activeClubId!);
}
```

### 4. Listen to Notifications

```dart
@override
void initState() {
  super.initState();
  
  NotificationService.instance.notificationStream.listen((notification) {
    print('🔔 ${notification.title}: ${notification.body}');
    // Handle notification
  });
}
```

### 5. Test with Mock Notifications

```dart
// In NotificationService
await notificationService.simulateFCMEvent(
  title: 'Goal Scored! ⚽',
  body: 'Juan scored - Home 1-0',
  type: 'match',
  entityId: 'match_123',
  data: {
    'player': 'Juan',
    'minute': '45',
    'score': '1-0',
  },
);
```

---

## Platform Configuration

### Android Setup

1. **Add google-services.json:**
   ```
   android/app/google-services.json
   ```

2. **Update android/build.gradle:**
   ```gradle
   buildscript {
     dependencies {
       classpath 'com.google.gms:google-services:4.3.15'
     }
   }
   ```

3. **Update android/app/build.gradle:**
   ```gradle
   plugins {
     id 'com.google.gms.google-services'
   }
   ```

### iOS Setup

1. **Add GoogleService-Info.plist:**
   - Drag to Xcode: `ios/Runner`
   - Target: Runner

2. **Enable Push Notifications (Xcode):**
   - Runner target → Signing & Capabilities
   - "+ Capability" → Push Notifications

3. **Update iOS minimum version:**
   ```yaml
   # ios/Podfile
   platform :ios, '12.0'
   ```

---

## Usage Examples

### Example 1: Subscribe to Match

```dart
// In match_detail_screen.dart
@override
void initState() {
  super.initState();
  
  // Subscribe to match notifications
  NotificationService.instance.subscribeToMatch(widget.matchId);
  
  // Listen for updates
  NotificationService.instance.notificationStream
    .where((n) => n.entityId == widget.matchId)
    .listen((notification) {
      setState(() {
        // Update UI with notification
        _handleMatchEvent(notification);
      });
    });
}

@override
void dispose() {
  // Unsubscribe when leaving
  NotificationService.instance.unsubscribeFromMatch(widget.matchId);
  super.dispose();
}
```

### Example 2: Trigger Match Goal Notification

```dart
// In match_service.dart
void addEvent(String matchId, MatchEvent event) {
  // ... existing logic ...
  
  if (event.type == 'goal') {
    // Trigger notification
    NotificationService.instance.subscribeToMatch(matchId);
  }
}
```

### Example 3: Handle Notification in UI

```dart
// In home_screen.dart
NotificationIndicator(
  onPressed: () {
    showModalBottomSheet(
      context: context,
      builder: (context) => const NotificationBottomSheet(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  },
)
```

---

## Testing

### Run Unit Tests

```bash
flutter test test/notification_service_test.dart
```

**Tests cover:**
- Service initialization
- Topic subscription/unsubscription
- Notification emission
- Token management
- RBAC enforcement

### Run Widget Tests

```bash
flutter test test/notification_widget_test.dart
```

**Tests cover:**
- UI component rendering
- Material 3 design compliance
- Badge updates
- SnackBar display

### Manual Testing Steps

1. **Test Initialization:**
   ```bash
   flutter run --debug
   ```
   - Check console for "NotificationService initialized successfully"

2. **Test Subscription:**
   - Open DevTools
   - In console, check `NotificationService.instance.subscribedTopics`
   - Should see "matches_match_123" after subscribing

3. **Test Notification Display:**
   - Tap notification bell icon in AppBar
   - Should show NotificationBottomSheet
   - Simulate event to see SnackBar appear

---

## Architecture Decisions

### Why Singleton?

```dart
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  static NotificationService get instance => _instance;
}
```

**Benefits:**
- Single FCM connection
- Shared token management
- Centralized RBAC
- Easy access throughout app

### Why StreamControllers?

```dart
final _notificationStreamController = StreamController<PushNotification>.broadcast();
Stream<PushNotification> get notificationStream => _notificationStreamController.stream;
```

**Benefits:**
- Multiple listeners
- Reactive updates
- Decoupled components
- Easy testing with `.listen()`

### Why Topic-Based Subscriptions?

```dart
// matches_123, tournaments_456, etc.
await _firebaseMessaging.subscribeToTopic(topic);
```

**Benefits:**
- Scalable server-side
- Granular control
- Efficient filtering
- No device list management

### Why Persist Subscriptions?

```dart
// In SharedPreferences
final subscriptions = _getPersistedSubscriptions();
for (final sub in subscriptions) {
  await _firebaseMessaging.subscribeToTopic(sub.topic);
}
```

**Benefits:**
- Survive app restart
- Background re-subscription
- User preferences
- Offline-ready

---

## Common Issues & Solutions

### Issue: "NotificationService is null"

**Solution:** Ensure initialization in main():

```dart
await NotificationService.instance.init(requestPermission: true);
```

### Issue: "Notifications not showing"

**Solution:** Check:
1. Is RBAC blocking? → Check user role
2. Is user subscribed? → Check `subscribedTopics`
3. Is notification proper? → Check title/body/data format
4. Is device online? → Check connectivity

### Issue: "Badge count not updating"

**Solution:** Ensure listener is attached:

```dart
NotificationService.instance.notificationStream.listen((notification) {
  setState(() {
    _notificationCount++;
  });
});
```

### Issue: "Subscriptions lost after restart"

**Solution:** They're automatically restored. If not:

```dart
@override
void initState() {
  super.initState();
  
  // Re-subscribe if needed
  final user = AuthService.instance.currentUser;
  if (user?.activeClubId != null) {
    NotificationService.instance.subscribeToClub(user!.activeClubId!);
  }
}
```

---

## Key Files

| File | Purpose |
|------|---------|
| `lib/services/notification_service.dart` | Core service |
| `lib/services/notification_mixin.dart` | Trigger helpers |
| `lib/widgets/notification_indicator.dart` | UI components |
| `lib/firebase_options.dart` | Firebase config |
| `lib/main.dart` | Initialization |
| `test/notification_service_test.dart` | Unit tests |
| `test/notification_widget_test.dart` | Widget tests |
| `docs/push-notifications-implementation.md` | Full guide |

---

## Next Steps

1. **Configure Firebase Project:**
   - Download google-services.json (Android)
   - Download GoogleService-Info.plist (iOS)
   - Configure backend FCM credentials

2. **Backend Integration:**
   - Implement FCM sender in backend
   - Set up notification permissions API
   - Create notification schedule system

3. **Enhanced Features:**
   - User notification preferences
   - Rich notifications with images
   - Deep linking support
   - Analytics tracking

---

## Support

For more details, see:
- [Full Implementation Guide](./push-notifications-implementation.md)
- [NotificationService API](./notification_service.dart)
- [Test Coverage](../test/notification_service_test.dart)

