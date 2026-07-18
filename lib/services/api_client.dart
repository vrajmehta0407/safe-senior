// lib/services/api_client.dart
// Dio-based backend API client with JWT auth interceptor and offline fallback.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/local_preferences.dart';

/// Base URL for the Safe Senior backend.
/// Update this to your Railway deployment URL before release.
const String kBackendBaseUrl = 'https://safe-senior-api.up.railway.app/api';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: kBackendBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  static bool _interceptorAdded = false;

  static void _ensureInterceptor() {
    if (_interceptorAdded) return;
    _interceptorAdded = true;
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = LocalPreferences.getJwtToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (e, handler) {
          if (kDebugMode) {
            print('[ApiClient] Error: ${e.response?.statusCode} ${e.message}');
          }
          handler.next(e);
        },
      ),
    );
  }

  // ─── Auth ─────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> signup({
    required String name,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    return _post('/auth/signup', {
      'name': name,
      'phone_number': phoneNumber,
      'email': email,
      'password': password,
    });
  }

  static Future<Map<String, dynamic>?> login({
    required String identifier, // email or phone
    required String password,
  }) async {
    return _post('/auth/login', {
      'identifier': identifier,
      'password': password,
    });
  }

  static Future<Map<String, dynamic>?> requestOtp({
    required String phoneNumber,
    required String purpose, // 'login' | 'signup' | 'reset'
  }) async {
    return _post('/auth/otp/request', {
      'phone_number': phoneNumber,
      'purpose': purpose,
    });
  }

  static Future<Map<String, dynamic>?> verifyOtp({
    required String phoneNumber,
    required String code,
    required String purpose,
  }) async {
    return _post('/auth/otp/verify', {
      'phone_number': phoneNumber,
      'code': code,
      'purpose': purpose,
    });
  }

  static Future<Map<String, dynamic>?> verify2fa({
    required String userId,
    required String code,
  }) async {
    return _post('/auth/2fa/verify', {
      'user_id': userId,
      'code': code,
    });
  }

  static Future<Map<String, dynamic>?> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    return _post('/auth/reset-password', {
      'email': email,
      'otp_code': otpCode,
      'new_password': newPassword,
    });
  }

  // ─── Guardian ─────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> syncGuardian({
    required String name,
    required String phone,
    required String relationship,
  }) async {
    return _post('/guardians/sync', {
      'name': name,
      'phone': phone,
      'relationship': relationship,
    });
  }

  // ─── Scam Reports ─────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> reportScam({
    required String sender,
    required String body,
    required String riskLevel,
    required List<String> reasons,
  }) async {
    return _post('/scam-reports', {
      'sender': sender,
      'body': body,
      'risk_level': riskLevel,
      'reasons': reasons,
    });
  }

  static Future<Map<String, dynamic>?> getScamPatterns() async {
    return _get('/scam-patterns/latest');
  }

  // ─── HTTP Helpers ─────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> _post(
    String path,
    Map<String, dynamic> data,
  ) async {
    _ensureInterceptor();
    try {
      final response = await _dio.post(path, data: data);
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('[ApiClient] POST $path failed: ${e.response?.statusCode} ${e.message}');
      }
      // Return error map so callers can inspect the message
      if (e.response?.data is Map<String, dynamic>) {
        return e.response!.data as Map<String, dynamic>;
      }
      return {'error': true, 'message': e.message ?? 'Network error'};
    }
  }

  static Future<Map<String, dynamic>?> _get(String path) async {
    _ensureInterceptor();
    try {
      final response = await _dio.get(path);
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('[ApiClient] GET $path failed: ${e.response?.statusCode} ${e.message}');
      }
      return null;
    }
  }
}
