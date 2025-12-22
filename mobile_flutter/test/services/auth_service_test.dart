import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_flutter/services/auth_service.dart';
import 'package:mobile_flutter/models/auth.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      await AuthService.init(prefs);
      authService = AuthService();
      await authService.logout();
    });

    // Initialization tests
    group('initialization', () {
      test('initializes with unauthenticated state', () {
        expect(authService.isAuthenticated, false);
        expect(authService.currentUser, isNull);
      });

      test('restores auth state from SharedPreferences', () async {
        // Set up mock data in prefs
        await prefs.setString('user_id', 'test-user-id');
        await prefs.setString(
          'user_data',
          '{"id":"test-user-id","email":"test@example.com","username":"testuser","fullName":"Test User","phoneNumber":"","avatarUrl":"","role":"coach","isEmailVerified":true,"isPhoneVerified":false,"createdAt":"2024-01-01T00:00:00.000Z","lastLoginAt":"2024-01-01T00:00:00.000Z","isActive":true,"metadata":{}}',
        );
        await prefs.setString('auth_token', 'test-token');

        await AuthService.init(prefs);
        final newAuthService = AuthService();
        expect(newAuthService.isAuthenticated, true);
        expect(newAuthService.currentUser, isNotNull);
      });

      test('isFirstLogin flag works correctly', () {
        expect(authService.isFirstLogin, false);
      });
    });

    // Login tests
    group('login', () {
      test('logs in with valid email and password', () async {
        final loginRequest = LoginRequest(
          emailOrUsername: 'coach@example.com',
          password: 'Coach123!Pass',
          rememberMe: false,
        );

        final ok = await authService.login(loginRequest);
        expect(ok, true);

        expect(authService.isAuthenticated, true);
        expect(authService.currentUser, isNotNull);
        expect(authService.currentUser?.email, 'coach@example.com');
      });

      test('logs in with valid username and password', () async {
        final loginRequest = LoginRequest(
          emailOrUsername: 'coach_user',
          password: 'Coach123!Pass',
          rememberMe: false,
        );

        final ok = await authService.login(loginRequest);
        expect(ok, true);

        expect(authService.isAuthenticated, true);
        expect(authService.currentUser, isNotNull);
      });

      test('fails with invalid password', () async {
        final loginRequest = LoginRequest(
          emailOrUsername: 'coach@example.com',
          password: 'WrongPassword123!',
          rememberMe: false,
        );

        final ok = await authService.login(loginRequest);
        expect(ok, false);
        expect(authService.isAuthenticated, false);
        expect(authService.state.error ?? '', contains('Invalid password'));
      });

      test('fails with non-existent email', () async {
        final loginRequest = LoginRequest(
          emailOrUsername: 'nonexistent@example.com',
          password: 'Coach123!Pass',
          rememberMe: false,
        );

        final ok = await authService.login(loginRequest);
        expect(ok, false);
        expect(authService.isAuthenticated, false);
        expect(authService.state.error ?? '', contains('User not found'));
      });

      test('stores auth token when rememberMe is true', () async {
        final loginRequest = LoginRequest(
          emailOrUsername: 'coach@example.com',
          password: 'Coach123!Pass',
          rememberMe: true,
        );

        final ok = await authService.login(loginRequest);
        expect(ok, true);

        expect(authService.isAuthenticated, true);
        expect(prefs.containsKey('auth_token'), true);
      });

      test('updates last login timestamp', () async {
        final loginRequest = LoginRequest(
          emailOrUsername: 'coach@example.com',
          password: 'Coach123!Pass',
          rememberMe: false,
        );

        final ok = await authService.login(loginRequest);
        expect(ok, true);

        final user = authService.currentUser;
        expect(user?.lastLoginAt, isNotNull);
      });
    });

    // Registration tests
    group('register', () {
      test('registers user with valid data', () async {
        final registerRequest = RegistrationRequest(
          email: 'newuser@example.com',
          username: 'newuser',
          fullName: 'New User',
          password: 'NewPassword123!',
          passwordConfirmation: 'NewPassword123!',
          role: UserRole.player,
          acceptTerms: true,
        );

        final ok = await authService.register(registerRequest);
        expect(ok, true);

        expect(authService.isAuthenticated, true);
        expect(authService.currentUser?.email, 'newuser@example.com');
        expect(authService.currentUser?.role, UserRole.player);
      });

      test('rejects duplicate email', () async {
        final registerRequest = RegistrationRequest(
          email: 'coach@example.com', // Already exists
          username: 'uniqueuser',
          fullName: 'New User',
          password: 'NewPassword123!',
          passwordConfirmation: 'NewPassword123!',
          role: UserRole.player,
          acceptTerms: true,
        );

        final ok = await authService.register(registerRequest);
        expect(ok, false);
        expect(authService.state.error ?? '', contains('already registered'));
      });

      test('rejects duplicate username', () async {
        final registerRequest = RegistrationRequest(
          email: 'unique@example.com',
          username: 'coach_user', // Already exists
          fullName: 'New User',
          password: 'NewPassword123!',
          passwordConfirmation: 'NewPassword123!',
          role: UserRole.player,
          acceptTerms: true,
        );

        final ok = await authService.register(registerRequest);
        expect(ok, false);
        expect(authService.state.error ?? '', contains('already taken'));
      });

      test('rejects mismatched passwords', () async {
        final registerRequest = RegistrationRequest(
          email: 'unique@example.com',
          username: 'uniqueuser',
          fullName: 'New User',
          password: 'NewPassword123!',
          passwordConfirmation: 'DifferentPassword123!',
          role: UserRole.player,
          acceptTerms: true,
        );

        final ok = await authService.register(registerRequest);
        expect(ok, false);
      });

      test('rejects registration without terms acceptance', () async {
        final registerRequest = RegistrationRequest(
          email: 'unique@example.com',
          username: 'uniqueuser',
          fullName: 'New User',
          password: 'NewPassword123!',
          passwordConfirmation: 'NewPassword123!',
          role: UserRole.player,
          acceptTerms: false,
        );

        final ok = await authService.register(registerRequest);
        expect(ok, false);
      });

      test('creates user with correct role', () async {
        final registerRequest = RegistrationRequest(
          email: 'staff@example.com',
          username: 'staffuser',
          fullName: 'Staff Member',
          password: 'NewPassword123!',
          passwordConfirmation: 'NewPassword123!',
          role: UserRole.staff,
          acceptTerms: true,
        );

        final ok = await authService.register(registerRequest);
        expect(ok, true);

        expect(authService.currentUser?.role, UserRole.staff);
      });

      test('sets isFirstLogin to true after registration', () async {
        final registerRequest = RegistrationRequest(
          email: 'firstlogin@example.com',
          username: 'firstlogin_user',
          fullName: 'New User',
          password: 'NewPassword123!',
          passwordConfirmation: 'NewPassword123!',
          role: UserRole.player,
          acceptTerms: true,
        );

        final ok = await authService.register(registerRequest);
        expect(ok, true);

        expect(authService.isFirstLogin, true);
      });
    });

    // Logout tests
    group('logout', () {
      test('clears auth state on logout', () async {
        // First login
        final loginRequest = LoginRequest(
          emailOrUsername: 'coach@example.com',
          password: 'Coach123!Pass',
          rememberMe: true,
        );

        final ok = await authService.login(loginRequest);
        expect(ok, true);
        expect(authService.isAuthenticated, true);

        // Then logout
        await authService.logout();

        expect(authService.isAuthenticated, false);
        expect(authService.currentUser, isNull);
        expect(prefs.containsKey('auth_token'), false);
      });

      test('clears token from storage on logout', () async {
        final loginRequest = LoginRequest(
          emailOrUsername: 'coach@example.com',
          password: 'Coach123!Pass',
          rememberMe: true,
        );

        final ok = await authService.login(loginRequest);
        expect(ok, true);
        expect(prefs.containsKey('auth_token'), true);

        await authService.logout();

        expect(prefs.containsKey('auth_token'), false);
      });
    });

    // Password reset tests
    group('password reset', () {
      test('requests password reset for valid email', () async {
        // Should not throw for existing email
        final ok = await authService.requestPasswordReset('coach@example.com');
        expect(ok, true);
      });

      test('requests password reset for non-existent email', () async {
        // Should still succeed (don't reveal if email exists)
        final ok = await authService.requestPasswordReset('nonexistent@example.com');
        expect(ok, true);
      });

      test('resets password with valid token', () async {
        final resetRequest = ResetPasswordRequest(
          token: 'valid-token',
          newPassword: 'NewPassword123!',
          confirmPassword: 'NewPassword123!',
        );

        final ok = await authService.resetPassword(resetRequest);
        expect(ok, true);
      });

      test('rejects mismatched passwords in reset', () async {
        final resetRequest = ResetPasswordRequest(
          token: 'valid-token',
          newPassword: 'NewPassword123!',
          confirmPassword: 'DifferentPassword123!',
        );

        final ok = await authService.resetPassword(resetRequest);
        expect(ok, false);
      });
    });

    // Onboarding tests
    group('onboarding', () {
      test('completes onboarding successfully', () async {
        // Login first
        final loginRequest = LoginRequest(
          emailOrUsername: 'coach@example.com',
          password: 'Coach123!Pass',
          rememberMe: false,
        );

        await authService.login(loginRequest);
        expect(authService.isAuthenticated, true);

        // Complete onboarding (should not throw)
        await authService.completeOnboarding();
      });
    });

    // Token refresh tests
    group('token refresh', () {
      test('refreshes auth token and remains authenticated', () async {
        final loginRequest = LoginRequest(
          emailOrUsername: 'coach@example.com',
          password: 'Coach123!Pass',
          rememberMe: true,
        );

        await authService.login(loginRequest);
        expect(authService.isAuthenticated, true);

        await authService.refreshToken();

        expect(authService.isAuthenticated, true);
        expect(authService.state.token, isNotNull);
      });
    });

    // Email/username availability tests
    group('availability checks', () {
      test('returns false for taken email', () async {
        expect(
          await authService.isEmailAvailable('coach@example.com'),
          false,
        );
      });

      test('returns true for available email', () async {
        expect(
          await authService.isEmailAvailable('newavailable@example.com'),
          true,
        );
      });

      test('returns false for taken username', () async {
        expect(
          await authService.isUsernameAvailable('coach_user'),
          false,
        );
      });

      test('returns true for available username', () async {
        expect(
          await authService.isUsernameAvailable('newavailableuser'),
          true,
        );
      });
    });

    // State persistence tests
    group('state persistence', () {
      test('persists auth state to SharedPreferences on login', () async {
        final loginRequest = LoginRequest(
          emailOrUsername: 'coach@example.com',
          password: 'Coach123!Pass',
          rememberMe: true,
        );

        final ok = await authService.login(loginRequest);
        expect(ok, true);

        expect(prefs.containsKey('user_id'), true);
        expect(prefs.containsKey('user_data'), true);
        expect(prefs.containsKey('auth_token'), true);
      });

      test('clears stored state on logout', () async {
        final loginRequest = LoginRequest(
          emailOrUsername: 'coach@example.com',
          password: 'Coach123!Pass',
          rememberMe: true,
        );

        final ok = await authService.login(loginRequest);
        expect(ok, true);
        expect(prefs.containsKey('auth_token'), true);

        await authService.logout();

        expect(prefs.containsKey('user_id'), false);
        expect(prefs.containsKey('user_data'), false);
        expect(prefs.containsKey('auth_token'), false);
      });
    });

    // State change notifications
    group('state notifications', () {
      test('notifies listeners on login', () async {
        var notificationCount = 0;
        authService.addListener(() {
          notificationCount++;
        });

        final loginRequest = LoginRequest(
          emailOrUsername: 'coach@example.com',
          password: 'Coach123!Pass',
          rememberMe: false,
        );

        await authService.login(loginRequest);

        expect(notificationCount, greaterThan(0));
      });

      test('notifies listeners on logout', () async {
        final loginRequest = LoginRequest(
          emailOrUsername: 'coach@example.com',
          password: 'Coach123!Pass',
          rememberMe: false,
        );

        await authService.login(loginRequest);

        var notificationCount = 0;
        authService.addListener(() {
          notificationCount++;
        });

        await authService.logout();

        expect(notificationCount, greaterThan(0));
      });
    });
  });
}
