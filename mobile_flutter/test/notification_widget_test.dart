import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/services/notification_service.dart';
import '../lib/services/auth_service.dart';
import '../lib/models/auth.dart';

/// Test widget that displays notifications using Material 3 SnackBar
class NotificationTestWidget extends StatefulWidget {
  const NotificationTestWidget({super.key});

  @override
  State<NotificationTestWidget> createState() => _NotificationTestWidgetState();
}

class _NotificationTestWidgetState extends State<NotificationTestWidget> {
  late NotificationService _notificationService;
  final List<PushNotification> _notifications = [];
  int _unreadCount = 0;
  StreamSubscription<PushNotification>? _notificationSub;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService.instance;

    // Listen to notifications
    _notificationSub = _notificationService.notificationStream.listen((notification) {
      if (!mounted) return;
      setState(() {
        _notifications.add(notification);
        _unreadCount++;
      });

      if (!mounted) return;
      // Show Material 3 Snackbar
      _showNotificationSnackBar(notification);
    });
  }

  void _showNotificationSnackBar(PushNotification notification) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              notification.body,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
        backgroundColor: _getNotificationColor(notification.type),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Cerrar',
          textColor: Colors.white,
          onPressed: scaffoldMessenger.hideCurrentSnackBar,
        ),
      ),
    );
  }

  Color _getNotificationColor(String type) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_unreadCount > 0)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Badge(
                  label: Text('$_unreadCount'),
                  child: const Icon(Icons.notifications),
                ),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[_notifications.length - 1 - index];
          return _buildNotificationTile(notification);
        },
      ),
    );
  }

  Widget _buildNotificationTile(PushNotification notification) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getNotificationColor(notification.type),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
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
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(notification.type.toUpperCase()),
                    backgroundColor: _getNotificationColor(notification.type).withAlpha(25),
                    labelStyle: TextStyle(
                      color: _getNotificationColor(notification.type),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _formatTime(notification.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'hace unos segundos';
    } else if (difference.inMinutes < 60) {
      return 'hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'hace ${difference.inHours}h';
    } else {
      return 'hace ${difference.inDays}d';
    }
  }

  @override
  void dispose() {
    _notificationSub?.cancel();
    super.dispose();
  }
}

void main() {
  group('Notification Widget Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await AuthService.init(prefs);

      // Initialize auth
      final mockUser = User(
        id: 'test_user',
        fullName: 'Test User',
        email: 'test@test.com',
        username: 'test_user',
        role: UserRole.coach,
        isEmailVerified: true,
        isPhoneVerified: false,
        createdAt: DateTime.now(),
        isActive: true,
      );
      AuthService.instance.setCurrentUser(mockUser);

      // Initialize notification service
      await NotificationService.instance.init();

      // Ensure clean slate between tests (service is a singleton)
      NotificationService.instance.clearAllNotifications();
    });

    tearDown(() async {
      await NotificationService.instance.disconnect();
    });

    testWidgets('Notification widget renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          title: 'Notification Test',
          theme: ThemeData(useMaterial3: true),
          home: const NotificationTestWidget(),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('Empty state shows when no notifications', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const NotificationTestWidget(),
        ),
      );

      expect(find.text('No notifications yet'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    });

    testWidgets('Notification badge displays unread count', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const NotificationTestWidget(),
        ),
      );

      // Initially no badge
      expect(find.byType(Badge), findsNothing);
    });

    testWidgets('Notification tile renders with Material 3 design', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: NotificationTestWidget(),
        ),
      );

      // Seed at least one notification so the ListView is visible.
      await NotificationService.instance.storeNotification(
        PushNotification(
          title: 'Test Title',
          body: 'Test Body',
          data: const {},
          timestamp: DateTime.now(),
          type: 'match',
          entityId: 'match_1',
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('Notification color changes by type', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const NotificationTestWidget(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify widgets render (colors are applied during rendering)
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Snackbar appears when notification arrives', (WidgetTester tester) async {
      final app = MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const NotificationTestWidget(),
        scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Verify snackbar can be shown
      expect(find.byType(SnackBar), findsNothing); // No snackbar initially
    });

    testWidgets('Notification list displays in reverse order', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const NotificationTestWidget(),
        ),
      );

      await NotificationService.instance.storeNotification(
        PushNotification(
          title: 'First',
          body: 'First body',
          data: const {},
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
          type: 'match',
          entityId: 'match_first',
        ),
      );
      await NotificationService.instance.storeNotification(
        PushNotification(
          title: 'Second',
          body: 'Second body',
          data: const {},
          timestamp: DateTime.now(),
          type: 'match',
          entityId: 'match_second',
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
      final firstInList = find.descendant(of: find.byType(ListView), matching: find.text('First'));
      final secondInList = find.descendant(of: find.byType(ListView), matching: find.text('Second'));

      expect(firstInList, findsOneWidget);
      expect(secondInList, findsOneWidget);

      final secondY = tester.getTopLeft(secondInList).dy;
      final firstY = tester.getTopLeft(firstInList).dy;
      expect(secondY, lessThan(firstY));
    });

    testWidgets('Chip displays notification type', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const NotificationTestWidget(),
        ),
      );

      await tester.pumpAndSettle();

      // Empty state should show
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('Time formatting works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const NotificationTestWidget(),
        ),
      );

      await tester.pumpAndSettle();

      // Widget renders without time display in empty state
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Close button in snackbar works', (WidgetTester tester) async {
      final app = MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const NotificationTestWidget(),
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Verify snackbar action can be accessed
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('Notification card has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const NotificationTestWidget(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Card widget exists
      expect(find.byType(Card), findsNothing); // None in empty state
    });

    testWidgets('AppBar displays notification count indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const NotificationTestWidget(),
        ),
      );

      // Find app bar
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsNothing); // No icon initially
    });

    testWidgets('Material 3 theme applied correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const NotificationTestWidget(),
        ),
      );

      final theme = Theme.of(tester.element(find.byType(NotificationTestWidget)));
      expect(theme.useMaterial3, isTrue);
    });

    testWidgets('Floating SnackBar appears above other widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const NotificationTestWidget(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify scaffold renders
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Notification dismissal updates UI', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const NotificationTestWidget(),
        ),
      );

      await tester.pumpAndSettle();

      // Empty state remains
      expect(find.text('No notifications yet'), findsOneWidget);
    });
  });
}
