// lib/services/auth_service.dart
// Local-first authentication with optional backend sync.
// Strategy: always validate locally first; sync to backend asynchronously.

import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../storage/user_store.dart';
import '../storage/local_preferences.dart';
import '../utils/password_hasher.dart';
import 'api_client.dart';

enum AuthError {
  emailAlreadyExists,
  invalidCredentials,
  emailNotFound,
  weakPassword,
  otpRequired,
  otpInvalid,
  network,
  unknown,
}

class AuthResult {
  final bool success;
  final UserProfile? user;
  final AuthError? error;
  final String? message;
  final bool otpRequired;

  const AuthResult._({
    required this.success,
    this.user,
    this.error,
    this.message,
    this.otpRequired = false,
  });

  factory AuthResult.success(UserProfile user) =>
      AuthResult._(success: true, user: user);

  factory AuthResult.failure(AuthError error, String message) =>
      AuthResult._(success: false, error: error, message: message);

  factory AuthResult.requiresOtp(String message) =>
      AuthResult._(success: false, error: AuthError.otpRequired, message: message, otpRequired: true);
}

class AuthService {
  /// Registers a new user locally, then syncs to backend.
  static Future<AuthResult> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      if (password != confirmPassword) {
        return AuthResult.failure(AuthError.weakPassword, 'Passwords do not match.');
      }
      if (password.length < 6) {
        return AuthResult.failure(AuthError.weakPassword, 'Password must be at least 6 characters.');
      }
      if (UserStore.emailExists(email.toLowerCase())) {
        return AuthResult.failure(AuthError.emailAlreadyExists, 'An account with this email already exists.');
      }

      final now = DateTime.now();
      final user = UserProfile(
        name: name.trim(),
        email: email.toLowerCase().trim(),
        phone: phone.trim(),
        passwordHash: PasswordHasher.hash(password),
        createdAt: now,
        trialStartDate: now,
      );

      await UserStore.saveUser(user);
      await LocalPreferences.setCurrentUserEmail(user.email);
      await LocalPreferences.setTrialStartDate(now);

      // Background sync — don't block signup on network failure
      _syncSignupToBackend(name: name, email: email, phone: phone, password: password);

      return AuthResult.success(user);
    } catch (e) {
      if (kDebugMode) print('[AuthService] signup error: $e');
      return AuthResult.failure(AuthError.unknown, 'Sign up failed. Please try again.');
    }
  }

  static void _syncSignupToBackend({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final resp = await ApiClient.signup(
        name: name,
        phoneNumber: phone,
        email: email,
        password: password,
      );
      if (resp != null && resp['token'] != null) {
        await LocalPreferences.setJwtToken(resp['token'].toString());
      }
    } catch (e) {
      if (kDebugMode) print('[AuthService] Backend signup sync failed (offline): $e');
    }
  }

  /// Authenticates locally; if backend is reachable, validates JWT token too.
  static Future<AuthResult> login({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      final input = emailOrPhone.trim().toLowerCase();

      UserProfile? user = UserStore.getUserByEmail(input);
      if (user == null) {
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

      await LocalPreferences.setCurrentUserEmail(user.email);

      // Background: sync JWT from backend
      _syncLoginToBackend(identifier: emailOrPhone, password: password);

      return AuthResult.success(user);
    } catch (e) {
      if (kDebugMode) print('[AuthService] login error: $e');
      return AuthResult.failure(AuthError.unknown, 'Login failed. Please try again.');
    }
  }

  static void _syncLoginToBackend({
    required String identifier,
    required String password,
  }) async {
    try {
      final resp = await ApiClient.login(identifier: identifier, password: password);
      if (resp != null && resp['token'] != null) {
        await LocalPreferences.setJwtToken(resp['token'].toString());
      }
    } catch (e) {
      if (kDebugMode) print('[AuthService] Backend login sync failed (offline): $e');
    }
  }

  // ─── OTP / 2FA ─────────────────────────────────────────────────────────────

  /// Request an OTP for the given phone number and purpose.
  static Future<AuthResult> requestOtp({
    required String phoneNumber,
    required String purpose,
  }) async {
    try {
      final resp = await ApiClient.requestOtp(phoneNumber: phoneNumber, purpose: purpose);
      if (resp == null) {
        return AuthResult.failure(AuthError.network, 'Could not send OTP. Check your internet connection.');
      }
      if (resp['error'] == true) {
        return AuthResult.failure(AuthError.unknown, resp['message']?.toString() ?? 'OTP request failed.');
      }
      return AuthResult.requiresOtp('OTP sent to $phoneNumber');
    } catch (e) {
      return AuthResult.failure(AuthError.network, 'Could not send OTP. Please try again.');
    }
  }

  /// Verify an OTP code entered by the user.
  static Future<bool> verifyOtp({
    required String phoneNumber,
    required String code,
    required String purpose,
  }) async {
    try {
      final resp = await ApiClient.verifyOtp(
        phoneNumber: phoneNumber,
        code: code,
        purpose: purpose,
      );
      if (resp == null) return false;
      return resp['verified'] == true || resp['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // ─── Reset Password ─────────────────────────────────────────────────────────

  static Future<AuthResult> resetPassword({
    required String email,
    required String newPassword,
    String? otpCode,
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

      // Local reset
      user.passwordHash = PasswordHasher.hash(newPassword);
      await user.save();

      // Backend sync if OTP provided
      if (otpCode != null && otpCode.isNotEmpty) {
        ApiClient.resetPassword(
          email: normalizedEmail,
          otpCode: otpCode,
          newPassword: newPassword,
        );
      }

      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.failure(AuthError.unknown, 'Password reset failed. Please try again.');
    }
  }

  // ─── Session ───────────────────────────────────────────────────────────────

  static Future<void> logout() async {
    await LocalPreferences.clearCurrentUserEmail();
    await LocalPreferences.clearJwtToken();
  }

  static UserProfile? getCurrentUser() {
    final email = LocalPreferences.getCurrentUserEmail();
    if (email == null) return null;
    return UserStore.getUserByEmail(email);
  }

  static bool get isLoggedIn => LocalPreferences.isLoggedIn();
}
