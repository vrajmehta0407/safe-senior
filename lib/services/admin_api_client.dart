// lib/services/admin_api_client.dart
// Dio client scoped to the admin route prefix.
// Token is pulled lazily from AdminProvider — never stored on disk.

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/admin_provider.dart';

// Keep in sync with ADMIN_ROUTE_PREFIX in backend .env
const _kAdminPrefix = '/api/ops-4e9f2c1a';

String get _adminBase {
  if (Platform.isAndroid) return 'http://192.168.31.53:3000$_kAdminPrefix';
  return 'http://localhost:3000$_kAdminPrefix';
}

class AdminApiClient {
  final Ref _ref;
  AdminApiClient(this._ref);

  Dio get _dio {
    final token = _ref.read(adminProvider).token;
    return Dio(
      BaseOptions(
        baseUrl: _adminBase,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  // ── Auth ────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    return _post('/auth/login', {'email': email, 'password': password});
  }

  // ── Stats ───────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getStats() => _get('/stats/overview');

  // ── Users ───────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getUsers({
    int limit = 20,
    int offset = 0,
    String? search,
  }) => _get('/users', params: {
        'limit': limit,
        'offset': offset,
        if (search != null && search.isNotEmpty) 'search': search,
      });

  Future<Map<String, dynamic>?> getUser(int userId) =>
      _get('/users/$userId');

  Future<Map<String, dynamic>?> suspendUser(int userId, {required bool suspend}) =>
      _patch('/users/$userId', {'is_suspended': suspend});

  Future<Map<String, dynamic>?> deleteUser(int userId) =>
      _delete('/users/$userId');

  // ── Scam Reports ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getScamReports({
    int limit = 50,
    int offset = 0,
    String? classification,
    String? type,
  }) => _get('/scam-reports', params: {
        'limit': limit,
        'offset': offset,
        if (classification != null) 'classification': classification,
        if (type != null) 'type': type,
      });

  // ── Scam Patterns ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getPatterns({
    int limit = 50,
    int offset = 0,
    String? severity,
    String? active,
  }) => _get('/scam-patterns', params: {
        'limit': limit,
        'offset': offset,
        if (severity != null) 'severity': severity,
        if (active != null) 'active': active,
      });

  Future<Map<String, dynamic>?> createPattern(Map<String, dynamic> body) =>
      _post('/scam-patterns', body);

  Future<Map<String, dynamic>?> updatePattern(int id, Map<String, dynamic> body) =>
      _put('/scam-patterns/$id', body);

  Future<Map<String, dynamic>?> deactivatePattern(int id) =>
      _delete('/scam-patterns/$id');

  // ── Guardians ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getGuardians({
    int limit = 50,
    int offset = 0,
    String? search,
  }) => _get('/guardians', params: {
        'limit': limit,
        'offset': offset,
        if (search != null && search.isNotEmpty) 'search': search,
      });

  // ── Audit Log ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getAuditLog({
    int limit = 50,
    int offset = 0,
  }) => _get('/audit-log', params: {'limit': limit, 'offset': offset});

  // ── HTTP helpers ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> _get(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    try {
      final r = await _dio.get(path, queryParameters: params);
      return r.data as Map<String, dynamic>?;
    } on DioException catch (e) {
      _log('GET $path', e);
      return e.response?.data is Map<String, dynamic>
          ? e.response!.data as Map<String, dynamic>
          : {'error': true, 'message': e.message ?? 'Network error'};
    }
  }

  Future<Map<String, dynamic>?> _post(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      final r = await _dio.post(path, data: data);
      return r.data as Map<String, dynamic>?;
    } on DioException catch (e) {
      _log('POST $path', e);
      return e.response?.data is Map<String, dynamic>
          ? e.response!.data as Map<String, dynamic>
          : {'error': true, 'message': e.message ?? 'Network error'};
    }
  }

  Future<Map<String, dynamic>?> _put(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      final r = await _dio.put(path, data: data);
      return r.data as Map<String, dynamic>?;
    } on DioException catch (e) {
      _log('PUT $path', e);
      return e.response?.data is Map<String, dynamic>
          ? e.response!.data as Map<String, dynamic>
          : {'error': true, 'message': e.message ?? 'Network error'};
    }
  }

  Future<Map<String, dynamic>?> _patch(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      final r = await _dio.patch(path, data: data);
      return r.data as Map<String, dynamic>?;
    } on DioException catch (e) {
      _log('PATCH $path', e);
      return e.response?.data is Map<String, dynamic>
          ? e.response!.data as Map<String, dynamic>
          : {'error': true, 'message': e.message ?? 'Network error'};
    }
  }

  Future<Map<String, dynamic>?> _delete(String path) async {
    try {
      final r = await _dio.delete(path);
      return r.data as Map<String, dynamic>?;
    } on DioException catch (e) {
      _log('DELETE $path', e);
      return e.response?.data is Map<String, dynamic>
          ? e.response!.data as Map<String, dynamic>
          : {'error': true, 'message': e.message ?? 'Network error'};
    }
  }

  void _log(String label, DioException e) {
    if (kDebugMode) {
      debugPrint('[AdminApiClient] $label → ${e.response?.statusCode} ${e.message}');
    }
  }
}

/// Riverpod provider so screens can access the client with `ref.read(adminApiProvider)`.
final adminApiProvider = Provider<AdminApiClient>((ref) => AdminApiClient(ref));
