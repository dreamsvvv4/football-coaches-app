import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/screens/venues_management_screen.dart';
import '../lib/services/venue_service.dart';
import '../lib/services/auth_service.dart';
import '../lib/models/auth.dart';

void main() {
  group('VenuesManagementScreen Widget Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await AuthService.init(prefs);
      await VenueService.instance.init();
      
      // Set up a mock user with coach role
      final mockUser = User(
        id: 'test_user',
        fullName: 'Test Coach',
        email: 'coach@test.com',
        username: 'test_coach',
        role: UserRole.coach,
        isEmailVerified: true,
        isPhoneVerified: false,
        createdAt: DateTime.now(),
        isActive: true,
        activeClubId: 'club1',
      );
      AuthService.instance.setCurrentUser(mockUser);
    });

    testWidgets('VenuesManagementScreen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VenuesManagementScreen(),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Gestión de Recintos'), findsWidgets);
    });

    testWidgets('Search functionality filters venues correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VenuesManagementScreen(),
        ),
      );

      // Find search field
      final searchField = find.byType(TextField);
      expect(searchField, findsWidgets);

      // Type in search
      await tester.enterText(searchField.first, 'campo');
      await tester.pumpAndSettle();

      // Should find filtered results
      final listTiles = find.byType(ListTile);
      expect(listTiles, findsWidgets);
    });

    testWidgets('FAB is visible for authorized roles', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VenuesManagementScreen(),
        ),
      );

      // Coach role should see FAB
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
    });

    testWidgets('FAB opens add venue dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VenuesManagementScreen(),
        ),
      );

      // Tap FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Nuevo Recinto'), findsWidgets);
    });

    testWidgets('Venues list displays venue items', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VenuesManagementScreen(),
        ),
      );

      // Should have ListTiles for each venue
      final listTiles = find.byType(ListTile);
      expect(listTiles, findsWidgets);
    });

    testWidgets('Venue card shows location icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VenuesManagementScreen(),
        ),
      );

      // Find location icons
      final icons = find.byIcon(Icons.location_on);
      expect(icons, findsWidgets);
    });

    testWidgets('Popup menu appears on trailing tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VenuesManagementScreen(),
        ),
      );

      // Tap popup menu button
      final popupMenus = find.byType(PopupMenuButton);
      expect(popupMenus, findsWidgets);
      
      if (popupMenus.evaluate().isNotEmpty) {
        await tester.tap(popupMenus.first);
        await tester.pumpAndSettle();

        // Menu options should appear
        expect(find.text('Editar'), findsOneWidget);
        expect(find.text('Eliminar'), findsOneWidget);
      }
    });

    testWidgets('Add venue dialog has required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VenuesManagementScreen(),
        ),
      );

      // Open dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Check for required fields
      expect(find.byType(TextField), findsWidgets);
      expect(find.text('Nombre del recinto'), findsOneWidget);
      expect(find.text('Latitud'), findsOneWidget);
      expect(find.text('Longitud'), findsOneWidget);
    });

    testWidgets('Empty state shows when no venues exist', (WidgetTester tester) async {
      // Clear all venues
      final allVenues = VenueService.instance.getAllVenues();
      for (final venue in List.from(allVenues)) {
        await VenueService.instance.deleteVenue(venue.id);
      }

      await tester.pumpWidget(
        const MaterialApp(
          home: VenuesManagementScreen(),
        ),
      );

      // Empty state should show
      expect(find.byIcon(Icons.location_off), findsOneWidget);
      expect(find.text('Sin recintos'), findsOneWidget);
    });
  });
}
