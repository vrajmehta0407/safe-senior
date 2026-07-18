// lib/storage/local_preferences.dart
// SharedPreferences wrapper for settings, session, language, voice settings.

import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class LocalPreferences {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    if (_prefs == null) throw StateError('LocalPreferences not initialized. Call init() first.');
    return _prefs!;
  }

  // ─── Session ───────────────────────────────────────────────────────────────
  static String? getCurrentUserEmail() => _instance.getString(AppConstants.keyCurrentUserEmail);

  static Future<void> setCurrentUserEmail(String email) =>
      _instance.setString(AppConstants.keyCurrentUserEmail, email);

  static Future<void> clearCurrentUserEmail() =>
      _instance.remove(AppConstants.keyCurrentUserEmail);

  static bool isLoggedIn() => getCurrentUserEmail() != null;

  static String? getJwtToken() => _instance.getString(AppConstants.keyJwtToken);

  static Future<void> setJwtToken(String token) =>
      _instance.setString(AppConstants.keyJwtToken, token);

  static Future<void> clearJwtToken() =>
      _instance.remove(AppConstants.keyJwtToken);

  // ─── Language ──────────────────────────────────────────────────────────────
  static String getLanguage() => _instance.getString(AppConstants.keyLanguage) ?? 'en';

  static Future<void> setLanguage(String code) =>
      _instance.setString(AppConstants.keyLanguage, code);

  // ─── Theme ─────────────────────────────────────────────────────────────────
  static String getThemeMode() => _instance.getString(AppConstants.keyThemeMode) ?? 'system';

  static Future<void> setThemeMode(String mode) =>
      _instance.setString(AppConstants.keyThemeMode, mode);

  // ─── Voice Settings ────────────────────────────────────────────────────────
  static bool getVoiceEnabled() => _instance.getBool(AppConstants.keyVoiceEnabled) ?? true;

  static Future<void> setVoiceEnabled(bool val) =>
      _instance.setBool(AppConstants.keyVoiceEnabled, val);

  static double getVoiceSpeed() => _instance.getDouble(AppConstants.keyVoiceSpeed) ?? 0.5;

  static Future<void> setVoiceSpeed(double val) =>
      _instance.setDouble(AppConstants.keyVoiceSpeed, val);

  static String getVoiceType() =>
      _instance.getString(AppConstants.keyVoiceType) ?? 'Calm Female';

  static Future<void> setVoiceType(String val) =>
      _instance.setString(AppConstants.keyVoiceType, val);

  static String getVoiceGender() => _instance.getString(AppConstants.keyVoiceGender) ?? 'neutral';

  static Future<void> setVoiceGender(String gender) =>
      _instance.setString(AppConstants.keyVoiceGender, gender);

  // ─── Premium ───────────────────────────────────────────────────────────────
  static bool getPremiumStatus() => _instance.getBool(AppConstants.keyPremiumStatus) ?? false;

  static Future<void> setPremiumStatus(bool val) =>
      _instance.setBool(AppConstants.keyPremiumStatus, val);

  static DateTime? getTrialStartDate() {
    final s = _instance.getString(AppConstants.keyTrialStartDate);
    if (s == null) return null;
    return DateTime.tryParse(s);
  }

  static Future<void> setTrialStartDate(DateTime dt) =>
      _instance.setString(AppConstants.keyTrialStartDate, dt.toIso8601String());

  static String? getSelectedPlanId() => _instance.getString(AppConstants.keySelectedPlanId);

  static Future<void> setSelectedPlanId(String planId) =>
      _instance.setString(AppConstants.keySelectedPlanId, planId);

  // ─── Utility ───────────────────────────────────────────────────────────────
  static Future<void> clearAll() => _instance.clear();
}
