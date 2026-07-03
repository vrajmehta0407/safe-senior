// lib/state/voice_settings_provider.dart
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

  Future<void> saveAll() async {
    await VoiceService.saveSettings(
      enabled: state.enabled,
      speed: state.speed,
      voiceType: state.voiceType,
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
