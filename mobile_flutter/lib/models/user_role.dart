enum UserRoleType {
  superadmin,
  adminClub,
  entrenador,
  padre,
  jugador,
}

class UserRole {
  final String userId;
  final String clubId;
  final String? teamId;
  final UserRoleType role;
  final DateTime assignedAt;

  UserRole({
    required this.userId,
    required this.clubId,
    this.teamId,
    required this.role,
    required this.assignedAt,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) => UserRole(
    userId: json['userId'] as String,
    clubId: json['clubId'] as String,
    teamId: json['teamId'] as String?,
    role: UserRoleType.values.firstWhere((e) => e.toString().split('.').last == (json['role'] as String)),
    assignedAt: DateTime.parse(json['assignedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'clubId': clubId,
    'teamId': teamId,
    'role': role.toString().split('.').last,
    'assignedAt': assignedAt.toIso8601String(),
  };

  bool appliesToClub(String clubId) => this.clubId == clubId;
  bool appliesToTeam(String teamId) => this.teamId == teamId;
}

class ActiveContext {
  String clubId;
  String? teamId;
  UserRoleType role;

  ActiveContext({required this.clubId, this.teamId, required this.role});
}
