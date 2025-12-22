import '../../services/club_registry.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/auth.dart';
import '../../services/auth_service.dart';
import '../home_screen_enhanced.dart';
import '../tournament_screen.dart';
import '../home/home_dashboard.dart';
import '../../feature_flags.dart';
import '../friendly_match_screen.dart';
import '../team_screen.dart';
import 'profile_screen.dart';
import '../calendar_screen.dart';

/// Main application screen with role-based bottom navigation
class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  Widget _navIcon(IconData icon, String label) {
    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        child: Icon(icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        final user = authService.currentUser;
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Navigation tabs and screens
        final tabs = _getTabsForRole(user.role);
        final screens = _buildScreens(user.role, tabs.length);

        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: tabs.map((tab) {
              final label = tab['label'] as String;
              final icon = tab['icon'] as IconData;
              return NavigationDestination(
                icon: _navIcon(icon, label),
                label: label,
              );
            }).toList(),
          ),
          // Use per-screen FABs to avoid duplication; global FAB disabled.
          floatingActionButton: null,
        );
      },
    );
  }

  /// Get available navigation tabs based on user role
  List<Map<String, dynamic>> _getTabsForRole(UserRole role) {
    // Basic set for all roles
    final tabs = <Map<String, dynamic>>[
      {'label': 'Inicio', 'icon': Icons.home_outlined},
      {'label': 'Calendario', 'icon': Icons.calendar_month_outlined},
      {'label': 'Equipos', 'icon': Icons.groups_outlined},
      {'label': 'Amistosos', 'icon': Icons.handshake_outlined},
      if (FeatureFlags.tournamentsEnabled)
        {'label': 'Torneos', 'icon': Icons.emoji_events_outlined},
      {'label': 'Perfil', 'icon': Icons.person_outlined},
    ];

    // Could tailor per role later
    return tabs;
  }

  /// Build screens list based on role
  List<Widget> _buildScreens(UserRole role, int tabCount) {
    final clubId = AuthService.instance.activeContext?.clubId;
    final club = ClubRegistry.getClubById(clubId);
    final screens = <Widget>[
      const HomeDashboard(),
      const CalendarScreen(),
      club != null
          ? TeamScreen(club: club)
          : const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No hay club activo. Ve a Perfil para seleccionar un club.'),
              ),
            ),
      const FriendlyMatchScreen(),
      const ProfileScreen(),
    ];
    if (FeatureFlags.tournamentsEnabled) {
      screens.insert(4, const TournamentScreen());
    }
    return screens.sublist(0, tabCount);
  }

  /// Build contextual FAB based on role
  FloatingActionButton? _buildFAB(BuildContext context, UserRole role) {
    // Global FAB disabled; rely on each screen's contextual FABs.
    return null;
  }

  /// Show menu for creating new items
  void _showCreateMenu(BuildContext context, UserRole role) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Create New',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.sports_soccer_outlined),
                title: const Text('Friendly Match'),
                subtitle: const Text('Schedule a new match'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.emoji_events_outlined),
                title: const Text('Tournament'),
                subtitle: const Text('Create a new tournament'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.groups_outlined),
                title: const Text('Team'),
                subtitle: const Text('Add a new team'),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
