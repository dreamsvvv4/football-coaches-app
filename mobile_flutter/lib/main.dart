import 'screens/event_creator_screen.dart';
import 'screens/callups_screen.dart';
import 'screens/training_rules_screen.dart';
import 'screens/announcements_screen.dart';
import 'screens/team_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth/auth_wrapper.dart';
import 'services/club_event_service.dart';
import 'models/club_event.dart';
import 'screens/home/main_app.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'services/friendly_match_service.dart';
import 'screens/convocatoria_flow_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences for auth system
  final prefs = await SharedPreferences.getInstance();
  final authService = AuthService(prefs);

  // Initialize theme provider
  final themeProvider = ThemeProvider();
  await themeProvider.init();

  // Bootstrap demo data en debug y crear partido premium de ejemplo
  assert(() {
    try {
      FriendlyMatchService.instance.bootstrapSampleData();
      ClubEventService.instance.createEvent(
        ClubEvent(
          id: 'match_demo_001',
          title: 'Partido vs Real Madrid',
          description: 'Partido oficial de liga. Uniforme blanco. Campo principal. Llegar 30 minutos antes. Notas: Ser puntuales.',
          start: DateTime.now().add(const Duration(days: 2, hours: 9)),
          end: DateTime.now().add(const Duration(days: 2, hours: 11)),
          type: ClubEventType.match,
          scope: ClubEventScope.team,
          teamId: 'team_001',
          createdByUserId: 'user_coach_001',
          attendees: const [],
        ),
        notify: false,
      );
    } catch (_) {}
    return true;
  }());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => authService),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => themeProvider),
      ],
      child: Builder(
        builder: (context) {
          final theme = context.watch<ThemeProvider>();
          return MaterialApp(
            title: 'Football Coaches',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: theme.themeMode,
            routes: {
              '/home': (context) => const MainApp(),
              '/calendar': (context) => const MainApp(),
              '/event_creator': (context) => const EventCreatorScreen(),
              '/callups': (context) => const ConvocatoriaFlowScreen(),
              '/training_rules': (context) => const TrainingRulesScreen(),
              '/announcements': (context) => const AnnouncementsScreen(),
              '/team_chat': (context) => const TeamChatScreen(),
              '/branding': (context) => const Placeholder(),
              '/convocatoria': (context) => const ConvocatoriaFlowScreen(),
            },
            home: AuthWrapper(
              homeBuilder: () => const MainApp(),
            ),
          );
        },
      ),
    ),
  );
}
// App bootstraps directly with MaterialApp under MultiProvider
