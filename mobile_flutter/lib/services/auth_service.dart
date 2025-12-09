import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth.dart';

/// Authentication service with state management
class AuthService extends ChangeNotifier {
  static const String _authTokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _rememberMeKey = 'remember_me';
  static const String _onboardingCompleteKey = 'onboarding_complete';

  // Singleton instance for backward compatibility
  static AuthService? _instance;

  AuthState _state = AuthState.initial();
  final SharedPreferences _prefs;

  // Simulated user database (replace with API calls)
  static final Map<String, Map<String, dynamic>> _userDatabase = {
    'coach@example.com': {
      'password': 'Coach123!',
      'user': User(
        id: 'user_coach_001',
        email: 'coach@example.com',
        username: 'john_coach',
        fullName: 'John Coach',
        phoneNumber: '+1234567890',
        role: UserRole.coach,
        isEmailVerified: true,
        isPhoneVerified: true,
        createdAt: DateTime(2024, 1, 1),
        isActive: true,
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
        role: UserRole.player,
        isEmailVerified: true,
        isPhoneVerified: false,
        createdAt: DateTime(2024, 1, 15),
        isActive: true,
      ),
    },
    'admin@example.com': {
      'password': 'Admin123!',
      'user': User(
        id: 'user_admin_001',
        email: 'admin@example.com',
        username: 'super_admin',
        fullName: 'Admin User',
        role: UserRole.superadmin,
        isEmailVerified: true,
        isPhoneVerified: true,
        createdAt: DateTime(2024, 1, 1),
        isActive: true,
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
    'john_coach',
    'jane_player',
    'super_admin',
  };

  AuthService(this._prefs) {
    _instance = this;
    _initialize();
  }

  /// Get singleton instance for backward compatibility
  static AuthService get instance {
    if (_instance == null) {
      throw Exception(
        'AuthService not initialized. Call main() properly.',
      );
    }
    return _instance!;
  }

  AuthState get state => _state;
  bool get isAuthenticated => _state.isAuthenticated;
  User? get currentUser => _state.user;
  bool get isFirstLogin => _state.isFirstLogin;

  /// Initialize auth state from stored data
  Future<void> _initialize() async {
    try {
      final storedToken = _prefs.getString(_authTokenKey);
      final storedUser = _prefs.getString(_userKey);
      final onboardingComplete =
          _prefs.getBool(_onboardingCompleteKey) ?? false;

      if (storedToken != null && storedUser != null) {
        // In production, verify token with backend
        final user = _parseUserJson(storedUser);
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
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

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
      final user = userEntry.value['user'] as User;

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
      await _prefs.setString(_authTokenKey, token.accessToken);
      await _prefs.setString(_userKey, _userToJson(user));
      if (request.rememberMe) {
        await _prefs.setBool(_rememberMeKey, true);
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
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

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
      await _prefs.setString(_authTokenKey, token.accessToken);
      await _prefs.setString(_userKey, _userToJson(newUser));

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
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      if (!_userDatabase.containsKey(email)) {
        throw 'User not found';
      }

      // In production, send reset link via email
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reset password with token
  Future<bool> resetPassword(ResetPasswordRequest request) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // In production, verify token with backend
      // For now, just validate the new password
      if (request.newPassword != request.confirmPassword) {
        throw 'Passwords do not match';
      }

      if (request.newPassword.length < 8) {
        throw 'Password must be at least 8 characters';
      }

      // In production, update password on backend
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _prefs.remove(_authTokenKey);
    await _prefs.remove(_userKey);
    await _prefs.remove(_rememberMeKey);

    _state = AuthState.initial();
    notifyListeners();
  }

  /// Mark onboarding as complete
  Future<void> completeOnboarding() async {
    await _prefs.setBool(_onboardingCompleteKey, true);
    _state = _state.copyWith(isFirstLogin: false);
    notifyListeners();
  }

  /// Refresh auth token
  Future<bool> refreshToken() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      final newToken = AuthToken(
        accessToken: 'token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'refresh_${DateTime.now().millisecondsSinceEpoch}',
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );

      await _prefs.setString(_authTokenKey, newToken.accessToken);
      _state = _state.copyWith(token: newToken);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if email is available (for registration)
  Future<bool> isEmailAvailable(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return !_registeredEmails.contains(email.toLowerCase());
  }

  /// Check if username is available (for registration)
  Future<bool> isUsernameAvailable(String username) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return !_registeredUsernames.contains(username.toLowerCase());
  }

  // Helper methods
  String _userToJson(User user) {
    // Simple JSON serialization
    final userMap = user.toJson();
    return userMap.toString();
  }

  User _parseUserJson(String userJson) {
    // Simple JSON parsing - in production use json_serializable
    return User(
      id: 'user_default',
      email: 'default@example.com',
      username: 'default_user',
      fullName: 'Default User',
      role: UserRole.fan,
      isEmailVerified: false,
      isPhoneVerified: false,
      createdAt: DateTime.now(),
      isActive: true,
    );
  }

  /// Get action permissions for a role
  List<String> getActionPermsForRole(dynamic role) {
    // Convert UserRole enum to string if needed
    String roleStr = role is UserRole ? role.displayName.toLowerCase() : role.toString().toLowerCase();
    
    if (roleStr.contains('coach')) return ['create_friendly', 'edit_team', 'view_stats', 'manage_players', 'create_tournament'];
    if (roleStr.contains('staff')) return ['view_stats', 'manage_players'];
    if (roleStr.contains('superadmin')) return ['create_friendly', 'edit_team', 'view_stats', 'manage_players', 'create_tournament', 'manage_venues', 'manage_users'];
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
        UserRole roleEnum = UserRole.fan;
        if (roleStr is String) {
          roleEnum = UserRole.values.firstWhere(
            (role) => role.displayName.toLowerCase() == roleStr.toLowerCase(),
            orElse: () => UserRole.fan,
          );
        } else if (roleStr is UserRole) {
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
          role: UserRole.coach,
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
    await _prefs.setBool(_onboardingCompleteKey, true);
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
