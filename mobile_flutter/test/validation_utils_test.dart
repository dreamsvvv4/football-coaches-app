import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/utils/validation_utils.dart';

void main() {
  group('ValidationUtils', () {
    // Email validation tests
    group('validateEmail', () {
      test('rejects empty email', () {
        expect(ValidationUtils.validateEmail(''), isNotNull);
        expect(ValidationUtils.validateEmail(null), isNotNull);
      });

      test('accepts valid emails', () {
        expect(ValidationUtils.validateEmail('coach@example.com'), isNull);
        expect(ValidationUtils.validateEmail('player.name@team.co.uk'), isNull);
        expect(ValidationUtils.validateEmail('user+tag@domain.org'), isNull);
      });

      test('rejects invalid emails', () {
        expect(ValidationUtils.validateEmail('invalid'), isNotNull);
        expect(ValidationUtils.validateEmail('invalid@'), isNotNull);
        expect(ValidationUtils.validateEmail('@example.com'), isNotNull);
      });

      test('rejects overly long emails', () {
        final longEmail = '${'a' * 255}@example.com';
        expect(ValidationUtils.validateEmail(longEmail), isNotNull);
      });
    });

    // Username validation tests
    group('validateUsername', () {
      test('rejects empty username', () {
        expect(ValidationUtils.validateUsername(''), isNotNull);
        expect(ValidationUtils.validateUsername(null), isNotNull);
      });

      test('accepts valid usernames', () {
        expect(ValidationUtils.validateUsername('john_coach'), isNull);
        expect(ValidationUtils.validateUsername('player-123'), isNull);
        expect(ValidationUtils.validateUsername('Coach2024'), isNull);
      });

      test('rejects invalid usernames', () {
        expect(ValidationUtils.validateUsername('ab'), isNotNull); // Too short
        expect(ValidationUtils.validateUsername('a@b'), isNotNull); // Invalid char
        expect(
          ValidationUtils.validateUsername('a' * 21),
          isNotNull,
        ); // Too long
      });
    });

    // Password validation tests
    group('validatePassword', () {
      test('rejects empty password', () {
        expect(ValidationUtils.validatePassword(''), isNotNull);
        expect(ValidationUtils.validatePassword(null), isNotNull);
      });

      test('rejects short passwords', () {
        expect(ValidationUtils.validatePassword('Pass1!'), isNotNull);
      });

      test('rejects passwords without uppercase', () {
        expect(ValidationUtils.validatePassword('password123!'), isNotNull);
      });

      test('rejects passwords without lowercase', () {
        expect(ValidationUtils.validatePassword('PASSWORD123!'), isNotNull);
      });

      test('rejects passwords without numbers', () {
        expect(ValidationUtils.validatePassword('Password!'), isNotNull);
      });

      test('rejects passwords without special characters', () {
        expect(ValidationUtils.validatePassword('Password123'), isNotNull);
      });

      test('accepts valid passwords', () {
        expect(ValidationUtils.validatePassword('Coach123!'), isNull);
        expect(ValidationUtils.validatePassword('MySecure@Pass2024'), isNull);
      });
    });

    // Password confirmation tests
    group('validatePasswordConfirmation', () {
      test('rejects empty confirmation', () {
        expect(
          ValidationUtils.validatePasswordConfirmation('', 'Coach123!'),
          isNotNull,
        );
        expect(
          ValidationUtils.validatePasswordConfirmation(null, 'Coach123!'),
          isNotNull,
        );
      });

      test('rejects mismatched passwords', () {
        expect(
          ValidationUtils.validatePasswordConfirmation(
            'Coach123!',
            'Different123!',
          ),
          isNotNull,
        );
      });

      test('accepts matching passwords', () {
        expect(
          ValidationUtils.validatePasswordConfirmation('Coach123!', 'Coach123!'),
          isNull,
        );
      });
    });

    // Full name validation tests
    group('validateFullName', () {
      test('rejects empty name', () {
        expect(ValidationUtils.validateFullName(''), isNotNull);
        expect(ValidationUtils.validateFullName(null), isNotNull);
      });

      test('rejects very short names', () {
        expect(ValidationUtils.validateFullName('A'), isNotNull);
      });

      test('accepts valid names', () {
        expect(ValidationUtils.validateFullName('John Doe'), isNull);
        expect(ValidationUtils.validateFullName('Mary Jane'), isNull);
      });

      test('rejects names with invalid characters', () {
        expect(ValidationUtils.validateFullName('John123'), isNotNull);
        expect(ValidationUtils.validateFullName('John@Doe'), isNotNull);
      });
    });

    // Password strength tests
    group('getPasswordStrength', () {
      test('short password has low to medium strength', () {
        final strength = ValidationUtils.getPasswordStrength('Short1!');
        expect(strength, greaterThan(0));
        expect(strength, lessThan(100));
      });

      test('medium password has medium strength', () {
        final strength =
            ValidationUtils.getPasswordStrength('Medium123!Pass');
        expect(strength, greaterThan(40));
        expect(strength, lessThan(100));
      });

      test('strong password has high strength', () {
        final strength =
            ValidationUtils.getPasswordStrength('VeryStrong123!@#');
        expect(strength, greaterThan(70));
      });
    });

    // Password strength labels tests
    group('getPasswordStrengthLabel', () {
      test('returns correct labels for strengths', () {
        expect(ValidationUtils.getPasswordStrengthLabel(20), 'Weak');
        expect(ValidationUtils.getPasswordStrengthLabel(50), 'Fair');
        expect(ValidationUtils.getPasswordStrengthLabel(70), 'Good');
        expect(ValidationUtils.getPasswordStrengthLabel(90), 'Strong');
        expect(ValidationUtils.getPasswordStrengthLabel(100), 'Very Strong');
      });
    });

    // Input sanitization tests
    group('sanitization', () {
      test('sanitizeInput removes whitespace', () {
        expect(
          ValidationUtils.sanitizeInput('  John Doe  '),
          'John Doe',
        );
      });

      test('sanitizeEmail lowercases and trims', () {
        expect(
          ValidationUtils.sanitizeEmail('  COACH@EXAMPLE.COM  '),
          'coach@example.com',
        );
      });
    });
  });
}
