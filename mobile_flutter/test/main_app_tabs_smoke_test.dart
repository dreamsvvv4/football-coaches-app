import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_flutter/models/auth.dart';
import 'package:mobile_flutter/models/club.dart';
import 'package:mobile_flutter/screens/home/main_app.dart';
import 'package:mobile_flutter/services/auth_service.dart';
import 'package:mobile_flutter/services/club_registry.dart';

void main() {
  group('MainApp bottom tabs smoke', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await AuthService.init(prefs);

      // Seed demo clubs so Equipos has context.
      ClubRegistry.clubs = [
        Club(
          id: 'club1',
          name: 'Real Madrid CF',
          city: 'Madrid',
          country: 'España',
          crestUrl: null,
          description: 'El club más exitoso de Europa',
          foundedYear: 1902,
        ),
      ];

      final user = User(
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
      AuthService.instance.setCurrentUser(user);
    });

    testWidgets('tabs render without blank screens', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthService>.value(
          value: AuthService.instance,
          child: const MaterialApp(home: MainApp()),
        ),
      );
      await tester.pumpAndSettle();

      // Calendario
      await tester.tap(find.byIcon(Icons.calendar_month_outlined));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text('Calendario')),
        findsOneWidget,
      );

      // Equipos
      await tester.tap(find.byIcon(Icons.groups_outlined));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text('Plantilla del equipo')),
        findsOneWidget,
      );

      // Amistosos
      await tester.tap(find.byIcon(Icons.handshake_outlined));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text('Amistosos')),
        findsOneWidget,
      );
      expect(find.text('Coordina tus amistosos'), findsOneWidget);

      // Perfil
      await tester.tap(find.byIcon(Icons.person_outlined));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text('Perfil')),
        findsOneWidget,
      );
    });
  });
}
