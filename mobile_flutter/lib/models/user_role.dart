/// Representa la relación entre un User, su Role y el contexto (Club/Team)
/// Un usuario puede ser coach en un equipo y admin en otro club
class UserRole {
  final String userId;
  final String role; // coach, player, clubAdmin, referee, fan, superadmin
  final String? clubId; // contexto: a qué club pertenece
  final String? teamId; // contexto: a qué equipo pertenece
  final DateTime assignedAt;

  UserRole({
    required this.userId,
    required this.role,
    this.clubId,
    this.teamId,
    required this.assignedAt,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) => UserRole(
    userId: json['userId'] as String,
    role: json['role'] as String,
    clubId: json['clubId'] as String?,
    teamId: json['teamId'] as String?,
    assignedAt: DateTime.parse(json['assignedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'role': role,
    'clubId': clubId,
    'teamId': teamId,
    'assignedAt': assignedAt.toIso8601String(),
  };

  // Verificar si este rol aplica en cierto contexto
  bool appliesToClub(String clubId) => this.clubId == clubId;
  bool appliesToTeam(String teamId) => this.teamId == teamId;
}
