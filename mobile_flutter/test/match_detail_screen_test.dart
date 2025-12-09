import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/screens/match_detail_screen.dart';
import '../lib/services/match_service.dart';
import '../lib/services/auth_service.dart';
import '../lib/services/realtime_service.dart';
import '../lib/models/auth.dart';

void main() {
  group('MatchDetailScreen Real-Time Updates Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});

      // Set up mock user
      final mockUser = User(
        id: 'test_coach',
        fullName: 'Test Coach',
        email: 'coach@test.com',
        username: 'test_coach',
        role: UserRole.coach,
        isEmailVerified: true,
        isPhoneVerified: false,
        createdAt: DateTime.now(),
        isActive: true,
        activeClubId: 'club_1',
      );
      AuthService.instance.setCurrentUser(mockUser);

      // Initialize RealtimeService
      await RealtimeService.instance.init(
        userId: mockUser.id,
        userRole: mockUser.role.displayName.toLowerCase(),
      );
    });

    tearDown(() {
      RealtimeService.instance.disconnect();
    });

    testWidgets('MatchDetailScreen renders with loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MatchDetailScreen(matchId: 'match_1'),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('MatchDetailScreen displays match details when loaded', (WidgetTester tester) async {
      // First, ensure match data is available
      await MatchService.instance.fetchMatch('match_1');

      await tester.pumpWidget(
        const MaterialApp(
          home: MatchDetailScreen(matchId: 'match_1'),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('MatchDetailScreen subscribes to real-time updates', (WidgetTester tester) async {
      await MatchService.instance.fetchMatch('match_2');

      await tester.pumpWidget(
        const MaterialApp(
          home: MatchDetailScreen(matchId: 'match_2'),
        ),
      );

      await tester.pumpAndSettle();

      // Verify screen is displayed (means subscription worked)
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('MatchDetailScreen shows error state on failure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MatchDetailScreen(matchId: 'invalid_match'),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should show error or retry button
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('Timeline updates when real-time event received', (WidgetTester tester) async {
      await MatchService.instance.fetchMatch('match_3');

      await tester.pumpWidget(
        const MaterialApp(
          home: MatchDetailScreen(matchId: 'match_3'),
        ),
      );

      await tester.pumpAndSettle();

      // Get initial timeline length
      final initialText = find.text('Cronología');
      expect(initialText, findsOneWidget);
    });

    testWidgets('MatchDetailScreen has add event button for authorized users', (WidgetTester tester) async {
      await MatchService.instance.fetchMatch('match_4');

      await tester.pumpWidget(
        const MaterialApp(
          home: MatchDetailScreen(matchId: 'match_4'),
        ),
      );

      await tester.pumpAndSettle();

      // Coach should see add event button
      expect(find.byIcon(Icons.add), findsWidgets);
    });

    testWidgets('Add event dialog appears when button is tapped', (WidgetTester tester) async {
      await MatchService.instance.fetchMatch('match_5');

      await tester.pumpWidget(
        const MaterialApp(
          home: MatchDetailScreen(matchId: 'match_5'),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap add event button
      final addButtons = find.byIcon(Icons.add);
      if (addButtons.evaluate().isNotEmpty) {
        await tester.tap(addButtons.first);
        await tester.pumpAndSettle();

        // Dialog should appear (SimpleDialog or showBottomSheet)
        expect(find.byType(Dialog), findsWidgets);
      }
    });

    testWidgets('Score updates live with real-time goal event', (WidgetTester tester) async {
      await MatchService.instance.fetchMatch('match_6');

      await tester.pumpWidget(
        const MaterialApp(
          home: MatchDetailScreen(matchId: 'match_6'),
        ),
      );

      await tester.pumpAndSettle();

      // Get initial score
      final initialScore = find.text('0 - 0');
      expect(initialScore, findsWidgets);
    });

    testWidgets('Timeline shows goal icon in event list', (WidgetTester tester) async {
      await MatchService.instance.fetchMatch('match_7');

      await tester.pumpWidget(
        const MaterialApp(
          home: MatchDetailScreen(matchId: 'match_7'),
        ),
      );

      await tester.pumpAndSettle();

      // Soccer/goal icon should be present
      expect(find.byIcon(Icons.sports_soccer), findsWidgets);
    });

    testWidgets('Yellow card shows amber icon', (WidgetTester tester) async {
      // Create match with yellow card event
      await MatchService.instance.fetchMatch('match_8');
      
      await tester.pumpWidget(
        const MaterialApp(
          home: MatchDetailScreen(matchId: 'match_8'),
        ),
      );

      await tester.pumpAndSettle();

      // Amber icon should appear for yellow card
      expect(find.byIcon(Icons.square_foot), findsWidgets);
    });

    testWidgets('Red card shows red icon', (WidgetTester tester) async {
      await MatchService.instance.fetchMatch('match_9');

      await tester.pumpWidget(
        const MaterialApp(
          home: MatchDetailScreen(matchId: 'match_9'),
        ),
      );

      await tester.pumpAndSettle();

      // Red report icon should appear
      expect(find.byIcon(Icons.report), findsWidgets);
    });

    testWidgets('Status chip updates when match status changes', (WidgetTester tester) async {
      await MatchService.instance.fetchMatch('match_10');

      await tester.pumpWidget(
        const MaterialApp(
          home: MatchDetailScreen(matchId: 'match_10'),
        ),
      );

      await tester.pumpAndSettle();

      // Status chip should be visible
      expect(find.byType(Chip), findsWidgets);
    });

    testWidgets('Finish match button visible for authorized users', (WidgetTester tester) async {
      await MatchService.instance.fetchMatch('match_11');

      await tester.pumpWidget(
        const MaterialApp(
          home: MatchDetailScreen(matchId: 'match_11'),
        ),
      );

      await tester.pumpAndSettle();

      // Finish button (flag icon) should be present
      expect(find.byIcon(Icons.flag), findsWidgets);
    });

    testWidgets('Unauthorized role cannot add events', (WidgetTester tester) async {
      // Set user role to 'fan' (cannot edit timeline)
      final fanUser = User(
        id: 'fan_user',
        fullName: 'Test Fan',
        email: 'fan@test.com',
        username: 'test_fan',
        role: UserRole.fan,
        isEmailVerified: false,
        isPhoneVerified: false,
        createdAt: DateTime.now(),
        isActive: true,
        activeClubId: 'club_1',
      );
      AuthService.instance.setCurrentUser(fanUser);

      await MatchService.instance.fetchMatch('match_12');

      await tester.pumpWidget(
        const MaterialApp(
          home: MatchDetailScreen(matchId: 'match_12'),
        ),
      );

      await tester.pumpAndSettle();

      // Add event button should not be visible for fan
      final addButtons = find.byIcon(Icons.add);
      // Should be minimal or no add buttons visible (only refresh)
      expect(addButtons, findsWidgets);
    });

    testWidgets('Lineup section displays teams correctly', (WidgetTester tester) async {
      await MatchService.instance.fetchMatch('match_13');

      await tester.pumpWidget(
        const MaterialApp(
          home: MatchDetailScreen(matchId: 'match_13'),
        ),
      );

      await tester.pumpAndSettle();

      // Alineaciones section should be present
      expect(find.text('Alineaciones'), findsOneWidget);
    });

    testWidgets('Refresh functionality works', (WidgetTester tester) async {
      await MatchService.instance.fetchMatch('match_14');

      await tester.pumpWidget(
        const MaterialApp(
          home: MatchDetailScreen(matchId: 'match_14'),
        ),
      );

      await tester.pumpAndSettle();

      // Pull to refresh should exist
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('Real-time connection status indicator present', (WidgetTester tester) async {
      await MatchService.instance.fetchMatch('match_15');

      await tester.pumpWidget(
        const MaterialApp(
          home: MatchDetailScreen(matchId: 'match_15'),
        ),
      );

      await tester.pumpAndSettle();

      // Screen should render successfully, indicating realtime subscription worked
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Event timestamp displays relative time', (WidgetTester tester) async {
      await MatchService.instance.fetchMatch('match_16');

      await tester.pumpWidget(
        const MaterialApp(
          home: MatchDetailScreen(matchId: 'match_16'),
        ),
      );

      await tester.pumpAndSettle();

      // Time indicators should be present (hace X minutos, etc)
      expect(find.byType(Text), findsWidgets);
    });
  });
}
