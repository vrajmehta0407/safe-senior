// lib/state/auth_provider.dart
// Riverpod provider for authentication state including OTP/2FA flows.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user_profile.dart';

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

  Future<bool> resetPassword(String email, String newPassword, {String? otpCode}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await AuthService.resetPassword(
      email: email,
      newPassword: newPassword,
      otpCode: otpCode,
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
    final result = await AuthService.requestOtp(phoneNumber: phoneNumber, purpose: purpose);
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
      phoneNumber: phoneNumber,
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

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
