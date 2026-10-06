// lib/storage/local_preferences.dart
import 'package:shared_preferences/shared_preferences.dart';

class LocalPreferences {
  static late SharedPreferences _instance;

  static Future<void> init() async {
    _instance = await SharedPreferences.getInstance();
  }

  // ─── First Launch ──────────────────────────────────────────────────────────
  static bool isFirstLaunch() => _instance.getBool('first_launch') ?? true;
  static Future<void> setFirstLaunchComplete() => _instance.setBool('first_launch', false);

  // ─── Remember Me & User Session ───────────────────────────────────────────
  static bool getRememberMe() => _instance.getBool('remember_me') ?? false;
  static Future<void> setRememberMe(bool val) => _instance.setBool('remember_me', val);

  static String? getRememberedEmail() => _instance.getString('remembered_email');
  static Future<void> setRememberedEmail(String email) => _instance.setString('remembered_email', email);

  static String? getCurrentUserEmail() => _instance.getString('current_user_email');
  static Future<void> setCurrentUserEmail(String email) => _instance.setString('current_user_email', email);
  static Future<void> clearCurrentUserEmail() => _instance.remove('current_user_email');

  static String? getJwtToken() => _instance.getString('jwt_token');
  static Future<void> setJwtToken(String token) => _instance.setString('jwt_token', token);
  static Future<void> clearJwtToken() => _instance.remove('jwt_token');

  static bool isLoggedIn() => getCurrentUserEmail() != null;

  // ─── Voice / Speech Preferences ───────────────────────────────────────────
  static double getSpeechRate() => _instance.getDouble('speech_rate') ?? 1.0;
  static Future<void> setSpeechRate(double rate) => _instance.setDouble('speech_rate', rate);

  static double getVoiceSpeed() => _instance.getDouble('voice_speed') ?? 1.0;
  static Future<void> setVoiceSpeed(double speed) => _instance.setDouble('voice_speed', speed);

  static bool getVoiceEnabled() => _instance.getBool('voice_enabled') ?? true;
  static Future<void> setVoiceEnabled(bool val) => _instance.setBool('voice_enabled', val);

  static String getVoiceGender() => _instance.getString('voice_gender') ?? 'neutral';
  static Future<void> setVoiceGender(String gender) => _instance.setString('voice_gender', gender);
  static String getVoiceType() => _instance.getString('voice_type') ?? 'Neutral';
  static Future<void> setVoiceType(String type) => _instance.setString('voice_type', type);

  // ─── Theme & Language ─────────────────────────────────────────────────────
  static String getThemeMode() => _instance.getString('theme_mode') ?? 'system';
  static Future<void> setThemeMode(String mode) => _instance.setString('theme_mode', mode);

  static String getLanguage() => _instance.getString('language') ?? 'en';
  static Future<void> setLanguage(String lang) => _instance.setString('language', lang);

  // ─── Premium (Always Active) ──────────────────────────────────────────────
  static bool getPremiumStatus() => true;
  static Future<void> setPremiumStatus(bool val) async {}
  static DateTime? getTrialStartDate() => null;
  static Future<void> setTrialStartDate(DateTime dt) async {}
  static String? getSelectedPlanId() => 'full_free';
  static Future<void> setSelectedPlanId(String planId) async {}

  // ─── Custom API Endpoint Configuration ───────────────────────────────────────
  static String? getCustomBackendUrl() => _instance.getString('custom_backend_url');
  static Future<void> setCustomBackendUrl(String url) => _instance.setString('custom_backend_url', url);

  // ─── Sensor Calibration Preferences ──────────────────────────────────────────
  static double getFallSensitivity() => _instance.getDouble('fall_sensitivity') ?? 2.5;
  static Future<void> setFallSensitivity(double val) => _instance.setDouble('fall_sensitivity', val);

  // ─── Location & Geofence Preferences (Ahmedabad Default) ──────────────────────
  static String getHomeLocationAddress() {
    final addr = _instance.getString('home_location_address');
    if (addr == null || addr.contains('Delhi')) return 'Navrangpura, Ahmedabad';
    return addr;
  }
  static Future<void> setHomeLocationAddress(String val) => _instance.setString('home_location_address', val);

  static double getHomeLat() {
    final lat = _instance.getDouble('home_lat');
    if (lat == null || (lat > 28.0 && lat < 29.0)) return 23.0365;
    return lat;
  }
  static Future<void> setHomeLat(double val) => _instance.setDouble('home_lat', val);

  static double getHomeLng() {
    final lng = _instance.getDouble('home_lng');
    if (lng == null || (lng > 76.5 && lng < 77.8)) return 72.5611;
    return lng;
  }
  static Future<void> setHomeLng(double val) => _instance.setDouble('home_lng', val);

  static String getLastKnownLocationAddress() {
    final addr = _instance.getString('last_known_location_address');
    if (addr == null || addr.contains('Delhi')) return 'SG Highway, Ahmedabad';
    return addr;
  }
  static Future<void> setLastKnownLocationAddress(String val) => _instance.setString('last_known_location_address', val);

  static double getLastKnownLat() {
    final lat = _instance.getDouble('last_known_lat');
    if (lat == null || (lat > 28.0 && lat < 29.0)) return 23.0525;
    return lat;
  }
  static Future<void> setLastKnownLat(double val) => _instance.setDouble('last_known_lat', val);

  static double getLastKnownLng() {
    final lng = _instance.getDouble('last_known_lng');
    if (lng == null || (lng > 76.5 && lng < 77.8)) return 72.5120;
    return lng;
  }
  static Future<void> setLastKnownLng(double val) => _instance.setDouble('last_known_lng', val);

  static String? getLastLocationAlertTime() => _instance.getString('last_location_alert_time');
  static Future<void> setLastLocationAlertTime(String val) => _instance.setString('last_location_alert_time', val);

  // ─── Utility ───────────────────────────────────────────────────────────────
  static Future<void> clearAll() => _instance.clear();
}
