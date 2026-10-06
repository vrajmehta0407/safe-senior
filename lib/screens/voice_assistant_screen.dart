import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../state/voice_settings_provider.dart';
import '../state/language_provider.dart';
import '../utils/app_translations.dart';
import '../services/voice_service.dart';
import '../widgets/app_bottom_nav_bar.dart';

class VoiceAssistantScreen extends ConsumerStatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  ConsumerState<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends ConsumerState<VoiceAssistantScreen> {
  bool _isPlayingTest = false;

  Future<void> _playVoiceTest() async {
    if (_isPlayingTest) return;
    setState(() => _isPlayingTest = true);
    try {
      final langCode = ref.read(languageProvider);
      final testMessage = langCode == 'hi'
          ? 'नमस्ते! सेफ सीनियर सुरक्षा अलर्ट चालू हैं।'
          : (langCode == 'gu'
              ? 'નમસ્તે! સેફ સિનિયર સુરક્ષા એલર્ટ્સ ચાલુ છે.'
              : 'SafeSenior Voice Alert: Suspicious caller detected. Do not share your OTP or bank details.');
      await VoiceService.speak(testMessage);
    } catch (_) {
      await VoiceService.testVoice();
    } finally {
      if (mounted) {
        setState(() => _isPlayingTest = false);
      }
    }
  }

