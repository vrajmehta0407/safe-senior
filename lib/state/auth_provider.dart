// lib/state/auth_provider.dart
// Riverpod provider for authentication state including OTP/2FA flows.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user_profile.dart';
import '../storage/user_store.dart';

class AuthState {
  final UserProfile? user;
  final bool isLoading;
  final String? errorMessage;
  final bool otpRequired;
  final String? pendingPhone; // phone waiting for OTP verification

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.otpRequired = false,
    this.pendingPhone,
  });

  AuthState copyWith({
    UserProfile? user,
    bool? isLoading,
    String? errorMessage,
    bool? otpRequired,
    String? pendingPhone,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      otpRequired: otpRequired ?? this.otpRequired,
      pendingPhone: pendingPhone ?? this.pendingPhone,
    );
  }

  bool get isLoggedIn => user != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(user: AuthService.getCurrentUser()));

  Future<bool> login(String emailOrPhone, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await AuthService.login(emailOrPhone: emailOrPhone, password: password);
    if (result.success) {
      state = AuthState(user: result.user);
      return true;
    } else {
      state = AuthState(errorMessage: result.message);
      return false;
    }
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await AuthService.signup(
      name: name,
      email: email,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
    );
    if (result.success) {
      state = AuthState(user: result.user);
      return true;
    } else {
      state = AuthState(errorMessage: result.message);
      return false;
    }
  }

  /// BUG 2 FIX: phone-based reset with mandatory OTP verification.
  Future<bool> resetPassword(String phoneNumber, String otpCode, String newPassword) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await AuthService.resetPassword(
      phoneNumber: phoneNumber,
      otpCode: otpCode,
      newPassword: newPassword,
    );
    if (result.success) {
      state = const AuthState();
      return true;
    } else {
      state = AuthState(errorMessage: result.message);
      return false;
    }
  }

  // ─── OTP ────────────────────────────────────────────────────────────────────

  /// Requests OTP for phone — sets otpRequired=true if request succeeds.
  Future<bool> requestOtp({required String phoneNumber, required String purpose}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await AuthService.requestOtp(identifier: phoneNumber, purpose: purpose);
    if (result.otpRequired) {
      state = AuthState(
        user: state.user,
        otpRequired: true,
        pendingPhone: phoneNumber,
      );
      return true;
    } else {
      state = AuthState(
        user: state.user,
        errorMessage: result.message,
      );
      return false;
    }
  }

  /// Verifies OTP code. Returns true if verified.
  Future<bool> verifyOtp({
    required String phoneNumber,
    required String code,
    required String purpose,
  }) async {
    state = state.copyWith(isLoading: true);
    final verified = await AuthService.verifyOtp(
      identifier: phoneNumber,
      code: code,
      purpose: purpose,
    );
    if (verified) {
      state = AuthState(user: state.user, otpRequired: false);
    } else {
      state = AuthState(
        user: state.user,
        otpRequired: true,
        pendingPhone: phoneNumber,
        errorMessage: 'Invalid OTP. Please try again.',
      );
    }
    return verified;
  }

  Future<void> logout() async {
    await AuthService.logout();
    state = const AuthState();
  }

  /// Restores auth state from a user map (returned by GET /auth/me).
  /// Called after successful biometric authentication to rebuild the session
  /// without requiring the user to re-enter credentials.
  Future<void> restoreSession(Map<String, dynamic> userMap) async {
    try {
      // Build a UserProfile from the /auth/me response
      final email = (userMap['email'] as String? ?? '').toLowerCase();

      // Try to get existing local record first (preserves isPremium, avatar, etc.)
      UserProfile? existing = UserStore.getUserByEmail(email);

      if (existing == null) {
        // Create a minimal profile from the server response
        existing = UserProfile(
          name:         userMap['name']         as String? ?? '',
          email:        email,
          phone:        userMap['phone_number']  as String? ?? '',
          passwordHash: '',
          createdAt:    DateTime.tryParse(userMap['created_at'] as String? ?? '') ?? DateTime.now(),
        );
        await UserStore.saveUser(existing);
      }
      state = AuthState(user: existing);
    } catch (e) {
      state = const AuthState(errorMessage: 'Failed to restore session.');
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void setLocalUser(UserProfile user) {
    state = AuthState(user: user);
  }

  /// Updates the locally-stored avatar path and refreshes state so
  /// all widgets watching [authProvider] rebuild with the new photo.
  Future<void> updateAvatarPath(String avatarPath) async {
    final user = state.user;
    if (user == null) return;
    await UserStore.updateAvatarPath(user.email, avatarPath);
    // Reload from store to get updated object
    final updated = UserStore.getUserByEmail(user.email);
    if (updated != null) {
      state = state.copyWith(user: updated);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
