import 'user_role.dart';

enum Permission {
  // SuperAdmin
  managePlatform,
  manageClubs,
  managePlans,
  viewLogs,
  impersonateUser,
  manageFeatureFlags,
  // Admin Club
  createTeam,
  editTeam,
  deleteTeam,
  assignRoles,
  createClubEvent,
  manageFriendly,
  manageCallUps,
  editBranding,
  viewClubStats,
  sendClubNotifications,
  // Entrenador
  manageOwnTeam,
  createTraining,
  createFriendlyRequest,
  callPlayers,
  sendTeamNotifications,
  // Padre
  viewTeam,
  viewEvents,
  respondToCallUp,
  // Jugador
  viewPersonalStats,
}

const rolePermissions = {
  UserRoleType.superadmin: Permission.values,
  UserRoleType.adminClub: [
    Permission.createTeam,
    Permission.editTeam,
    Permission.deleteTeam,
    Permission.assignRoles,
    Permission.createClubEvent,
    Permission.manageFriendly,
    Permission.manageCallUps,
    Permission.editBranding,
    Permission.viewClubStats,
    Permission.sendClubNotifications,
    Permission.viewTeam,
    Permission.viewEvents,
  ],
  UserRoleType.entrenador: [
    Permission.manageOwnTeam,
    Permission.createTraining,
    Permission.createFriendlyRequest,
    Permission.callPlayers,
    Permission.sendTeamNotifications,
    Permission.viewTeam,
    Permission.viewEvents,
  ],
  UserRoleType.padre: [
    Permission.viewTeam,
    Permission.viewEvents,
    Permission.respondToCallUp,
  ],
  UserRoleType.jugador: [
    Permission.viewTeam,
    Permission.viewEvents,
    Permission.viewPersonalStats,
  ],
};
