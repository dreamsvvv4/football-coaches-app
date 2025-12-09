/// Validation utilities for authentication
class ValidationUtils {
  // Email regex pattern
  static const String _emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  // Username regex (alphanumeric, underscore, dash, 3-20 chars)
  static const String _usernamePattern = r'^[a-zA-Z0-9_-]{3,20}$';

  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (value.length > 254) {
      return 'Email is too long';
    }
    if (!RegExp(_emailPattern).hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  /// Validate username format
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (!RegExp(_usernamePattern).hasMatch(value)) {
      return 'Username must be 3-20 characters (alphanumeric, underscore, dash)';
    }
    return null;
  }

  /// Validate password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!_hasUpperCase(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!_hasLowerCase(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!_hasNumber(value)) {
      return 'Password must contain at least one number';
    }
    if (!_hasSpecialChar(value)) {
      return 'Password must contain at least one special character (@\$!%*?&)';
    }
    return null;
  }

  /// Validate password confirmation
  static String? validatePasswordConfirmation(
    String? value,
    String password,
  ) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validate full name
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }
    if (value.length < 2) {
      return 'Full name must be at least 2 characters';
    }
    if (value.length > 100) {
      return 'Full name must not exceed 100 characters';
    }
    if (!RegExp(r"^[a-zA-Z\s\'-]+$").hasMatch(value)) {
      return 'Full name can only contain letters, spaces, hyphens, and apostrophes';
    }
    return null;
  }

  /// Validate phone number (optional, international format)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    // Accept +1-999-999-9999 or +9999999999999
    if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value.replaceAll(RegExp(r'\D'), ''))) {
      return 'Invalid phone number';
    }
    return null;
  }

  /// Check if string has uppercase
  static bool _hasUpperCase(String value) {
    return RegExp(r'[A-Z]').hasMatch(value);
  }

  /// Check if string has lowercase
  static bool _hasLowerCase(String value) {
    return RegExp(r'[a-z]').hasMatch(value);
  }

  /// Check if string has number
  static bool _hasNumber(String value) {
    return RegExp(r'\d').hasMatch(value);
  }

  /// Check if string has special character
  static bool _hasSpecialChar(String value) {
    return RegExp(r'[@$!%*?&]').hasMatch(value);
  }

  /// Sanitize input (remove leading/trailing whitespace)
  static String sanitizeInput(String value) {
    return value.trim();
  }

  /// Sanitize email (lowercase, trim)
  static String sanitizeEmail(String value) {
    return value.trim().toLowerCase();
  }

  /// Get password strength indicator (0-100)
  static int getPasswordStrength(String password) {
    int strength = 0;

    if (password.length >= 8) strength += 20;
    if (password.length >= 12) strength += 10;
    if (password.length >= 16) strength += 10;

    if (_hasLowerCase(password)) strength += 15;
    if (_hasUpperCase(password)) strength += 15;
    if (_hasNumber(password)) strength += 15;
    if (_hasSpecialChar(password)) strength += 15;

    return strength.clamp(0, 100);
  }

  /// Get password strength label
  static String getPasswordStrengthLabel(int strength) {
    if (strength < 30) return 'Weak';
    if (strength < 60) return 'Fair';
    if (strength < 80) return 'Good';
    if (strength < 100) return 'Strong';
    return 'Very Strong';
  }

  /// Get password strength color (0 = weak red, 100 = strong green)
  static double getPasswordStrengthHue(int strength) {
    // Red (0°) to Green (120°) spectrum
    return (strength / 100) * 120;
  }
}
