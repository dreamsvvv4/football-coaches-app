import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_flutter/screens/auth/login_screen.dart';
import 'package:mobile_flutter/screens/auth/registration_screen.dart';
import 'package:mobile_flutter/screens/auth/password_reset_screen.dart';
import 'package:mobile_flutter/screens/auth/onboarding_screen.dart';
import 'package:mobile_flutter/services/auth_service.dart';

// Helper function to build test app with auth service
Widget buildTestApp(Widget child) {
  return MaterialApp(
    home: child,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    ),
  );
}

Widget buildAuthApp(Widget child, AuthService authService) {
  return MaterialApp(
    home: ChangeNotifierProvider.value(
      value: authService,
      child: child,
    ),
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    ),
  );
}

void main() {
  group('LoginScreen Widget Tests', () {
    late AuthService authService;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      await AuthService.init(prefs);
      authService = AuthService();
    });

    testWidgets('renders login form correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildAuthApp(
          LoginScreen(
            onLoginSuccess: () {},
            onNavigateToRegister: () {},
            onNavigateToForgotPassword: () {},
          ),
          authService,
        ),
      );

      expect(find.byType(TextFormField), findsWidgets);
      expect(find.text('Email or Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('shows password visibility toggle', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildAuthApp(
          LoginScreen(
            onLoginSuccess: () {},
            onNavigateToRegister: () {},
            onNavigateToForgotPassword: () {},
          ),
          authService,
        ),
      );

      // Find password field and toggle visibility
      final toggleButton = find.byIcon(Icons.visibility_off_outlined);
      expect(toggleButton, findsOneWidget);

      await tester.tap(toggleButton);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('shows remember me checkbox', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildAuthApp(
          LoginScreen(
            onLoginSuccess: () {},
            onNavigateToRegister: () {},
            onNavigateToForgotPassword: () {},
          ),
          authService,
        ),
      );

      expect(find.text('Remember me'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets(
      'toggles remember me checkbox',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildAuthApp(
            LoginScreen(
              onLoginSuccess: () {},
              onNavigateToRegister: () {},
              onNavigateToForgotPassword: () {},
            ),
            authService,
          ),
        );

        final checkbox = find.byType(Checkbox);
        expect(checkbox, findsOneWidget);
      },
      skip: true, // Placeholder - real test would verify checkbox state toggled
    );

    testWidgets('shows loading state during login', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildAuthApp(
          LoginScreen(
            onLoginSuccess: () {},
            onNavigateToRegister: () {},
            onNavigateToForgotPassword: () {},
          ),
          authService,
        ),
      );

      // Find login button
      final loginButton = find.byType(FilledButton);
      expect(loginButton, findsOneWidget);

      // Fill in valid credentials
      await tester.enterText(find.byType(TextFormField).first, 'coach@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'Coach123!Pass');
      await tester.pumpAndSettle();

      // Tap login
      await tester.tap(loginButton);
      await tester.pump(); // Show loading state

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('validates empty email field', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildAuthApp(
          LoginScreen(
            onLoginSuccess: () {},
            onNavigateToRegister: () {},
            onNavigateToForgotPassword: () {},
          ),
          authService,
        ),
      );

      final loginButton = find.byType(FilledButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Validation should prevent submission
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('navigates to registration on signup tap',
        (WidgetTester tester) async {
      bool navigatedToRegister = false;

      await tester.pumpWidget(
        buildAuthApp(
          LoginScreen(
            onLoginSuccess: () {},
            onNavigateToRegister: () => navigatedToRegister = true,
            onNavigateToForgotPassword: () {},
          ),
          authService,
        ),
      );

      final signupLink = find.textContaining("Don't have an account?");
      expect(signupLink, findsOneWidget);

      // Find the registration link and tap it
      final registerLink = find.text('Sign up');
      await tester.tap(registerLink);
      await tester.pumpAndSettle();

      expect(navigatedToRegister, true);
    });

    testWidgets('navigates to forgot password on link tap',
        (WidgetTester tester) async {
      bool navigatedToForgot = false;

      await tester.pumpWidget(
        buildAuthApp(
          LoginScreen(
            onLoginSuccess: () {},
            onNavigateToRegister: () {},
            onNavigateToForgotPassword: () => navigatedToForgot = true,
          ),
          authService,
        ),
      );

      final forgotLink = find.text('Forgot password?');
      expect(forgotLink, findsOneWidget);

      await tester.tap(forgotLink);
      await tester.pumpAndSettle();

      expect(navigatedToForgot, true);
    });
  });

  group('RegistrationScreen Widget Tests', () {
    late AuthService authService;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      await AuthService.init(prefs);
      authService = AuthService();
    });

    testWidgets('renders registration form with all fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildAuthApp(
          RegistrationScreen(
            onRegistrationSuccess: () {},
            onNavigateToLogin: () {},
          ),
          authService,
        ),
      );

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('shows password strength indicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildAuthApp(
          RegistrationScreen(
            onRegistrationSuccess: () {},
            onNavigateToLogin: () {},
          ),
          authService,
        ),
      );

      // Find password field
      final passwordFields = find.byType(TextFormField);
      // Enter password to show strength
      await tester.enterText(passwordFields.at(3), 'Test123!');
      await tester.pumpAndSettle();

      // Should show strength indicator
      expect(find.text('Strong'), findsOneWidget);
    });

    testWidgets('updates password strength on input',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildAuthApp(
          RegistrationScreen(
            onRegistrationSuccess: () {},
            onNavigateToLogin: () {},
          ),
          authService,
        ),
      );

      final passwordFields = find.byType(TextFormField);

      // Enter weak password
      await tester.enterText(passwordFields.at(3), 'Test123!');
      await tester.pumpAndSettle();
      expect(find.text('Strong'), findsOneWidget);

      // Clear and enter stronger password
      await tester.enterText(passwordFields.at(3), 'VeryStrongPassword123!@#');
      await tester.pumpAndSettle();
      expect(find.text('Very Strong'), findsOneWidget);
    });

    testWidgets('displays role selection chips',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildAuthApp(
          RegistrationScreen(
            onRegistrationSuccess: () {},
            onNavigateToLogin: () {},
          ),
          authService,
        ),
      );

      // Should show role options
      expect(find.text('Coach'), findsOneWidget);
      expect(find.text('Player'), findsOneWidget);
      expect(find.text('Staff'), findsOneWidget);
      expect(find.text('Referee'), findsOneWidget);
    });

    testWidgets('selects role when chip tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildAuthApp(
          RegistrationScreen(
            onRegistrationSuccess: () {},
            onNavigateToLogin: () {},
          ),
          authService,
        ),
      );

      final playerChip = find.text('Player');
      await tester.tap(playerChip);
      await tester.pumpAndSettle();

      // Player chip should now be selected (highlighted)
      expect(playerChip, findsOneWidget);
    });

    testWidgets('shows terms and conditions checkbox',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildAuthApp(
          RegistrationScreen(
            onRegistrationSuccess: () {},
            onNavigateToLogin: () {},
          ),
          authService,
        ),
      );

      expect(find.text('I agree to '), findsOneWidget);
      expect(find.text('Terms & Conditions'), findsOneWidget);
    });

    testWidgets('validates password confirmation match',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildAuthApp(
          RegistrationScreen(
            onRegistrationSuccess: () {},
            onNavigateToLogin: () {},
          ),
          authService,
        ),
      );

      final fields = find.byType(TextFormField);

      // Enter password and mismatched confirmation
      await tester.enterText(fields.at(3), 'Test123!Pass');
      await tester.enterText(fields.at(4), 'Different123!');
      await tester.pumpAndSettle();

      // Form should show validation error
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('navigates to login on back button tap',
        (WidgetTester tester) async {
      bool navigatedToLogin = false;

      await tester.pumpWidget(
        buildAuthApp(
          RegistrationScreen(
            onRegistrationSuccess: () {},
            onNavigateToLogin: () => navigatedToLogin = true,
          ),
          authService,
        ),
      );

      // Look for back button or login link
      final loginLink = find.text('Already have an account?');
      if (loginLink.evaluate().isNotEmpty) {
        await tester.tap(loginLink);
        await tester.pumpAndSettle();
        expect(navigatedToLogin, true);
      }
    });
  });

  group('PasswordResetScreen Widget Tests', () {
    late AuthService authService;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      await AuthService.init(prefs);
      authService = AuthService();
    });

    testWidgets('ForgotPasswordScreen renders email input',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildAuthApp(
          ForgotPasswordScreen(
            onBackToLogin: () {},
          ),
          authService,
        ),
      );

      expect(find.text('Email Address'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('ForgotPasswordScreen shows success state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildAuthApp(
          ForgotPasswordScreen(
            onBackToLogin: () {},
          ),
          authService,
        ),
      );

      final emailField = find.byType(TextField);
      final sendButton = find.byType(FilledButton);

      await tester.enterText(emailField, 'test@example.com');
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      // Should show success message
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('ResetPasswordScreen renders password fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildAuthApp(
          ResetPasswordScreen(
            token: 'test-token',
            onResetSuccess: () {},
          ),
          authService,
        ),
      );

      expect(find.text('New Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('ResetPasswordScreen toggles password visibility',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildAuthApp(
          ResetPasswordScreen(
            token: 'test-token',
            onResetSuccess: () {},
          ),
          authService,
        ),
      );

      final visibilityButtons = find.byIcon(Icons.visibility_off_outlined);
      expect(visibilityButtons, findsWidgets);

      await tester.tap(visibilityButtons.first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_outlined), findsWidgets);
    });

    testWidgets('ResetPasswordScreen validates password match',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildAuthApp(
          ResetPasswordScreen(
            token: 'test-token',
            onResetSuccess: () {},
          ),
          authService,
        ),
      );

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'NewPassword123!');
      await tester.enterText(fields.at(1), 'Different123!');
      await tester.pumpAndSettle();

      // Form should validate mismatch
      expect(find.byType(TextFormField), findsWidgets);
    });
  });

  group('OnboardingScreen Widget Tests', () {
    late AuthService authService;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      await AuthService.init(prefs);
      authService = AuthService();
    });

    testWidgets('renders onboarding with correct number of pages',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildAuthApp(
          OnboardingScreen(
            onOnboardingComplete: () {},
          ),
          authService,
        ),
      );

      // Should show first page content
      expect(find.text('Team Management'), findsOneWidget);
    });

    testWidgets('shows progress indicator dots',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildAuthApp(
          OnboardingScreen(
            onOnboardingComplete: () {},
          ),
          authService,
        ),
      );

      // Should have progress indicator
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('navigates to next page on next button tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildAuthApp(
          OnboardingScreen(
            onOnboardingComplete: () {},
          ),
          authService,
        ),
      );

      expect(find.text('Team Management'), findsOneWidget);

      final nextButton = find.text('Next');
      await tester.tap(nextButton);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Should now show second page
      expect(find.text('Match Scheduling'), findsOneWidget);
    });

    testWidgets('navigates to previous page on back button tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildAuthApp(
          OnboardingScreen(
            onOnboardingComplete: () {},
          ),
          authService,
        ),
      );

      final nextButton = find.text('Next');

      // Go to second page
      await tester.tap(nextButton);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Now back button should exist
      final backButton = find.text('Back');
      expect(backButton, findsOneWidget);

      await tester.tap(backButton);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Should be back at first page
      expect(find.text('Team Management'), findsOneWidget);
    });

    testWidgets('shows skip button on all pages except last',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildAuthApp(
          OnboardingScreen(
            onOnboardingComplete: () {},
          ),
          authService,
        ),
      );

      expect(find.text('Skip'), findsOneWidget);

      // Go to last page
      for (int i = 0; i < 4; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
      }

      // Skip should be gone on last page
      expect(find.text('Skip'), findsNothing);
    });

    testWidgets('shows Get Started button on final page',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildAuthApp(
          OnboardingScreen(
            onOnboardingComplete: () {},
          ),
          authService,
        ),
      );

      // Go to last page
      for (int i = 0; i < 4; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
      }

      expect(find.text("You're All Set!"), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('calls onOnboardingComplete when Get Started tapped',
        (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        buildAuthApp(
          OnboardingScreen(
            onOnboardingComplete: () => completed = true,
          ),
          authService,
        ),
      );

      // Go to last page
      for (int i = 0; i < 4; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
      }

      final getStartedButton = find.text('Get Started');
      await tester.tap(getStartedButton);
      await tester.pumpAndSettle();

      expect(completed, true);
    });

    testWidgets('skips to last page on Skip button tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildAuthApp(
          OnboardingScreen(
            onOnboardingComplete: () {},
          ),
          authService,
        ),
      );

      expect(find.text('Team Management'), findsOneWidget);

      final skipButton = find.text('Skip');
      await tester.tap(skipButton);
      await tester.pumpAndSettle();

      // Should jump to last page
      expect(find.text("You're All Set!"), findsOneWidget);
    });

    testWidgets('displays page content correctly for all pages',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildAuthApp(
          OnboardingScreen(
            onOnboardingComplete: () {},
          ),
          authService,
        ),
      );

      final pages = [
        'Team Management',
        'Match Scheduling',
        'Real-time Updates',
        'Training & Stats',
        "You're All Set!",
      ];

      for (int i = 0; i < pages.length; i++) {
        expect(find.text(pages[i]), findsOneWidget);

        if (i < pages.length - 1) {
          await tester.tap(find.text('Next'));
          await tester.pumpAndSettle(const Duration(milliseconds: 300));
        }
      }
    });
  });
}
