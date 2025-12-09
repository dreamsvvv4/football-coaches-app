import '../models/role.dart';
import '../services/auth_service.dart';

class PermissionService {
  // Singleton
  static final PermissionService instance = PermissionService._internal();
  PermissionService._internal();

  // Define permissions per role. Keys are permission identifiers.
  // Add or change permissions here as app features grow.
  final Map<Role, Set<String>> _rolePermissions = {
    Role.coach: {
      'teams:read',
      'teams:write',
      'matches:read',
      'matches:write',
      'tournaments:read',
      'tournaments:write',
    },
    Role.player: {
      'teams:read',
      'matches:read',
      'tournaments:read',
    },
    Role.clubAdmin: {
      'teams:read',
      'teams:write',
      'clubs:write',
      'tournaments:read',
      'tournaments:write',
    },
    Role.referee: {
      'matches:read',
      'matches:write',
    },
    Role.fan: {
      'tournaments:read',
      'matches:read',
    },
    Role.superadmin: {
      'teams:read',
      'teams:write',
      'clubs:write',
      'tournaments:read',
      'tournaments:write',
      'users:write',
      'system:admin',
    },
  };

  // Check by permission string
  bool hasPermission(String permission) {
    final user = AuthService.instance.currentUser;
    if (user == null) return false;

    // First check contextual roles assigned to the user (if any)
    final roles = AuthService.instance.currentUserRoles;
    if (roles.isNotEmpty) {
      for (final roleStr in roles) {
        Role roleEnum;
        try {
          roleEnum = Role.values.firstWhere((r) => r.toString().split('.').last == roleStr);
        } catch (_) {
          continue;
        }
        final perms = _rolePermissions[roleEnum];
        if (perms == null) continue;
        if (perms.contains(permission)) return true;
      }
    }

    // Fallback to primary role on user model
    Role role;
    try {
      final roleStr = user.role is String
          ? (user.role as String)
          : user.role.toString().split('.').last;
      role = Role.values.firstWhere((r) => r.toString().split('.').last == roleStr);
    } catch (_) {
      role = Role.coach;
    }
    final perms = _rolePermissions[role];
    if (perms == null) return false;
    return perms.contains(permission);
  }

  // Convenience helpers
  bool canCreateTournament() => hasPermission('tournaments:write');
  bool canEditTeam() => hasPermission('teams:write');
  bool canRecordMatch() => hasPermission('matches:write');

  // Premium planner access: allow coaches, club admins, superadmins
  bool canUsePremiumPlanner() {
    final user = AuthService.instance.currentUser;
    if (user == null) return false;
    final roleStr = user.role.toString().split('.').last;
    return roleStr == 'coach' || roleStr == 'clubAdmin' || roleStr == 'superadmin';
  }
}
