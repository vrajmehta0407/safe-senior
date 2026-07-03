// lib/models/voice_settings.dart

class VoiceSettings {
  final bool enabled;
  final double speed; // 0.0 to 1.0, maps to TTS rate 0.25–1.0
  final String voiceType; // 'Calm Female' | 'Friendly Male'

  const VoiceSettings({
    this.enabled = true,
    this.speed = 0.5,
    this.voiceType = 'Calm Female',
  });

  VoiceSettings copyWith({bool? enabled, double? speed, String? voiceType}) {
    return VoiceSettings(
      enabled: enabled ?? this.enabled,
      speed: speed ?? this.speed,
      voiceType: voiceType ?? this.voiceType,
    );
  }

  /// Map 0–1 slider to TTS speech rate (0.25 = slow, 1.0 = fast).
  double get ttsRate => 0.25 + (speed * 0.75);
}
