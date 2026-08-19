// lib/state/admin_provider.dart
// In-memory admin auth state — token is NEVER persisted to disk.

import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminState {
  final String? token;
  final String? adminName;
  final String? adminRole;
  final bool isLoading;
  final String? errorMessage;

  const AdminState({
    this.token,
    this.adminName,
    this.adminRole,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isLoggedIn => token != null;

  AdminState copyWith({
    String? token,
    String? adminName,
    String? adminRole,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool clearToken = false,
  }) {
    return AdminState(
      token:        clearToken ? null : (token ?? this.token),
      adminName:    clearToken ? null : (adminName ?? this.adminName),
      adminRole:    clearToken ? null : (adminRole ?? this.adminRole),
      isLoading:    isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  AdminNotifier() : super(const AdminState());

  void setSession({
    required String token,
    required String name,
    required String role,
  }) {
    state = AdminState(token: token, adminName: name, adminRole: role);
  }

  void setLoading(bool v) => state = state.copyWith(isLoading: v);

  void setError(String msg) =>
      state = state.copyWith(isLoading: false, errorMessage: msg);

  void clearError() => state = state.copyWith(clearError: true);

  void logout() => state = state.copyWith(clearToken: true);
}

final adminProvider =
    StateNotifierProvider<AdminNotifier, AdminState>((ref) => AdminNotifier());
