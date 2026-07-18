// lib/services/voice_service.dart
// flutter_tts wrapper for voice alerts — now with gender selection and available voices.

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/platform_capabilities.dart';
import '../storage/local_preferences.dart';

class VoiceService {
  static final FlutterTts _tts = FlutterTts();
  static bool _initialized = false;
  static List<dynamic> _availableVoices = [];

  static Future<void> init() async {
    if (!PlatformCapabilities.hasTts) return;
    await _tts.setLanguage('en-US');
    await _tts.setPitch(1.0);
    _initialized = true;

    // Cache available voices
    try {
      _availableVoices = await _tts.getVoices ?? [];
    } catch (_) {
      _availableVoices = [];
    }

    await _applyStoredSettings();
  }

  static Future<void> _applyStoredSettings() async {
    final speed = LocalPreferences.getVoiceSpeed();
    final ttsRate = 0.25 + (speed * 0.75);
    await _tts.setSpeechRate(ttsRate);

    // Apply stored gender preference
    final gender = LocalPreferences.getVoiceGender();
    await _applyGender(gender);
  }

  // ─── Voice Gender ─────────────────────────────────────────────────────────

  /// Returns the list of all available TTS voices on this device.
  static Future<List<dynamic>> getAvailableVoices() async {
    if (!_initialized) await init();
    if (_availableVoices.isNotEmpty) return _availableVoices;
    try {
      _availableVoices = await _tts.getVoices ?? [];
    } catch (_) {}
    return _availableVoices;
  }

  /// Sets TTS voice by gender preference ('female', 'male', 'neutral').
  /// Scans device voice list for a match; falls back gracefully.
  static Future<void> setVoiceGender(String gender) async {
    if (!PlatformCapabilities.hasTts) return;
    if (!_initialized) await init();
    await LocalPreferences.setVoiceGender(gender);
    await _applyGender(gender);
  }

  static Future<void> _applyGender(String gender) async {
    try {
      final voices = _availableVoices;
      if (voices.isEmpty) return;

      // Search voice list for gender match
      final lowerGender = gender.toLowerCase();
      Map<String, String>? matchedVoice;

      for (final v in voices) {
        if (v is Map) {
          final name = (v['name'] ?? '').toString().toLowerCase();
          final locale = (v['locale'] ?? '').toString().toLowerCase();

          bool isEnglish = locale.startsWith('en');
          bool genderMatch = false;

          if (lowerGender == 'female') {
            genderMatch = name.contains('female') ||
                name.contains('woman') ||
                name.contains('girl') ||
                // Common female voice names across platforms
                name.contains('samantha') ||
                name.contains('victoria') ||
                name.contains('karen') ||
                name.contains('moira') ||
                name.contains('tessa');
          } else if (lowerGender == 'male') {
            genderMatch = name.contains('male') ||
                name.contains('man') ||
                name.contains('daniel') ||
                name.contains('alex') ||
                name.contains('fred') ||
                name.contains('tom') ||
                name.contains('gordon') ||
                name.contains('lee');
          }

          if (isEnglish && genderMatch) {
            matchedVoice = {
              'name': v['name'].toString(),
              'locale': v['locale'].toString(),
            };
            break;
          }
        }
      }

      if (matchedVoice != null) {
        await _tts.setVoice(matchedVoice);
        if (kDebugMode) print('[VoiceService] Voice set to: ${matchedVoice['name']}');
      }
    } catch (e) {
      if (kDebugMode) print('[VoiceService] setVoiceGender error: $e');
    }
  }

  // ─── Speak ────────────────────────────────────────────────────────────────

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

  /// Saves all voice settings to preferences and applies them.
  static Future<void> saveSettings({
    required bool enabled,
    required double speed,
    required String voiceType,
    String? gender,
  }) async {
    await LocalPreferences.setVoiceEnabled(enabled);
    await LocalPreferences.setVoiceSpeed(speed);
    await LocalPreferences.setVoiceType(voiceType);
    if (gender != null) await LocalPreferences.setVoiceGender(gender);
    await setSpeedFromSlider(speed);
    if (gender != null) await _applyGender(gender);
  }

  /// Test voice with current settings.
  static Future<void> testVoice() async {
    await speak('Hello! Your voice alerts are working correctly.');
  }

  /// Start listening (stub — speech-to-text requires speech_to_text plugin,
  /// not in this pass scope, but the button is wired to this no-op).
  static Future<void> startListening() async {
    if (kDebugMode) print('[VoiceService] startListening — speech_to_text not wired yet.');
    // TODO(next-pass): Add speech_to_text plugin for mic input.
    await speak('Listening is not available yet. Please type your question.');
  }
}
