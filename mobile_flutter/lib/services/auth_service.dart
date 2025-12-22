import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth.dart' as auth_models;
import '../models/auth.dart' show User, AuthState, AuthToken, LoginRequest, RegistrationRequest, ResetPasswordRequest;
import '../models/user_role.dart' as user_roles;
import 'token_storage.dart';

/// Authentication service with state management
class AuthService extends ChangeNotifier {
  final TokenStorage _tokenStorage = TokenStorage.instance;

  void _ensureDemoAuthAllowed() {
    if (kReleaseMode) {
      throw 'Demo auth is disabled in release builds';
    }
  }
  // Active context for permissions
  user_roles.ActiveContext? get activeContext {
    final user = currentUser;
    if (user == null) return null;
    // Puedes adaptar esto si tienes clubId/teamId en el usuario
    // Mapear UserRole (auth.dart) a UserRoleType (user_role.dart)
    user_roles.UserRoleType? mappedRole;
    switch (user.role) {
      case auth_models.UserRole.superadmin:
        mappedRole = user_roles.UserRoleType.superadmin;
        break;
      case auth_models.UserRole.staff:
        mappedRole = user_roles.UserRoleType.adminClub;
        break;
      case auth_models.UserRole.coach:
        mappedRole = user_roles.UserRoleType.entrenador;
        break;
      case auth_models.UserRole.fan:
        mappedRole = user_roles.UserRoleType.padre;
        break;
      case auth_models.UserRole.player:
        mappedRole = user_roles.UserRoleType.jugador;
        break;
      default:
        mappedRole = null;
    }
    if (mappedRole == null) return null;

    final clubId = user.activeClubId ?? user.clubId ?? '';
    final teamId = user.activeTeamId ?? user.teamId ?? '';
    return user_roles.ActiveContext(
      role: mappedRole,
      clubId: clubId,
      teamId: teamId,
    );
  }
    /// Get singleton instance for backward compatibility
    static AuthService get instance {
      if (_instance == null) {
        throw Exception('AuthService not initialized. Call AuthService.init(prefs) in main()');
      }
      return _instance!;
    }
  static const String _authTokenKey = 'auth_token';
  static const String _userKey = 'user_data';
    static const String _userIdKey = 'user_id';
  static const String _rememberMeKey = 'remember_me';
  static const String _onboardingCompleteKey = 'onboarding_complete';

  static AuthService? _instance;
  static SharedPreferences? _prefs;

