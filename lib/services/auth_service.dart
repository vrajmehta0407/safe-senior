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
        return AuthResult.failure(AuthError.weakPassword, 'PINs/Passwords do not match.');
      }
      if (password.length < 4) {
        return AuthResult.failure(AuthError.weakPassword, 'PIN must be at least 4 digits.');
      }
      if (email.isNotEmpty && UserStore.emailExists(email.toLowerCase())) {
        // Update existing user or return success
        final existing = UserStore.getUserByEmail(email.toLowerCase())!;
        existing.passwordHash = PasswordHasher.hash(password);
        await UserStore.saveUser(existing);
        await LocalPreferences.setCurrentUserEmail(existing.email);
        _syncSignupToBackend(name: name, email: email, phone: phone, password: password);
        return AuthResult.success(existing);
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

  /// Registers locally AND syncs to backend. Returns backend JWT if sync succeeds.
  /// Called by signup screen — must await so user exists in DB before OTP is requested.
  static Future<String?> syncSignupToBackend({
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
        final token = resp['token'].toString();
        await LocalPreferences.setJwtToken(token);
        return token;
      }
    } catch (e) {
      if (kDebugMode) print('[AuthService] Backend signup sync failed (offline): $e');
    }
    return null;
  }

  static void _syncSignupToBackend({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await syncSignupToBackend(name: name, email: email, phone: phone, password: password);
  }

  /// Authenticates locally; if local check fails or user not found, falls back to backend API.
  static Future<AuthResult> login({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      final input = emailOrPhone.trim();
      final inputLower = input.toLowerCase();

      // 1. Try local cache lookup
      UserProfile? user = UserStore.getUserByEmail(inputLower) ?? UserStore.getUserByPhone(input);

      if (user != null && PasswordHasher.verify(password, user.passwordHash)) {
        await LocalPreferences.setCurrentUserEmail(user.email);
        // Sync JWT in background
        syncLoginToBackend(phoneOrEmail: emailOrPhone, password: password);
        return AuthResult.success(user);
      }

      // 2. Fallback to backend API authentication
      try {
        final resp = await ApiClient.login(phoneOrEmail: input, password: password);
        if (resp != null && resp['success'] == true && resp['user'] != null) {
          final uMap = resp['user'] as Map<String, dynamic>;
          final token = resp['token']?.toString();
          if (token != null) {
            await LocalPreferences.setJwtToken(token);
          }

          final remoteEmail = (uMap['email'] as String? ?? '').toLowerCase().trim();
          final remotePhone = (uMap['phone_number'] as String? ?? '').trim();
          final remoteName = (uMap['name'] as String? ?? 'User').trim();

          user = UserProfile(
            name: remoteName,
            email: remoteEmail.isNotEmpty ? remoteEmail : (user?.email ?? '${input.replaceAll(RegExp(r'\D'), '')}@safesenior.app'),
            phone: remotePhone.isNotEmpty ? remotePhone : (user?.phone ?? input),
            passwordHash: PasswordHasher.hash(password),
            createdAt: DateTime.tryParse(uMap['created_at']?.toString() ?? '') ?? DateTime.now(),
            isPremium: true,
          );

          await UserStore.saveUser(user);
          await LocalPreferences.setCurrentUserEmail(user.email);
          return AuthResult.success(user);
        }
      } catch (backendErr) {
        if (kDebugMode) print('[AuthService] Backend login fallback error: $backendErr');
      }

      // If user was found locally but password failed
      if (user != null) {
        return AuthResult.failure(AuthError.invalidCredentials, 'Incorrect PIN. Please try again.');
      }

      return AuthResult.failure(AuthError.invalidCredentials, 'No account found with this phone number or email.');
    } catch (e) {
      if (kDebugMode) print('[AuthService] login error: $e');
      return AuthResult.failure(AuthError.unknown, 'Login failed. Please try again.');
    }
  }

  /// Syncs login to backend and saves JWT if successful.
  static Future<String?> syncLoginToBackend({
    required String phoneOrEmail,
    required String password,
  }) async {
    try {
      final resp = await ApiClient.login(phoneOrEmail: phoneOrEmail, password: password);
      if (resp != null && resp['token'] != null) {
        final token = resp['token'].toString();
        await LocalPreferences.setJwtToken(token);
        return token;
      }
    } catch (e) {
      if (kDebugMode) print('[AuthService] Backend login sync failed (offline): $e');
    }
    return null;
  }

  // ─── OTP / 2FA ─────────────────────────────────────────────────────────────

  /// Request an OTP for the given identifier (email or phone) and purpose.
  /// OTP is sent to the user's registered email address.
  static Future<AuthResult> requestOtp({
    String? identifier,    // email or phone — preferred
    String? phoneNumber,   // legacy fallback
    required String purpose,
  }) async {
    try {
      final id = identifier ?? phoneNumber;
      if (id == null || id.isEmpty) {
        return AuthResult.failure(AuthError.unknown, 'Please provide an email or phone number.');
      }
      final resp = await ApiClient.requestOtp(
        identifier: id,
        purpose: purpose,
      );
      if (resp == null) {
        return AuthResult.failure(AuthError.network, 'Could not send OTP. Check your internet connection.');
      }
      if (resp['error'] == true) {
        return AuthResult.failure(AuthError.unknown, resp['message']?.toString() ?? 'OTP request failed.');
      }
      return AuthResult.requiresOtp('OTP sent to your registered email address.');
    } catch (e) {
      return AuthResult.failure(AuthError.network, 'Could not send OTP. Please try again.');
    }
  }

  /// Verify an OTP code entered by the user.
  static Future<bool> verifyOtp({
    String? identifier,    // email or phone — preferred
    String? phoneNumber,   // legacy fallback
    required String code,
    required String purpose,
  }) async {
    try {
      final resp = await ApiClient.verifyOtp(
        identifier: identifier ?? phoneNumber,
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

  /// BUG 2 FIX: reset is phone-based end-to-end (matches backend POST /auth/reset-password).
  /// OTP must be requested via requestOtp(purpose: 'reset') before calling this.
  static Future<AuthResult> resetPassword({
    required String phoneNumber,
    required String otpCode,
    required String newPassword,
  }) async {
    try {
      final trimmedPhone = phoneNumber.trim();

      if (newPassword.length < 8) {
        return AuthResult.failure(AuthError.weakPassword, 'New password must be at least 8 characters.');
      }
      if (otpCode.isEmpty) {
        return AuthResult.failure(AuthError.otpInvalid, 'Please enter the OTP sent to your phone.');
      }

      // Backend reset (authoritative — OTP verified server-side)
      final resp = await ApiClient.resetPassword(
        phoneNumber: trimmedPhone,
        otpCode: otpCode,
        newPassword: newPassword,
      );

      if (resp == null) {
        return AuthResult.failure(AuthError.network, 'Could not reach server. Please try again.');
      }
      if (resp['error'] == true || resp['success'] == false) {
        final msg = resp['message']?.toString() ?? 'Reset failed. Please try again.';
        return AuthResult.failure(AuthError.otpInvalid, msg);
      }

      // Also update local Hive copy if user is stored locally (offline-first)
      final user = UserStore.getUserByPhone(trimmedPhone);
      if (user != null) {
        user.passwordHash = PasswordHasher.hash(newPassword);
        await user.save();
      }

      // Return a dummy success user (screen only needs success=true)
      return AuthResult._(success: true);
    } catch (e) {
      if (kDebugMode) print('[AuthService] resetPassword error: $e');
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
