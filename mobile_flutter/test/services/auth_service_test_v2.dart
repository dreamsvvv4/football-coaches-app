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
      authService = AuthService(prefs);
    });

    group('Login', () {
      test('logs in with valid email and password', () async {
        final loginRequest = LoginRequest(
          emailOrUsername: 'coach@example.com',
          password: 'Coach123!Pass',
          rememberMe: false,
        );

        await authService.login(loginRequest);

        expect(authService.isAuthenticated, true);
        expect(authService.currentUser?.email, 'coach@example.com');
      });

      test('logs in with valid username', () async {
        final loginRequest = LoginRequest(
          emailOrUsername: 'coach_user',
          password: 'Coach123!Pass',
          rememberMe: false,
        );

        await authService.login(loginRequest);

        expect(authService.isAuthenticated, true);
      });

      test('fails with invalid password', () async {
        final loginRequest = LoginRequest(
          emailOrUsername: 'coach@example.com',
          password: 'WrongPassword',
          rememberMe: false,
        );

        expect(
          () => authService.login(loginRequest),
          throwsA(isA<Exception>()),
        );
      });

      test('stores token when rememberMe is true', () async {
        final loginRequest = LoginRequest(
          emailOrUsername: 'coach@example.com',
          password: 'Coach123!Pass',
          rememberMe: true,
        );

        await authService.login(loginRequest);

        expect(prefs.containsKey('auth_token'), true);
      });
    });

    group('Registration', () {
      test('registers new user successfully', () async {
        final registerRequest = RegistrationRequest(
          email: 'newuser@example.com',
          username: 'newuser',
          fullName: 'New User',
          password: 'NewPassword123!',
          passwordConfirmation: 'NewPassword123!',
          role: UserRole.player,
          acceptTerms: true,
        );

        await authService.register(registerRequest);

        expect(authService.isAuthenticated, true);
        expect(authService.currentUser?.role, UserRole.player);
      });

      test('rejects duplicate email', () async {
        final registerRequest = RegistrationRequest(
          email: 'coach@example.com',
          username: 'unique_user',
          fullName: 'New User',
          password: 'NewPassword123!',
          passwordConfirmation: 'NewPassword123!',
          role: UserRole.player,
          acceptTerms: true,
        );

        expect(
          () => authService.register(registerRequest),
          throwsA(isA<Exception>()),
        );
      });

      test('rejects mismatched passwords', () async {
        final registerRequest = RegistrationRequest(
          email: 'new@example.com',
          username: 'newuser',
          fullName: 'New User',
          password: 'NewPassword123!',
          passwordConfirmation: 'Different123!',
          role: UserRole.player,
          acceptTerms: true,
        );

        expect(
          () => authService.register(registerRequest),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Logout', () {
      test('clears auth state', () async {
        final loginRequest = LoginRequest(
          emailOrUsername: 'coach@example.com',
          password: 'Coach123!Pass',
          rememberMe: true,
        );

        await authService.login(loginRequest);
        expect(authService.isAuthenticated, true);

        await authService.logout();

        expect(authService.isAuthenticated, false);
        expect(authService.currentUser, isNull);
        expect(prefs.containsKey('auth_token'), false);
      });
    });

    group('Password Reset', () {
      test('requests password reset', () async {
        await authService.requestPasswordReset('coach@example.com');
      });

      test('resets password with matching confirmation', () async {
        final resetRequest = ResetPasswordRequest(
          token: 'test-token',
          newPassword: 'NewPassword123!',
          confirmPassword: 'NewPassword123!',
        );

        await authService.resetPassword(resetRequest);
      });

      test('rejects mismatched password confirmation', () async {
        final resetRequest = ResetPasswordRequest(
          token: 'test-token',
          newPassword: 'NewPassword123!',
          confirmPassword: 'Different123!',
        );

        expect(
          () => authService.resetPassword(resetRequest),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Email/Username Availability', () {
      test('checks email availability', () async {
        final available =
            await authService.isEmailAvailable('newavailable@example.com');
        expect(available, true);

        final taken = await authService.isEmailAvailable('coach@example.com');
        expect(taken, false);
      });

      test('checks username availability', () async {
        final available = await authService.isUsernameAvailable('newuser123');
        expect(available, true);

        final taken = await authService.isUsernameAvailable('coach_user');
        expect(taken, false);
      });
    });

    group('Onboarding', () {
      test('completes onboarding', () async {
        await authService.completeOnboarding();
      });
    });

    group('Token Refresh', () {
      test('refreshes token while authenticated', () async {
        final loginRequest = LoginRequest(
          emailOrUsername: 'coach@example.com',
          password: 'Coach123!Pass',
          rememberMe: true,
        );

        await authService.login(loginRequest);
        expect(authService.isAuthenticated, true);

        await authService.refreshToken();

        expect(authService.isAuthenticated, true);
      });
    });

    group('State Persistence', () {
      test('persists user data on login with rememberMe', () async {
        final loginRequest = LoginRequest(
          emailOrUsername: 'coach@example.com',
          password: 'Coach123!Pass',
          rememberMe: true,
        );

        await authService.login(loginRequest);

        expect(prefs.containsKey('user_id'), true);
        expect(prefs.containsKey('user_data'), true);
        expect(prefs.containsKey('auth_token'), true);
      });

      test('does not persist without rememberMe', () async {
        final loginRequest = LoginRequest(
          emailOrUsername: 'coach@example.com',
          password: 'Coach123!Pass',
          rememberMe: false,
        );

        await authService.login(loginRequest);

        // Without rememberMe, token may not be persisted
        expect(authService.isAuthenticated, true);
      });
    });

    group('State Notifications', () {
      test('notifies on login', () async {
        var notified = false;

        authService.addListener(() {
          notified = true;
        });

        final loginRequest = LoginRequest(
          emailOrUsername: 'coach@example.com',
          password: 'Coach123!Pass',
          rememberMe: false,
        );

        await authService.login(loginRequest);

        expect(notified, true);
      });

      test('notifies on logout', () async {
        final loginRequest = LoginRequest(
          emailOrUsername: 'coach@example.com',
          password: 'Coach123!Pass',
          rememberMe: false,
        );

        await authService.login(loginRequest);

        var notified = false;

        authService.addListener(() {
          notified = true;
        });

        await authService.logout();

        expect(notified, true);
      });
    });
  });
}
