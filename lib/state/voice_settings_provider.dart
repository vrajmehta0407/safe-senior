// lib/state/voice_settings_provider.dart
// Riverpod provider for voice settings — now includes voice gender selection.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/voice_settings.dart';
import '../storage/local_preferences.dart';
import '../services/voice_service.dart';

class VoiceSettingsNotifier extends StateNotifier<VoiceSettings> {
  VoiceSettingsNotifier()
      : super(VoiceSettings(
          enabled: LocalPreferences.getVoiceEnabled(),
          speed: LocalPreferences.getVoiceSpeed(),
          voiceType: LocalPreferences.getVoiceType(),
        ));

  Future<void> setEnabled(bool val) async {
    await LocalPreferences.setVoiceEnabled(val);
    state = state.copyWith(enabled: val);
  }

  Future<void> setSpeed(double val) async {
    await LocalPreferences.setVoiceSpeed(val);
    state = state.copyWith(speed: val);
  }

  Future<void> setVoiceType(String type) async {
    await LocalPreferences.setVoiceType(type);
    state = state.copyWith(voiceType: type);
  }

  /// Sets voice gender ('female', 'male', 'neutral') and applies to TTS engine.
  Future<void> setVoiceGender(String gender) async {
    await VoiceService.setVoiceGender(gender);
    // voiceType is the display label; gender is the engine param
    state = state.copyWith(voiceType: _genderToLabel(gender));
  }

  static String _genderToLabel(String gender) {
    switch (gender.toLowerCase()) {
      case 'female':
        return 'Calm Female';
      case 'male':
        return 'Calm Male';
      default:
        return 'Neutral';
    }
  }

  Future<void> saveAll() async {
    await VoiceService.saveSettings(
      enabled: state.enabled,
      speed: state.speed,
      voiceType: state.voiceType,
      gender: LocalPreferences.getVoiceGender(),
    );
  }

  Future<void> testVoice() async {
    await VoiceService.testVoice();
  }
}

final voiceSettingsProvider =
    StateNotifierProvider<VoiceSettingsNotifier, VoiceSettings>(
  (ref) => VoiceSettingsNotifier(),
);

/// FutureProvider exposing the device's available TTS voices.
final availableVoicesProvider = FutureProvider<List<dynamic>>((ref) async {
  return VoiceService.getAvailableVoices();
});
