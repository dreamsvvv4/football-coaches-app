import 'package:equatable/equatable.dart';

/// User roles for RBAC
enum UserRole {
  coach,
  player,
  staff,
  referee,
  fan,
  superadmin,
}

/// Extension to get role display name
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.coach:
        return 'Coach';
      case UserRole.player:
        return 'Player';
      case UserRole.staff:
        return 'Staff';
      case UserRole.referee:
        return 'Referee';
      case UserRole.fan:
        return 'Fan';
      case UserRole.superadmin:
        return 'Admin';
    }
  }

  String get description {
    switch (this) {
      case UserRole.coach:
        return 'Manage teams, matches, and training sessions';
      case UserRole.player:
        return 'View matches, training info, and personal stats';
      case UserRole.staff:
        return 'Assist with team management and coordination';
      case UserRole.referee:
        return 'Officiate matches and manage game events';
      case UserRole.fan:
        return 'Follow teams and stay updated with matches';
      case UserRole.superadmin:
        return 'Full system administration';
    }
  }

  static UserRole fromDisplayName(String name) {
    switch (name.toLowerCase()) {
      case 'coach':
        return UserRole.coach;
      case 'player':
        return UserRole.player;
      case 'staff':
        return UserRole.staff;
      case 'referee':
        return UserRole.referee;
      case 'fan':
        return UserRole.fan;
      case 'admin':
      case 'superadmin':
        return UserRole.superadmin;
      default:
        return UserRole.coach; // Default fallback
    }
  }
}

/// User model
class User extends Equatable {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final UserRole role;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;
  final Map<String, dynamic>? metadata;
  final String? activeClubId;
  final String? activeTeamId;
  final String? clubId;
  final String? teamId;

  // Getter for backward compatibility
  String? get name => fullName;

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    required this.role,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.createdAt,
    this.lastLoginAt,
    required this.isActive,
    this.metadata,
    this.activeClubId,
    this.activeTeamId,
    this.clubId,
    this.teamId,
  });

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
    UserRole? role,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
    String? activeClubId,
    String? activeTeamId,
    String? clubId,
    String? teamId,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
      activeClubId: activeClubId ?? this.activeClubId,
      activeTeamId: activeTeamId ?? this.activeTeamId,
      clubId: clubId ?? this.clubId,
      teamId: teamId ?? this.teamId,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'avatarUrl': avatarUrl,
        'role': role.toString().split('.').last,
        'isEmailVerified': isEmailVerified,
        'isPhoneVerified': isPhoneVerified,
        'createdAt': createdAt.toIso8601String(),
        'lastLoginAt': lastLoginAt?.toIso8601String(),
        'isActive': isActive,
        'metadata': metadata,
        'activeClubId': activeClubId,
        'activeTeamId': activeTeamId,
        'clubId': clubId,
        'teamId': teamId,
      };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'],
      avatarUrl: json['avatarUrl'],
      role: UserRole.values.firstWhere(
        (role) => role.toString().split('.').last == (json['role'] ?? 'fan'),
        orElse: () => UserRole.fan,
      ),
      isEmailVerified: json['isEmailVerified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
      isActive: json['isActive'] ?? true,
      metadata: json['metadata'],
      activeClubId: json['activeClubId'],
      activeTeamId: json['activeTeamId'],
      clubId: json['clubId'],
      teamId: json['teamId'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        fullName,
        phoneNumber,
        avatarUrl,
        role,
        isEmailVerified,
        isPhoneVerified,
        createdAt,
        lastLoginAt,
        isActive,
        metadata,
        activeClubId,
        activeTeamId,
        clubId,
        teamId,
      ];
}

/// Login request model
class LoginRequest extends Equatable {
  final String emailOrUsername;
  final String password;
  final bool rememberMe;

  const LoginRequest({
    required this.emailOrUsername,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() => {
        'emailOrUsername': emailOrUsername,
        'password': password,
        'rememberMe': rememberMe,
      };

  @override
  List<Object?> get props => [emailOrUsername, password, rememberMe];
}

/// Registration request model
class RegistrationRequest extends Equatable {
  final String email;
  final String username;
  final String fullName;
  final String password;
  final String passwordConfirmation;
  final UserRole role;
  final bool acceptTerms;

  const RegistrationRequest({
    required this.email,
    required this.username,
    required this.fullName,
    required this.password,
    required this.passwordConfirmation,
    required this.role,
    required this.acceptTerms,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'username': username,
        'fullName': fullName,
        'password': password,
        'passwordConfirmation': passwordConfirmation,
        'role': role.toString().split('.').last,
        'acceptTerms': acceptTerms,
      };

  @override
  List<Object?> get props => [
        email,
        username,
        fullName,
        password,
        passwordConfirmation,
        role,
        acceptTerms,
      ];
}

/// Reset password request
class ResetPasswordRequest extends Equatable {
  final String token;
  final String newPassword;
  final String confirmPassword;

  const ResetPasswordRequest({
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
        'token': token,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      };

  @override
  List<Object?> get props => [token, newPassword, confirmPassword];
}

/// Auth token response
class AuthToken extends Equatable {
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;
  final String tokenType;

  const AuthToken({
    required this.accessToken,
    this.refreshToken,
    required this.expiresAt,
    this.tokenType = 'Bearer',
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isExpiringSoon =>
      DateTime.now().add(const Duration(minutes: 5)).isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresAt': expiresAt.toIso8601String(),
        'tokenType': tokenType,
      };

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['accessToken'] ?? json['access_token'] ?? '',
      refreshToken: json['refreshToken'] ?? json['refresh_token'],
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : json['expires_at'] != null
              ? DateTime.parse(json['expires_at'])
              : DateTime.now().add(const Duration(hours: 24)),
      tokenType: json['tokenType'] ?? json['token_type'] ?? 'Bearer',
    );
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt, tokenType];
}

/// Auth state model
class AuthState extends Equatable {
  final bool isAuthenticated;
  final User? user;
  final AuthToken? token;
  final bool isLoading;
  final String? error;
  final bool isFirstLogin;

  const AuthState({
    required this.isAuthenticated,
    this.user,
    this.token,
    required this.isLoading,
    this.error,
    required this.isFirstLogin,
  });

  factory AuthState.initial() => const AuthState(
        isAuthenticated: false,
        user: null,
        token: null,
        isLoading: false,
        error: null,
      isFirstLogin: false,
      );

  factory AuthState.loading() => const AuthState(
        isAuthenticated: false,
        user: null,
        token: null,
        isLoading: true,
        error: null,
        isFirstLogin: false,
      );

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    AuthToken? token,
    bool? isLoading,
    String? error,
    bool? isFirstLogin,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
    );
  }

  @override
  List<Object?> get props =>
      [isAuthenticated, user, token, isLoading, error, isFirstLogin];
}
