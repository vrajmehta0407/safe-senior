// lib/utils/validators.dart
// Reusable form validators for all existing form fields.

class Validators {
  /// Validates email or phone number (used in login screen).
  static String? emailOrPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email or phone number.';
    }
    final trimmed = value.trim();
    // Check if it looks like an email
    if (trimmed.contains('@')) {
      return email(trimmed);
    }
    // Otherwise validate as phone
    return phone(trimmed);
  }

  /// Validates email format.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address.';
    }
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  /// Validates phone number (basic, 7–15 digits, optional +/spaces/dashes).
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number.';
    }
    final digits = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    if (digits.length < 7 || digits.length > 15) {
      return 'Please enter a valid phone number.';
    }
    if (!RegExp(r'^\d+$').hasMatch(digits)) {
      return 'Phone number must contain only digits.';
    }
    return null;
  }

  /// Validates password strength (min 6 chars).
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  /// Confirms two passwords match.
  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }
    if (value != original) {
      return 'Passwords do not match.';
    }
    return null;
  }

  /// Validates a full name.
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name.';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters.';
    }
    return null;
  }

  /// Non-empty generic field.
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }
}
