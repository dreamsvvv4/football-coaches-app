class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String role; // primary role
  final String? activeClubId; // club context actual
  final String? activeTeamId; // team context actual
  final bool hasCompletedOnboarding; // si pasó onboarding

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.role,
    this.activeClubId,
    this.activeTeamId,
    this.hasCompletedOnboarding = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String? ?? 'coach',
      activeClubId: json['activeClubId'] as String?,
      activeTeamId: json['activeTeamId'] as String?,
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'avatarUrl': avatarUrl,
    'role': role,
    'activeClubId': activeClubId,
    'activeTeamId': activeTeamId,
    'hasCompletedOnboarding': hasCompletedOnboarding,
  };

  // Método para crear copia con cambios (copyWith)
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? role,
    String? activeClubId,
    String? activeTeamId,
    bool? hasCompletedOnboarding,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      activeClubId: activeClubId ?? this.activeClubId,
      activeTeamId: activeTeamId ?? this.activeTeamId,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}