  static Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    // Always create a fresh instance when (re)initializing.
    // This keeps test runs deterministic and avoids leaking listeners/state.
    _instance = AuthService._internal();
    await _instance!._initialize();
  }



  AuthState _state = AuthState.initial();

  /// Factory constructor for backward/test compatibility.
  /// Returns the singleton instance once initialized.
  factory AuthService() => AuthService.instance;

  // Only one internal constructor for singleton
  AuthService._internal();

  // Simulated user database (replace with API calls)
  static final Map<String, Map<String, dynamic>> _userDatabase = {
    'coach@example.com': {
      'password': 'Coach123!Pass',
      'user': User(
        id: 'user_coach_001',
        email: 'coach@example.com',
        username: 'coach_user',
        fullName: 'John Coach',
        phoneNumber: '+1234567890',
        role: auth_models.UserRole.coach,
        isEmailVerified: true,
        isPhoneVerified: true,
        createdAt: DateTime(2024, 1, 1),
        isActive: true,
        activeClubId: 'club1',
      ),
    },
    'player@example.com': {
      'password': 'Player123!',
      'user': User(
        id: 'user_player_001',
        email: 'player@example.com',
        username: 'jane_player',
        fullName: 'Jane Player',
        phoneNumber: '+1234567891',
        role: auth_models.UserRole.player,
        isEmailVerified: true,
        isPhoneVerified: false,
        createdAt: DateTime(2024, 1, 15),
        isActive: true,
        activeClubId: 'club1',
      ),
    },
    'admin@example.com': {
      'password': 'Admin123!',
      'user': User(
        id: 'user_admin_001',
        email: 'admin@example.com',
        username: 'super_admin',
        fullName: 'Admin User',
        role: auth_models.UserRole.superadmin,
        isEmailVerified: true,
        isPhoneVerified: true,
        createdAt: DateTime(2024, 1, 1),
        isActive: true,
        activeClubId: 'club1',
      ),
    },
    'clubadmin@example.com': {
      'password': 'ClubAdmin123!',
      'user': User(
        id: 'user_clubadmin_001',
        email: 'clubadmin@example.com',
        username: 'club_admin',
        fullName: 'Club Admin',
        phoneNumber: '+1234567892',
        role: auth_models.UserRole.staff, // Mapea a adminClub en el sistema de permisos
        isEmailVerified: true,
        isPhoneVerified: true,
        createdAt: DateTime(2024, 2, 1),
        isActive: true,
        activeClubId: 'club1',
      ),
    },
    'padre@example.com': {
      'password': 'Padre123!',
      'user': User(
        id: 'user_padre_001',
        email: 'padre@example.com',
        username: 'padre_futbol',
        fullName: 'Padre Futbolero',
        phoneNumber: '+1234567893',
        role: auth_models.UserRole.fan, // Mapea a padre en el sistema de permisos
        isEmailVerified: true,
        isPhoneVerified: false,
        createdAt: DateTime(2024, 3, 1),
        isActive: true,
        activeClubId: 'club1',
      ),
    },
  };

  // Simulated registered users (for registration validation)
  static final Set<String> _registeredEmails = {
    'coach@example.com',
    'player@example.com',
    'admin@example.com',
  };

  static final Set<String> _registeredUsernames = {
    'coach_user',
    'jane_player',
    'super_admin',
  };



  AuthState get state => _state;
  bool get isAuthenticated => _state.isAuthenticated;
  User? get currentUser => _state.user;
  bool get isFirstLogin => _state.isFirstLogin;

  /// Permissions (stub for compatibility)
  List<String> getPermissionsForContext(String context) {
    // TODO: Implement real permission logic
    return [];
  }


  /// Initialize auth state from stored data
  Future<void> _initialize() async {
    try {
        final secureToken = await _tokenStorage.readToken();
        final secureUser = await _tokenStorage.readUserJson();

        final legacyToken = _prefs?.getString(_authTokenKey);
        final legacyUser = _prefs?.getString(_userKey);

        final storedToken = secureToken ?? legacyToken;
        final storedUser = secureUser ?? legacyUser;
        final onboardingComplete =
          _prefs?.getBool(_onboardingCompleteKey) ?? false;

      if (storedToken != null && storedUser != null) {
        // In production, verify token with backend
        final user = _parseUserJson(storedUser);

        // One-time migration from legacy SharedPreferences storage.
        if (secureToken == null || secureUser == null) {
          await _tokenStorage.saveToken(storedToken);
          await _tokenStorage.saveUserJson(storedUser);
        }

        _state = AuthState(
          isAuthenticated: true,
          user: user,
          token: AuthToken(
            accessToken: storedToken,
            expiresAt: DateTime.now().add(const Duration(hours: 24)),
          ),
          isLoading: false,
          error: null,
          isFirstLogin: !onboardingComplete,
        );
      }
      notifyListeners();
    } catch (e) {
      _state = AuthState.initial();
      notifyListeners();
    }
  }

  /// Login with email/username and password
  Future<bool> login(LoginRequest request) async {
    _state = AuthState.loading();
    notifyListeners();

    try {
      _ensureDemoAuthAllowed();

      // Find user by email or username
      final userEntry = _userDatabase.entries.firstWhere(
        (entry) {
          final user = entry.value['user'] as User;
          final emailMatch = entry.key == request.emailOrUsername;
          final usernameMatch = user.username == request.emailOrUsername;
          return emailMatch || usernameMatch;
        },
        orElse: () => throw 'User not found',
      );

      final storedPassword = userEntry.value['password'] as String;
      final baseUser = userEntry.value['user'] as User;
      final user = baseUser.copyWith(lastLoginAt: DateTime.now());
      userEntry.value['user'] = user;

      // Verify password (in production, this happens on backend)
      if (storedPassword != request.password) {
        throw 'Invalid password';
      }

      if (!user.isActive) {
        throw 'User account is inactive';
      }

      // Create token
      final token = AuthToken(
        accessToken: 'token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'refresh_${DateTime.now().millisecondsSinceEpoch}',
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );

      // Store data
      await _tokenStorage.saveToken(token.accessToken);
      await _tokenStorage.saveUserJson(_userToJson(user));
      if (request.rememberMe) {
        await _prefs?.setString(_userIdKey, user.id);
        await _prefs?.setString(_userKey, _userToJson(user));
        await _prefs?.setString(_authTokenKey, token.accessToken);
        await _prefs?.setBool(_rememberMeKey, true);
      } else {
        await _prefs?.remove(_rememberMeKey);
      }

      // Update state
      _state = AuthState(
        isAuthenticated: true,
        user: user,
        token: token,
        isLoading: false,
        error: null,
        isFirstLogin: false,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _state = AuthState(
        isAuthenticated: false,
        user: null,
        token: null,
        isLoading: false,
        error: e.toString(),
        isFirstLogin: true,
      );
      notifyListeners();
      return false;
    }
  }

  /// Register new user
  Future<bool> register(RegistrationRequest request) async {
    _state = AuthState.loading();
    notifyListeners();

    try {
      _ensureDemoAuthAllowed();

      if (!request.acceptTerms) {
        throw 'You must accept the terms';
      }

      if (request.password != request.passwordConfirmation) {
        throw 'Passwords do not match';
      }

      if (request.password.length < 8) {
        throw 'Password too short';
      }

      // Validate unique email
      if (_registeredEmails.contains(request.email.toLowerCase())) {
        throw 'Email already registered';
      }

      // Validate unique username
      if (_registeredUsernames.contains(request.username.toLowerCase())) {
        throw 'Username already taken';
      }

      // Create new user
      final newUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: request.email,
        username: request.username,
        fullName: request.fullName,
        role: request.role,
        isEmailVerified: false,
        isPhoneVerified: false,
        createdAt: DateTime.now(),
        isActive: true,
      );

      // Add to database
      _userDatabase[request.email] = {
        'password': request.password,
        'user': newUser,
      };
      _registeredEmails.add(request.email.toLowerCase());
      _registeredUsernames.add(request.username.toLowerCase());

      // Create token
      final token = AuthToken(
        accessToken: 'token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'refresh_${DateTime.now().millisecondsSinceEpoch}',
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );

      // Store data
      await _tokenStorage.saveToken(token.accessToken);
      await _tokenStorage.saveUserJson(_userToJson(newUser));
      await _prefs?.setString(_userIdKey, newUser.id);
      await _prefs?.setString(_userKey, _userToJson(newUser));
      await _prefs?.setString(_authTokenKey, token.accessToken);

      // Update state
      _state = AuthState(
        isAuthenticated: true,
        user: newUser,
        token: token,
        isLoading: false,
        error: null,
        isFirstLogin: true,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _state = AuthState(
        isAuthenticated: false,
        user: null,
        token: null,
        isLoading: false,
        error: e.toString(),
        isFirstLogin: true,
      );
      notifyListeners();
      return false;
    }
  }

  /// Request password reset
  Future<bool> requestPasswordReset(String email) async {
    try {
      _ensureDemoAuthAllowed();
      // In production, send reset link via email.
      // Never reveal whether the email exists.
      return true;
    } catch (e) {
      return true;
    }
  }

  /// Reset password with token
  Future<bool> resetPassword(ResetPasswordRequest request) async {
    try {
      _ensureDemoAuthAllowed();

      // In production, verify token with backend
      // For now, just validate the new password
      if (request.newPassword != request.confirmPassword) {
        return false;
      }

      if (request.newPassword.length < 8) {
        return false;
      }

      // In production, update password on backend
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _tokenStorage.deleteToken();
    await _tokenStorage.deleteUserJson();
    await _prefs?.remove(_userIdKey);
    await _prefs?.remove(_authTokenKey);
    await _prefs?.remove(_userKey);
    await _prefs?.remove(_rememberMeKey);
    await _prefs?.remove(_onboardingCompleteKey);

    _state = AuthState.initial();
    notifyListeners();
  }

  /// Mark onboarding as complete
  Future<void> completeOnboarding() async {
    await _prefs?.setBool(_onboardingCompleteKey, true);
    _state = _state.copyWith(isFirstLogin: false);
    notifyListeners();
  }

  /// Refresh auth token
  Future<bool> refreshToken() async {
    try {
      final newToken = AuthToken(
        accessToken: 'token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'refresh_${DateTime.now().millisecondsSinceEpoch}',
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );

      await _tokenStorage.saveToken(newToken.accessToken);
      await _prefs?.setString(_authTokenKey, newToken.accessToken);
      _state = _state.copyWith(token: newToken);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if email is available (for registration)
  Future<bool> isEmailAvailable(String email) async {
    return !_registeredEmails.contains(email.toLowerCase());
  }

  /// Check if username is available (for registration)
  Future<bool> isUsernameAvailable(String username) async {
    return !_registeredUsernames.contains(username.toLowerCase());
  }

  // Helper methods
  String _userToJson(User user) {
    return jsonEncode(user.toJson());
  }

  User _parseUserJson(String userJson) {
    final decoded = jsonDecode(userJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid user JSON');
    }
    return User.fromJson(decoded);
  }

  /// Get action permissions for a role
  List<String> getActionPermsForRole(dynamic role) {
    // Convert UserRole enum to string if needed
    String roleStr = role is auth_models.UserRole ? role.displayName.toLowerCase() : role.toString().toLowerCase();

    if (roleStr.contains('coach')) {
      return [
        'create_friendly',
        'edit_team',
        'view_stats',
        'manage_players',
        'create_tournament',
        'match_live_events',
      ];
    }
    if (roleStr.contains('staff')) {
      return [
        'view_stats',
        'manage_players',
        'match_live_events',
      ];
    }
    if (roleStr.contains('superadmin')) {
      return [
        'create_friendly',
        'edit_team',
        'view_stats',
        'manage_players',
        'create_tournament',
        'manage_venues',
        'manage_users',
        'match_live_events',
      ];
    }
    if (roleStr.contains('player')) return ['view_stats'];
    if (roleStr.contains('fan')) return ['view_stats'];
    
    return [];
  }

  /// Get current user roles as list of strings for backward compatibility
  List<String> get currentUserRoles {
    if (currentUser == null) return [];
    return [currentUser!.role.displayName.toLowerCase()];
  }

  /// Get current user as dynamic object (for backward compatibility)
  dynamic getCurrentUserCompat() {
    final user = currentUser;
    if (user == null) return null;
    
    return {
      'id': user.id,
      'email': user.email,
      'username': user.username,
      'fullName': user.fullName,
      'name': user.fullName, // Backward compat
      'phoneNumber': user.phoneNumber,
      'role': user.role.displayName.toLowerCase(),
      'isEmailVerified': user.isEmailVerified,
      'isPhoneVerified': user.isPhoneVerified,
      'createdAt': user.createdAt,
      'isActive': user.isActive,
      'activeClubId': null,
      'activeTeamId': null,
      'clubId': null,
      'teamId': null,
    };
  }

  /// Set current user directly (for testing)
  /// Accepts both the new User (from auth.dart) and the old User (from user.dart)
  void setCurrentUser(dynamic userObj) {
    User user;
    
    // If it's already a User from auth.dart, use it directly
    if (userObj is User) {
      user = userObj;
    } else {
      // Try to convert from old User format or dynamic object
      try {
        final id = userObj.id ?? 'test_user_id';
        final email = userObj.email ?? 'test@example.com';
        final name = userObj.name ?? userObj.fullName ?? 'Test User';
        final roleStr = userObj.role ?? 'coach';
        
        // Convert role string to UserRole enum
        auth_models.UserRole roleEnum = auth_models.UserRole.fan;
        if (roleStr is String) {
          roleEnum = auth_models.UserRole.values.firstWhere(
            (role) => role.displayName.toLowerCase() == roleStr.toLowerCase(),
            orElse: () => auth_models.UserRole.fan,
          );
        } else if (roleStr is auth_models.UserRole) {
          roleEnum = roleStr;
        }
        
        user = User(
          id: id,
          email: email,
          username: name.replaceAll(' ', '_').toLowerCase(),
          fullName: name,
          phoneNumber: userObj.phoneNumber,
          avatarUrl: userObj.avatarUrl,
          role: roleEnum,
          isEmailVerified: userObj.isEmailVerified ?? true,
          isPhoneVerified: userObj.isPhoneVerified ?? false,
          createdAt: userObj.createdAt ?? DateTime.now(),
          isActive: userObj.isActive ?? true,
          activeClubId: userObj.activeClubId,
          activeTeamId: userObj.activeTeamId,
          clubId: userObj.clubId,
          teamId: userObj.teamId,
        );
      } catch (e) {
        // Fallback for unknown format
        user = User(
          id: 'test_user',
          email: 'test@example.com',
          username: 'test_user',
          fullName: 'Test User',
          role: auth_models.UserRole.coach,
          isEmailVerified: true,
          isPhoneVerified: false,
          createdAt: DateTime.now(),
          isActive: true,
        );
      }
    }
    
    _state = AuthState(
      isAuthenticated: true,
      user: user,
      isLoading: false,
      error: null,
      isFirstLogin: false,
    );
    notifyListeners();
  }

  /// Get visible tabs for a role
  List<String> getVisibleTabsForRole(String role) {
    // Hide tournaments via feature flag
    const bool tournamentsEnabled = false;
    final roleStr = role.toLowerCase();
    List<String> base;
    if (roleStr.contains('admin') || roleStr.contains('superadmin')) {
      base = ['home', 'team', 'friendlies', 'chat', 'profile'];
    } else if (roleStr.contains('coach')) {
      base = ['home', 'team', 'friendlies', 'chat', 'profile'];
    } else if (roleStr.contains('manager')) {
      base = ['home', 'team', 'friendlies', 'chat', 'profile'];
    } else if (roleStr.contains('player')) {
      base = ['home', 'friendlies', 'profile'];
    } else {
      base = ['profile'];
    }
    if (tournamentsEnabled) {
      // Insert tournaments as second tab if enabled
      if (!base.contains('tournaments')) {
        base.insert(1, 'tournaments');
      }
    }
    return base;
  }

  /// Persist onboarding snapshot (for testing)
  Future<void> persistOnboardingSnapshot() async {
    await _prefs?.setBool(_onboardingCompleteKey, true);
  }

  /// Set visible tabs for a role
  void setVisibleTabsForRole(String role, List<String> tabs) {
    // Store in preferences or state as needed
    // For now, just a placeholder for test compatibility
  }

  /// Set action permissions for a role
  void setActionPermsForRole(String role, List<String> perms) {
    // Store in preferences or state as needed
    // For now, just a placeholder for test compatibility
  }
}
