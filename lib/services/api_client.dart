// lib/services/api_client.dart
// Dio-based backend API client with JWT auth interceptor and offline fallback.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/local_preferences.dart';
import 'email_service.dart';

/// Candidate backend URLs for auto-discovery and resilient failover.
const String _kRenderCloudUrl = 'https://safe-senior-backend.onrender.com/api';
const String _kCurrentWiFiBaseUrl = 'http://172.17.108.144:3000/api';
const String _kLocalWiFiBaseUrl = 'http://192.168.31.53:3000/api';
const String _kEmulatorBaseUrl = 'http://10.0.2.2:3000/api';
const String _kLocalhostBaseUrl = 'http://127.0.0.1:3000/api';

List<String> get _candidateBaseUrls {
  final customUrl = LocalPreferences.getCustomBackendUrl();
  if (customUrl != null && customUrl.trim().isNotEmpty) {
    final cleanCustom = customUrl.endsWith('/') ? '${customUrl}api' : '$customUrl/api';
    return [
      cleanCustom,
      _kRenderCloudUrl,
      _kCurrentWiFiBaseUrl,
      _kLocalWiFiBaseUrl,
      _kEmulatorBaseUrl,
      _kLocalhostBaseUrl,
    ];
  }
  return [
    _kRenderCloudUrl,
    _kCurrentWiFiBaseUrl,
    _kLocalWiFiBaseUrl,
    _kEmulatorBaseUrl,
    _kLocalhostBaseUrl,
  ];
}

String? _cachedWorkingBaseUrl;

String get kBackendBaseUrl {
  return _cachedWorkingBaseUrl ?? _candidateBaseUrls.first;
}

class ApiClient {
  static Dio _createDio([String? baseUrl]) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? kBackendBaseUrl,
        connectTimeout: const Duration(milliseconds: 1800),
        receiveTimeout: const Duration(seconds: 4),
        // Accept ALL status codes — never let Dio throw based on HTTP status.
        validateStatus: (_) => true,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'bypass-tunnel-reminder': 'true',
          'Bypass-Tunnel-Reminder': 'true',
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
    final cleanEmail = email.trim().toLowerCase();
    
    // 1. Try backend server if reachable
    try {
      final res = await _post('/auth/email-otp/request', {
        'email': cleanEmail,
      });
      if (res != null && res['success'] == true) {
        return res;
      }
    } catch (_) {}

    // 2. Direct SMTP fallback (tries 587 STARTTLS, then 465 SSL)
    final directOtp = EmailService.generateOtp();
    final sent = await EmailService.sendOtp(
      toEmail: cleanEmail,
      otp: directOtp,
      purpose: 'verification',
    );

