import '../models/role.dart';
import '../models/permissions.dart';
import '../models/user_role.dart' as user_roles;
import '../services/auth_service.dart';

class PermissionService {
  // Singleton
  static final PermissionService instance = PermissionService._internal();
  PermissionService._internal();

  // Define permissions per role. Keys are permission identifiers.
  // Add or change permissions here as app features grow.
  // Deprecated: use enums only
  // final Map<Role, Set<String>> _rolePermissions = {...}


  // Nuevo: obtener permisos como enums
  static List<Permission> getPermissionsForContext(dynamic context) {
    if (context == null || (context is Map && context['role'] == null)) return [];
    var roleType = context is Map
        ? context['role']
        : (context.role ?? context.toString());
    // Mapear a UserRoleType si es necesario
    if (roleType is String) {
      try {
        roleType = user_roles.UserRoleType.values.firstWhere((e) => e.toString().split('.').last == roleType);
      } catch (_) {
        return [];
      }
    }
    if (roleType is user_roles.UserRoleType && rolePermissions.containsKey(roleType)) {
      return List<Permission>.from(rolePermissions[roleType]!);
    }
    return [];
  }

  // Helpers actualizados para enums
  static bool canCreateTournament(dynamic context) {
    final perms = getPermissionsForContext(context);
    // Un torneo se puede crear si tiene permiso de crear equipo o evento de club
    return perms.contains(Permission.createTeam) || perms.contains(Permission.createClubEvent);
  }
  static bool canEditTeam(dynamic context) {
    final perms = getPermissionsForContext(context);
    return perms.contains(Permission.editTeam);
  }
  static bool canRecordMatch(dynamic context) {
    final perms = getPermissionsForContext(context);
    // Usar manageFriendly para registrar partidos amistosos
    return perms.contains(Permission.manageFriendly);
  }

  static bool canUsePremiumPlanner(dynamic context) {
    final perms = getPermissionsForContext(context);
    // Usar createTraining como permiso premium de planner
    return perms.contains(Permission.createTraining);
  }
}
