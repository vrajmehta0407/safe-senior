// lib/state/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user_profile.dart';

class AuthState {
  final UserProfile? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({this.user, this.isLoading = false, this.errorMessage});

  AuthState copyWith({UserProfile? user, bool? isLoading, String? errorMessage}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
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

  Future<bool> resetPassword(String email, String newPassword) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await AuthService.resetPassword(email: email, newPassword: newPassword);
    if (result.success) {
      state = AuthState();
      return true;
    } else {
      state = AuthState(errorMessage: result.message);
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
