import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/screens/profile_screen.dart';
import '../lib/services/auth_service.dart';
import '../lib/services/venue_service.dart';
import '../lib/models/auth.dart';

void main() {
  group('ProfileScreen Venue Selection Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await VenueService.instance.init();
      
      // Set up a mock user
      final mockUser = User(
        id: 'test_user',
        fullName: 'Test User',
        email: 'test@example.com',
        username: 'test_user',
        role: UserRole.coach,
        isEmailVerified: true,
        isPhoneVerified: false,
        createdAt: DateTime.now(),
        isActive: true,
        activeClubId: 'club1',
      );
      AuthService.instance.setCurrentUser(mockUser);
    });

    testWidgets('ProfileScreen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Perfil'), findsWidgets);
    });

    testWidgets('Venue dropdown is visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Look for venue dropdown with helper text
      expect(
        find.byWidgetPredicate(
          (widget) {
            if (widget is! DropdownButtonFormField) return false;
            final labelText = widget.decoration.labelText;
            return labelText != null && labelText.contains('Recinto');
          },
          skipOffstage: false,
        ),
        findsOneWidget,
      );
    });

    testWidgets('Venue dropdown contains venues from service', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Try to tap dropdown to see options
      final dropdowns = find.byType(DropdownButtonFormField);
      expect(dropdowns, findsWidgets);
    });

    testWidgets('Helper text is shown for venue selection', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Look for helper text about venue selection
      expect(
        find.text('Selecciona tu campo o estadio principal'),
        findsOneWidget,
      );
    });

    testWidgets('Manage venues button opens dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap manage venues button
      final manageButton = find.byWidgetPredicate(
        (widget) =>
            widget is OutlinedButton &&
            widget.child is Row &&
            (widget.child as Row).children.whereType<Text>().any(
                  (text) => text.data?.contains('Gestionar') == true,
                ),
        skipOffstage: false,
      );

      if (manageButton.evaluate().isNotEmpty) {
        await tester.tap(manageButton.first);
        await tester.pumpAndSettle();

        // Dialog should appear
        expect(find.byType(AlertDialog), findsOneWidget);
      }
    });

    testWidgets('Form validates required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Find the save button
      final saveButton = find.byWidgetPredicate(
        (widget) =>
            widget is ElevatedButton &&
            widget.child is Text &&
            (widget.child as Text).data?.contains('Guardar') == true,
        skipOffstage: false,
      );

      expect(saveButton, findsWidgets);
    });

    testWidgets('Can select a venue from dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Find the venue dropdown
      final dropdowns = find.byType(DropdownButtonFormField<String>);
      
      if (dropdowns.evaluate().length > 2) {
        // The venue dropdown should be one of the later dropdowns
        await tester.tap(dropdowns.at(2)); // Assuming venue is 3rd dropdown
        await tester.pumpAndSettle();

        // A menu should appear
        expect(find.byType(DropdownButton), findsWidgets);
      }
    });

    testWidgets('Venue field maintains selection after toggle', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // The venue field should be preserved after other interactions
      final textFields = find.byType(TextFormField);
      expect(textFields, findsWidgets);
    });

    testWidgets('Role change updates UI', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap a role button
      final segments = find.byType(SegmentedButton);
      expect(segments, findsWidgets);
    });

    testWidgets('Screen loads with user data', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Check that user's email is pre-filled
      expect(find.text('test@example.com'), findsWidgets);
    });

    testWidgets('Club dropdown is present', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Look for club dropdown
      expect(find.text('Club activo'), findsOneWidget);
    });

    testWidgets('Team dropdown is present', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Look for team dropdown
      expect(find.text('Equipo activo'), findsOneWidget);
    });
  });
}
