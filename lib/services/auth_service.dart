// lib/services/auth_service.dart
// Local-first authentication: signup, login, reset password using SHA-256 hashing.

import '../models/user_profile.dart';
import '../storage/user_store.dart';
import '../storage/local_preferences.dart';
import '../utils/password_hasher.dart';
import '../utils/constants.dart';

enum AuthError {
  emailAlreadyExists,
  invalidCredentials,
  emailNotFound,
  weakPassword,
  unknown,
}

class AuthResult {
  final bool success;
  final UserProfile? user;
  final AuthError? error;
  final String? message;

  const AuthResult._({
    required this.success,
    this.user,
    this.error,
    this.message,
  });

  factory AuthResult.success(UserProfile user) =>
      AuthResult._(success: true, user: user);

  factory AuthResult.failure(AuthError error, String message) =>
      AuthResult._(success: false, error: error, message: message);
}

class AuthService {
  /// Registers a new user. Returns an [AuthResult] with success or error.
  static Future<AuthResult> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      // Validate passwords match
      if (password != confirmPassword) {
        return AuthResult.failure(AuthError.weakPassword, 'Passwords do not match.');
      }
      if (password.length < 6) {
        return AuthResult.failure(AuthError.weakPassword, 'Password must be at least 6 characters.');
      }

      // Check if email is taken
      if (UserStore.emailExists(email.toLowerCase())) {
        return AuthResult.failure(AuthError.emailAlreadyExists, 'An account with this email already exists.');
      }

      // Create user
      final now = DateTime.now();
      final user = UserProfile(
        name: name.trim(),
        email: email.toLowerCase().trim(),
        phone: phone.trim(),
        passwordHash: PasswordHasher.hash(password),
        createdAt: now,
        trialStartDate: now, // 7-day free trial starts at signup
      );

      await UserStore.saveUser(user);
      await LocalPreferences.setCurrentUserEmail(user.email);
      await LocalPreferences.setTrialStartDate(now);

      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.failure(AuthError.unknown, 'Sign up failed. Please try again.');
    }
  }

  /// Authenticates an existing user. Returns an [AuthResult].
  static Future<AuthResult> login({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      final input = emailOrPhone.trim().toLowerCase();

      // Find by email directly or scan all users for phone match
      UserProfile? user = UserStore.getUserByEmail(input);

      if (user == null) {
        // Try phone lookup
        final allUsers = UserStore.getAllUsers();
        try {
          user = allUsers.firstWhere(
            (u) => u.phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '') ==
                input.replaceAll(RegExp(r'[\s\-\(\)\+]'), ''),
          );
        } catch (_) {
          user = null;
        }
      }

      if (user == null) {
        return AuthResult.failure(AuthError.invalidCredentials, 'No account found with that email or phone.');
      }

      if (!PasswordHasher.verify(password, user.passwordHash)) {
        return AuthResult.failure(AuthError.invalidCredentials, 'Incorrect password. Please try again.');
      }

      // Persist session
      await LocalPreferences.setCurrentUserEmail(user.email);

      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.failure(AuthError.unknown, 'Login failed. Please try again.');
    }
  }

  /// Resets password using email + new password.
  /// NOTE: The reset_password_screen.dart shows an email + security question UI.
  /// Since no security questions were stored at signup, we use email existence as the
  /// "answer" gate — matching the simplified flow visible in the existing screen.
  static Future<AuthResult> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final user = UserStore.getUserByEmail(normalizedEmail);

      if (user == null) {
        return AuthResult.failure(AuthError.emailNotFound, 'No account found with that email address.');
      }

      if (newPassword.length < 6) {
        return AuthResult.failure(AuthError.weakPassword, 'New password must be at least 6 characters.');
      }

      user.passwordHash = PasswordHasher.hash(newPassword);
      await user.save();

      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.failure(AuthError.unknown, 'Password reset failed. Please try again.');
    }
  }

  /// Logs the current user out.
  static Future<void> logout() async {
    await LocalPreferences.clearCurrentUserEmail();
  }

  /// Returns the currently logged-in user, or null.
  static UserProfile? getCurrentUser() {
    final email = LocalPreferences.getCurrentUserEmail();
    if (email == null) return null;
    return UserStore.getUserByEmail(email);
  }

  static bool get isLoggedIn => LocalPreferences.isLoggedIn();
}
