// lib/services/api_client.dart
// Dio-based backend API client with JWT auth interceptor and offline fallback.

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/local_preferences.dart';

/// Primary and fallback backend URLs.
/// 1. Public tunnel (localtunnel): https://safesenior-api.loca.lt/api
/// 2. Direct local Wi-Fi IP: http://192.168.31.53:3000/api
const String _kPublicBaseUrl = 'https://safesenior-api.loca.lt/api';
const String _kLocalBaseUrl = 'http://192.168.31.53:3000/api';
const String _kEmulatorBaseUrl = 'http://10.0.2.2:3000/api';

String get kBackendBaseUrl {
  final customUrl = LocalPreferences.getCustomBackendUrl();
  if (customUrl != null && customUrl.trim().isNotEmpty) {
    return customUrl.endsWith('/') ? '${customUrl}api' : '$customUrl/api';
  }
  if (!kIsWeb && Platform.isAndroid) {
    return _kLocalBaseUrl;
  }
  return _kLocalBaseUrl;
}

class ApiClient {
  static Dio _createDio([String? baseUrl]) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? kBackendBaseUrl,
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 8),
        // Accept ALL status codes — never let Dio throw based on HTTP status.
        // The app checks response.data['success'] / response.statusCode itself.
        validateStatus: (_) => true,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'bypass-tunnel-reminder': 'true',
        },
      ),
    );
    final token = LocalPreferences.getJwtToken();
    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
    return dio;
  }

  static Dio get _dio => _createDio();


  // ─── Auth ─────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> requestEmailOtp({
    required String email,
  }) async {
    return _post('/auth/email-otp/request', {
      'email': email,
    });
  }

  static Future<Map<String, dynamic>?> verifyEmailOtp({
    required String email,
    required String code,
  }) async {
    return _post('/auth/email-otp/verify', {
      'email': email,
      'code': code,
    });
  }

  static Future<Map<String, dynamic>?> requestPhoneOtp({
    required String phoneNumber,
    String? email,
  }) async {
    return _post('/auth/phone-otp/request', {
      'phone_number': phoneNumber,
      if (email != null) 'email': email,
    });
  }

  static Future<Map<String, dynamic>?> verifyPhoneOtp({
    required String phoneNumber,
    required String code,
  }) async {
    return _post('/auth/phone-otp/verify', {
      'phone_number': phoneNumber,
      'code': code,
    });
  }

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

  /// BUG 1 FIX: field was 'identifier' — backend reads 'phone_or_email'.
  static Future<Map<String, dynamic>?> login({
    required String phoneOrEmail,
    required String password,
  }) async {
    return _post('/auth/login', {
      'phone_or_email': phoneOrEmail,
      'password': password,
    });
  }

  /// Valid purpose values: 'login' | '2fa' | 'reset'
  /// OTP is sent to the user's registered email address.
  /// Pass [identifier] as email OR phone number — backend looks up either.
  static Future<Map<String, dynamic>?> requestOtp({
    String? identifier,       // email or phone — preferred
    String? phoneNumber,      // legacy fallback
    required String purpose,  // 'login' | '2fa' | 'reset'
  }) async {
    return _post('/auth/otp/request', {
      'identifier': identifier ?? phoneNumber,
      'purpose': purpose,
    });
  }

  static Future<Map<String, dynamic>?> verifyOtp({
    String? identifier,   // email or phone — preferred
    String? phoneNumber,  // legacy fallback
    required String code,
    required String purpose,
  }) async {
    return _post('/auth/otp/verify', {
      'identifier': identifier ?? phoneNumber,
      'code': code,
      'purpose': purpose,
    });
  }

  static Future<Map<String, dynamic>?> verify2fa({
    String? identifier,   // email or phone
    String? phoneNumber,  // legacy fallback
    required String code,
  }) async {
    return _post('/auth/2fa/verify', {
      'identifier': identifier ?? phoneNumber,
      'code': code,
    });
  }

  /// BUG 2 FIX: backend reads phone_number (not email); OTP-based reset.
  static Future<Map<String, dynamic>?> resetPassword({
    required String phoneNumber,
    required String otpCode,
    required String newPassword,
  }) async {
    return _post('/auth/reset-password', {
      'phone_number': phoneNumber,
      'otp_code': otpCode,
      'new_password': newPassword,
    });
  }

  /// Fetch current user profile — used to restore session after biometric auth.
  static Future<Map<String, dynamic>?> getMe() async {
    return _get('/auth/me');
  }

  // ─── Guardian (legacy single-guardian) ───────────────────────────────────────

  /// @deprecated — use addGuardianRemote() instead.
  /// BUG 4 FIX: path was '/guardians/sync' (plural) — backend mounts at
  /// '/guardian' (singular). Field was 'phone' — backend expects 'phone_number'.
  static Future<Map<String, dynamic>?> syncGuardian({
    required String name,
    required String phoneNumber,
    required String relationship,
  }) async {
    return _post('/guardian/sync', {
      'name': name,
      'phone_number': phoneNumber,
      'relationship': relationship,
    });
  }

  /// @deprecated — use listGuardians() instead.
  static Future<Map<String, dynamic>?> getGuardian() async {
    return _get('/guardian/sync');
  }

  // ─── Multi-Guardian ───────────────────────────────────────────────────────

  /// GET /guardians — list all guardians for the current user.
  /// Returns { success, guardians: [{ id, is_primary, name, phone_number, relationship }] }
  static Future<Map<String, dynamic>?> listGuardians() async {
    return _get('/guardians');
  }

  /// POST /guardians — add a guardian contact to the backend.
  /// Returns { success, link: { id, is_primary }, guardianId }
  static Future<Map<String, dynamic>?> addGuardianRemote({
    required String name,
    required String phoneNumber,
    String relationship = 'family',
    bool isPrimary = false,
  }) async {
    return _post('/guardians', {
      'name':         name,
      'phone_number': phoneNumber,
      'relationship': relationship,
      'is_primary':   isPrimary,
    });
  }

  /// DELETE /guardians/:id — remove a guardian link by user_guardians.id.
  static Future<Map<String, dynamic>?> deleteGuardianRemote(int linkId) async {
    return delete('/guardians/$linkId');
  }

  /// PATCH /guardians/:id/set-primary — promote a guardian to primary.
  static Future<Map<String, dynamic>?> setPrimaryGuardianRemote(int linkId) async {
    return patch('/guardians/$linkId/set-primary', {});
  }

  // ─── Scam Reports ─────────────────────────────────────────────────────────

  /// BUG 5 FIX: path was '/scam-reports' (doesn't exist) — real endpoint is
  /// '/scam-patterns/report'. Body shape now matches backend contract.
  /// [type] must be 'sms' or 'call'.
  /// [classification] must be 'safe', 'suspicious', or 'high-risk'.
  static Future<Map<String, dynamic>?> reportScam({
    required String type,           // 'sms' | 'call'
    required String sender,
    required String classification, // 'suspicious' | 'high-risk'
    String? bodyPreview,
  }) async {
    return _post('/scam-patterns/report', {
      'type': type,
      'sender': sender,
      'classification': classification,
      'body_preview': bodyPreview,   // null-safe: backend ignores null value
    });
  }

  static Future<Map<String, dynamic>?> getScamPatterns() async {
    return _get('/scam-patterns/latest');
  }

  // ─── Generic public helpers (for feature screens) ─────────────────────────

  /// Public GET — use for feature endpoints that don't warrant a named method.
  static Future<Map<String, dynamic>?> get(String path) => _get(path);

  /// Public POST — use for feature endpoints.
  static Future<Map<String, dynamic>?> post(
    String path,
    Map<String, dynamic> data,
  ) => _post(path, data);

  /// Public PATCH.
  static Future<Map<String, dynamic>?> patch(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.patch(path, data: data);
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      if (kDebugMode) print('[ApiClient] PATCH $path failed: ${e.response?.statusCode}');
      if (e.response?.data is Map<String, dynamic>) return e.response!.data as Map<String, dynamic>;
      return null;
    }
  }

  /// Public DELETE.
  static Future<Map<String, dynamic>?> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      if (kDebugMode) print('[ApiClient] DELETE $path failed: ${e.response?.statusCode}');
      if (e.response?.data is Map<String, dynamic>) return e.response!.data as Map<String, dynamic>;
      return null;
    }
  }

  // ─── HTTP Helpers (with automatic Local/Public URL Failover) ───────────────

  static Future<Map<String, dynamic>?> _post(
    String path,
    Map<String, dynamic> data,
  ) async {
    // 1. Try primary URL (Local Wi-Fi IP)
    try {
      final response = await _dio.post(path, data: data);
      // Return body for any status — caller checks success flag
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      // Non-JSON body (shouldn't happen with our API)
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return {'success': true};
      }
      // Server returned non-JSON error — fall through to tunnel
    } on DioException catch (e) {
      // Only fall through to tunnel on connection / timeout errors (not status errors)
      final isConnectionError = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout;
      if (!isConnectionError) {
        // Some other Dio error — return what we have
        if (e.response?.data is Map<String, dynamic>) {
          return e.response!.data as Map<String, dynamic>;
        }
        return {'success': false, 'message': e.message ?? 'Request failed'};
      }
      if (kDebugMode) {
        print('[ApiClient] Primary POST $path failed (${e.type}). Trying fallback public tunnel...');
      }
    } catch (_) {}

    // 2. Fallback to public tunnel URL (if phone is outside Wi-Fi on mobile data)
    try {
      final fallbackDio = _createDio(_kPublicBaseUrl);
      final response = await fallbackDio.post(path, data: data);
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('[ApiClient] Fallback POST $path failed: ${e.response?.statusCode} ${e.message}');
      }
      if (e.response?.data is Map<String, dynamic>) {
        return e.response!.data as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'No internet connection. Please check your network and try again.'};
    } catch (e) {
      return {'success': false, 'message': 'No internet connection. Please check your network and try again.'};
    }
    return {'success': false, 'message': 'Server unreachable. Please try again.'};
  }

  static Future<Map<String, dynamic>?> _get(String path) async {
    // 1. Try primary URL
    try {
      final response = await _dio.get(path);
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
    } on DioException catch (e) {
      final isConnectionError = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout;
      if (!isConnectionError) {
        if (e.response?.data is Map<String, dynamic>) {
          return e.response!.data as Map<String, dynamic>;
        }
      }
      if (kDebugMode) {
        print('[ApiClient] Primary GET $path failed (${e.type}). Trying fallback public tunnel...');
      }
    } catch (_) {}

    // 2. Fallback to public tunnel
    try {
      final fallbackDio = _createDio(_kPublicBaseUrl);
      final response = await fallbackDio.get(path);
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('[ApiClient] Fallback GET $path failed: ${e.response?.statusCode} ${e.message}');
      }
      if (e.response?.data is Map<String, dynamic>) {
        return e.response!.data as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }
}
