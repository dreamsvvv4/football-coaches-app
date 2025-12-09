import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'package:mobile_flutter/screens/auth/login_screen.dart';
import 'package:mobile_flutter/screens/auth/registration_screen.dart';
import 'package:mobile_flutter/screens/auth/password_reset_screen.dart';
import 'package:mobile_flutter/screens/auth/onboarding_screen.dart';

enum AuthScreenState {
  login,
  registration,
  forgotPassword,
  resetPassword,
  onboarding,
}

/// AuthWrapper manages navigation between all authentication screens
/// and routes to main app once user is authenticated and onboarding is complete.
class AuthWrapper extends StatefulWidget {
  final Widget Function() homeBuilder;

  const AuthWrapper({
    required this.homeBuilder,
    Key? key,
  }) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late AuthScreenState _currentScreen;
  String? _resetPasswordToken;

  @override
  void initState() {
    super.initState();
    _currentScreen = AuthScreenState.login;

    // Removed auto-login to show proper login/registration screens
  }

  void _navigateToRegistration() {
    setState(() {
      _currentScreen = AuthScreenState.registration;
    });
  }

  void _navigateToForgotPassword() {
    setState(() {
      _currentScreen = AuthScreenState.forgotPassword;
    });
  }

  void _navigateToLogin() {
    setState(() {
      _currentScreen = AuthScreenState.login;
    });
  }

  void _navigateToOnboarding() {
    setState(() {
      _currentScreen = AuthScreenState.onboarding;
    });
  }

  void _handleLoginSuccess() {
    // Check if user needs to complete onboarding
    final authService = context.read<AuthService>();
    if (authService.isFirstLogin) {
      _navigateToOnboarding();
    } else {
      // User is fully authenticated, app will show main screen
      // (handled by parent widget listening to authService state)
    }
  }

  void _handleRegistrationSuccess() {
    // New users should complete onboarding after registration
    final authService = context.read<AuthService>();
    if (authService.isFirstLogin) {
      _navigateToOnboarding();
    }
  }

  void _handleResetPasswordSuccess() {
    // After successful password reset, return to login
    _navigateToLogin();
  }

  void _handleOnboardingComplete() {
    // Onboarding is done, user is ready for main app
    // The main app is shown based on authService.isAuthenticated state
    // This is handled by the parent widget
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        // If user is not authenticated, show auth screens
        if (!authService.isAuthenticated) {
          switch (_currentScreen) {
            case AuthScreenState.login:
              return LoginScreen(
                onLoginSuccess: _handleLoginSuccess,
                onNavigateToRegister: _navigateToRegistration,
                onNavigateToForgotPassword: _navigateToForgotPassword,
              );

            case AuthScreenState.registration:
              return RegistrationScreen(
                onRegistrationSuccess: _handleRegistrationSuccess,
                onNavigateToLogin: _navigateToLogin,
              );

            case AuthScreenState.forgotPassword:
              return ForgotPasswordScreen(
                onBackToLogin: _navigateToLogin,
              );

            case AuthScreenState.resetPassword:
              return ResetPasswordScreen(
                token: _resetPasswordToken ?? '',
                onResetSuccess: _handleResetPasswordSuccess,
              );

            case AuthScreenState.onboarding:
              return OnboardingScreen(
                onOnboardingComplete: _handleOnboardingComplete,
              );
          }
        }

        // If user is authenticated but hasn't completed onboarding
        if (authService.isFirstLogin) {
          return OnboardingScreen(
            onOnboardingComplete: _handleOnboardingComplete,
          );
        }

        // User is fully authenticated and onboarding is complete
        return widget.homeBuilder();
      },
    );
  }
}