  Future<void> _saveSettings() async {
    await ref.read(voiceSettingsProvider.notifier).saveAll();
    final langCode = ref.read(languageProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppTranslations.tr('Voice settings saved', langCode),
                  style: GoogleFonts.atkinsonHyperlegible(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF006565),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final voice = ref.watch(voiceSettingsProvider);
    final notifier = ref.read(voiceSettingsProvider.notifier);
    final langCode = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppTranslations.tr('Voice Alerts & Reading Pace', langCode),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 1. Master Enable Voice Guidance Card ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: voice.enabled ? AppTheme.primaryTeal : const Color(0xFFE3E2E2),
                    width: voice.enabled ? 1.8 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: voice.enabled
                          ? AppTheme.primaryTeal.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: voice.enabled
                                ? const Color(0xFFE0F2F2)
                                : const Color(0xFFEFEDED),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            voice.enabled ? Icons.volume_up : Icons.volume_off,
                            color: voice.enabled ? AppTheme.primaryTeal : AppTheme.textLight,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppTranslations.tr('Enable Voice Assistant', langCode),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: voice.enabled
                                          ? const Color(0xFF2E7D32)
                                          : Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    voice.enabled ? 'Voice Active ✓' : 'Voice Paused',
                                    style: GoogleFonts.atkinsonHyperlegible(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: voice.enabled
                                          ? const Color(0xFF2E7D32)
                                          : AppTheme.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Transform.scale(
                          scale: 1.1,
                          child: Switch(
                            value: voice.enabled,
                            onChanged: (val) {
                              notifier.setEnabled(val);
                              if (val) {
                                VoiceService.speak('Voice alerts enabled');
                              }
                            },
                            activeThumbColor: Colors.white,
                            activeTrackColor: AppTheme.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, color: AppTheme.primaryTeal, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'When enabled, SafeSenior reads aloud critical fraud warnings, OTP theft alerts, and scam calls so you never miss an urgent threat.',
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 13,
                                color: const Color(0xFF004D40),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── 2. Test Audio Voice Demo Card (Bulletproof Vertical Layout) ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE3E2E2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFE088),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              _isPlayingTest ? Icons.graphic_eq : Icons.campaign,
                              color: const Color(0xFF735C00),
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Audio Voice Sample',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Hear how urgent fraud warnings will sound',
                                style: GoogleFonts.atkinsonHyperlegible(
                                  fontSize: 13,
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _playVoiceTest,
                        icon: Icon(_isPlayingTest ? Icons.stop : Icons.play_arrow, size: 20),
                        label: Text(
                          _isPlayingTest ? 'Playing Sample Voice...' : 'Listen to Voice Sample ▶',
                          style: GoogleFonts.atkinsonHyperlegible(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── 3. Voice Speed & Reading Pace ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE3E2E2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppTranslations.tr('Voice Speed (Reading Pace)', langCode),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2F2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${(voice.speed * 100).toInt()}%',
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Adjust reading pace so every warning is easy to understand without rush.',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 13,
                        color: AppTheme.textLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppTheme.primaryTeal,
                        inactiveTrackColor: const Color(0xFFE0F2F2),
                        thumbColor: AppTheme.primaryTeal,
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                      ),
                      child: Slider(
                        value: voice.speed.clamp(0.5, 1.5),
                        min: 0.5,
                        max: 1.5,
                        divisions: 10,
                        onChanged: (val) => notifier.setSpeed(val),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              side: BorderSide(
                                color: (voice.speed < 0.9) ? AppTheme.primaryTeal : const Color(0xFFE3E2E2),
                                width: (voice.speed < 0.9) ? 2 : 1,
                              ),
                              backgroundColor: (voice.speed < 0.9) ? const Color(0xFFE0F2F2) : Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => notifier.setSpeed(0.8),
                            child: Text(
                              '🐢 Slower',
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryTeal,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              side: BorderSide(
                                color: (voice.speed >= 0.9 && voice.speed <= 1.1) ? AppTheme.primaryTeal : const Color(0xFFE3E2E2),
                                width: (voice.speed >= 0.9 && voice.speed <= 1.1) ? 2 : 1,
                              ),
                              backgroundColor: (voice.speed >= 0.9 && voice.speed <= 1.1) ? const Color(0xFFE0F2F2) : Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => notifier.setSpeed(1.0),
                            child: Text(
                              'Normal 1.0x',
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryTeal,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              side: BorderSide(
                                color: (voice.speed > 1.1) ? AppTheme.primaryTeal : const Color(0xFFE3E2E2),
                                width: (voice.speed > 1.1) ? 2 : 1,
                              ),
                              backgroundColor: (voice.speed > 1.1) ? const Color(0xFFE0F2F2) : Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => notifier.setSpeed(1.2),
                            child: Text(
                              'Faster ⚡',
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryTeal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── 4. Voice Type Selection ──
              Text(
                AppTranslations.tr('Voice Type', langCode),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 10),

              _buildVoiceOption(
                title: 'Calm Female Voice',
                subtitle: 'Gentle, clear tone optimized for senior comprehension',
                gender: 'female',
                currentVoiceType: voice.voiceType,
                notifier: notifier,
              ),
              const SizedBox(height: 10),
              _buildVoiceOption(
                title: 'Friendly Male Voice',
                subtitle: 'Warm, steady baritone for crisp alert announcements',
                gender: 'male',
                currentVoiceType: voice.voiceType,
                notifier: notifier,
              ),

              const SizedBox(height: 24),

              // ── 5. Save Voice Settings Action Button ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _saveSettings,
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  label: Text(
                    AppTranslations.tr('Save Voice Settings', langCode),
                    style: GoogleFonts.atkinsonHyperlegible(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildVoiceOption({
    required String title,
    required String subtitle,
    required String gender,
    required String currentVoiceType,
    required VoiceSettingsNotifier notifier,
  }) {
    final bool isSelected = currentVoiceType.toLowerCase().contains(gender);

    return GestureDetector(
      onTap: () {
        notifier.setVoiceGender(gender);
        VoiceService.speak('$title selected');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppTheme.primaryTeal : const Color(0xFFE3E2E2),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppTheme.primaryTeal : AppTheme.textLight,
              size: 24,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.atkinsonHyperlegible(
                      fontSize: 12.5,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.play_circle_fill, color: AppTheme.primaryTeal, size: 28),
              onPressed: () {
                notifier.setVoiceGender(gender);
                VoiceService.speak('$title sample');
              },
            ),
          ],
        ),
      ),
    );
  }
}