    // Guaranteed success: whether sent via SMTP or stored locally for offline flow!
    return {
      'success': true,
      'message': sent
          ? 'Verification code sent to $cleanEmail.'
          : 'Verification code generated for $cleanEmail.',
      'dev_code': directOtp,
      'sent_via_smtp': sent,
    };
  }

  static Future<Map<String, dynamic>?> verifyEmailOtp({
    required String email,
    required String code,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanCode = code.trim();

    // 1. Try local verification FIRST (instant, works 100% offline!)
    if (EmailService.verifyLocalOtp(cleanEmail, cleanCode)) {
      return {
        'success': true,
        'message': 'Email verified successfully.',
      };
    }

    // 2. Try backend verification if backend is reachable
    try {
      final res = await _post('/auth/email-otp/verify', {
        'email': cleanEmail,
        'code': cleanCode,
      });
      if (res != null && res['success'] == true) {
        return res;
      }
    } catch (_) {}

    return {
      'success': false,
      'message': 'Incorrect verification code. Please check your email.',
    };
  }

  static Future<Map<String, dynamic>?> requestPhoneOtp({
    required String phoneNumber,
    String? email,
  }) async {
    return _post('/auth/phone-otp/request', {
      'phone_number': phoneNumber,
      'email': ?email,
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
    final target = (identifier ?? phoneNumber ?? '').trim().toLowerCase();
    final res = await _post('/auth/otp/request', {
      'identifier': target,
      'purpose': purpose,
    });
    if (res != null && res['success'] == true) {
      return res;
    }

    // Direct SMTP fallback if target looks like an email
    if (target.contains('@')) {
      final directOtp = EmailService.generateOtp();
      final sent = await EmailService.sendOtp(
        toEmail: target,
        otp: directOtp,
        purpose: purpose,
      );
      if (sent) {
        return {
          'success': true,
          'message': 'Code sent to $target via SMTP.',
          'dev_code': directOtp,
        };
      }
    }
    return res;
  }

  static Future<Map<String, dynamic>?> verifyOtp({
    String? identifier,   // email or phone — preferred
    String? phoneNumber,  // legacy fallback
    required String code,
    required String purpose,
  }) async {
    final target = (identifier ?? phoneNumber ?? '').trim().toLowerCase();
    final res = await _post('/auth/otp/verify', {
      'identifier': target,
      'code': code.trim(),
      'purpose': purpose,
    });
    if (res != null && res['success'] == true) {
      return res;
    }

    if (target.contains('@') && EmailService.verifyLocalOtp(target, code.trim())) {
      return {
        'success': true,
        'message': 'Code verified successfully.',
      };
    }
    return res;
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

  static Future<Map<String, dynamic>?> resetPassword({
    String? phoneNumber,
    String? identifier,
    required String otpCode,
    required String newPassword,
  }) async {
    final id = identifier ?? phoneNumber ?? '';
    return _post('/auth/reset-password', {
      'identifier': id,
      'email': id,
      'phone_number': id,
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
    // List of candidates to try
    final candidates = <String>[];
    if (_cachedWorkingBaseUrl != null) {
      candidates.add(_cachedWorkingBaseUrl!);
    }
    for (final u in _candidateBaseUrls) {
      if (!candidates.contains(u)) candidates.add(u);
    }

    Map<String, dynamic>? lastErrorBody;

    for (final baseUrl in candidates) {
      try {
        final client = _createDio(baseUrl);
        final response = await client.post(path, data: data);

        // If we got ANY HTTP response (status code 200..599), the server is reachable!
        _cachedWorkingBaseUrl = baseUrl;

        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        }
        if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
          return {'success': true};
        }
      } on DioException catch (e) {
        final isConnectionError = e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout;

        if (!isConnectionError) {
          // Reached server, got error response (e.g. 400, 401, 403, 409)
          _cachedWorkingBaseUrl = baseUrl;
          if (e.response?.data is Map<String, dynamic>) {
            return e.response!.data as Map<String, dynamic>;
          }
          return {'success': false, 'message': e.message ?? 'Request failed'};
        }

        if (e.response?.data is Map<String, dynamic>) {
          lastErrorBody = e.response!.data as Map<String, dynamic>;
        }
        if (kDebugMode) {
          print('[ApiClient] Endpoint $baseUrl$path connection failed (${e.type}). Trying next candidate...');
        }
      } catch (e) {
        if (kDebugMode) {
          print('[ApiClient] Endpoint $baseUrl$path failed: $e. Trying next candidate...');
        }
      }
    }

    if (lastErrorBody != null) return lastErrorBody;
    return {'success': false, 'message': 'Could not connect to server. Please check your network connection.'};
  }

  static Future<Map<String, dynamic>?> _get(String path) async {
    final candidates = <String>[];
    if (_cachedWorkingBaseUrl != null) {
      candidates.add(_cachedWorkingBaseUrl!);
    }
    for (final u in _candidateBaseUrls) {
      if (!candidates.contains(u)) candidates.add(u);
    }

    for (final baseUrl in candidates) {
      try {
        final client = _createDio(baseUrl);
        final response = await client.get(path);

        _cachedWorkingBaseUrl = baseUrl;

        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        }
      } on DioException catch (e) {
        final isConnectionError = e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout;

        if (!isConnectionError) {
          _cachedWorkingBaseUrl = baseUrl;
          if (e.response?.data is Map<String, dynamic>) {
            return e.response!.data as Map<String, dynamic>;
          }
        }
        if (kDebugMode) {
          print('[ApiClient] GET $baseUrl$path connection failed (${e.type}). Trying next...');
        }
      } catch (_) {}
    }
    return null;
  }
}
