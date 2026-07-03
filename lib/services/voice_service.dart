// lib/services/voice_service.dart
// flutter_tts wrapper for voice alerts.

import 'package:flutter_tts/flutter_tts.dart';
import '../services/platform_capabilities.dart';
import '../storage/local_preferences.dart';

class VoiceService {
  static final FlutterTts _tts = FlutterTts();
  static bool _initialized = false;

  static Future<void> init() async {
    if (!PlatformCapabilities.hasTts) return;
    await _tts.setLanguage('en-US');
    await _tts.setPitch(1.0);
    _initialized = true;
    _applyStoredSettings();
  }

  static Future<void> _applyStoredSettings() async {
    final speed = LocalPreferences.getVoiceSpeed();
    final ttsRate = 0.25 + (speed * 0.75);
    await _tts.setSpeechRate(ttsRate);
  }

  /// Speaks the given text if voice alerts are enabled.
  static Future<void> speak(String text) async {
    if (!PlatformCapabilities.hasTts) return;
    if (!_initialized) await init();
    if (!LocalPreferences.getVoiceEnabled()) return;
    await _tts.stop();
    await _applyStoredSettings();
    await _tts.speak(text);
  }

  /// Speaks a scam alert — used by warning_screen.dart on entry.
  static Future<void> speakScamAlert(String sender) async {
    await speak(
      'Warning! Suspicious message detected from $sender. '
      'Do not share any codes or personal information. '
      'This may be a scam.',
    );
  }

  /// Speaks a safety tip.
  static Future<void> speakTip(String tip) async {
    await speak('Safety tip: $tip');
  }

  /// Stops any ongoing speech.
  static Future<void> stop() async {
    if (!PlatformCapabilities.hasTts) return;
    await _tts.stop();
  }

  /// Updates speech rate from slider value (0.0–1.0).
  static Future<void> setSpeedFromSlider(double sliderValue) async {
    if (!PlatformCapabilities.hasTts) return;
    final rate = 0.25 + (sliderValue * 0.75);
    await _tts.setSpeechRate(rate);
    await LocalPreferences.setVoiceSpeed(sliderValue);
  }

  /// Saves all voice settings to preferences.
  static Future<void> saveSettings({
    required bool enabled,
    required double speed,
    required String voiceType,
  }) async {
    await LocalPreferences.setVoiceEnabled(enabled);
    await LocalPreferences.setVoiceSpeed(speed);
    await LocalPreferences.setVoiceType(voiceType);
    await setSpeedFromSlider(speed);
  }

  /// Test voice with current settings.
  static Future<void> testVoice() async {
    await speak('Hello! Your voice alerts are working correctly.');
  }
}
