import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../state/voice_settings_provider.dart';
import '../services/voice_service.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import '../widgets/app_bottom_nav_bar.dart';

class VoiceAssistantScreen extends ConsumerStatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  ConsumerState<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends ConsumerState<VoiceAssistantScreen> {
  int _selectedIndex = 3;

  // BUG 6 FIX: real STT state
  bool _isListening = false;
  String _lastTranscript = '';
  String _statusMessage = 'Tap the mic to speak';

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  void dispose() {
    // Stop listening when navigating away
    if (_isListening) VoiceService.stopListening();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await VoiceService.stopListening();
      if (mounted) setState(() { _isListening = false; _statusMessage = 'Tap the mic to speak'; });
      return;
    }

    if (!VoiceService.canListen) {
      setState(() => _statusMessage = 'Voice listening not available on this device.');
      await VoiceService.speak('Voice listening is not available on this device.');
      return;
    }

    setState(() { _isListening = true; _statusMessage = 'Listening… Speak now'; _lastTranscript = ''; });
    await VoiceService.startListening(
      onResult: (text) {
        if (mounted) setState(() => _lastTranscript = text);
      },
      onDone: () {
        if (mounted) setState(() { _isListening = false; _statusMessage = 'Tap the mic to speak'; });
      },
    );
  }

  Future<void> _saveSettings() async {
    await ref.read(voiceSettingsProvider.notifier).saveAll();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final voice = ref.watch(voiceSettingsProvider);
    final notifier = ref.read(voiceSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Voice Assistant',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: AppTheme.textDark),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Box
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLightBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryLightBlue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLightBlue.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_outlined, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How this keeps you safe',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your assistant will read out loud important security alerts if we detect a suspicious caller or a scam message. It helps you catch risks instantly without needing to look at your screen.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textDark.withValues(alpha: 0.8),
                                  height: 1.5,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Live Mic Section (BUG 6 FIX) ─────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isListening ? AppTheme.primaryDarkBlue : Colors.grey.withValues(alpha: 0.3),
                    width: _isListening ? 2 : 1,
                  ),
                  boxShadow: _isListening ? [
                    BoxShadow(color: AppTheme.primaryDarkBlue.withValues(alpha: 0.15), blurRadius: 16, spreadRadius: 2),
                  ] : [],
                ),
                child: Column(
                  children: [
                    // Mic button
                    GestureDetector(
                      onTap: _toggleListening,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _isListening ? AppTheme.primaryDarkBlue : AppTheme.primaryLightBlue.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isListening ? AppTheme.primaryDarkBlue : AppTheme.primaryLightBlue,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: _isListening ? Colors.white : AppTheme.primaryDarkBlue,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        color: _isListening ? AppTheme.primaryDarkBlue : AppTheme.textDark,
                        fontWeight: _isListening ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                    if (_lastTranscript.isNotEmpty) ...[  
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLightBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '“$_lastTranscript”',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 15,
                            color: AppTheme.textDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Enable Voice Alerts — wired to voiceSettingsProvider
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enable Voice Alerts',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Speak critical security warnings',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textDark),
                          ),
                        ],
                      ),
                    ),
                    // Wired to provider
                    Switch(
                      value: voice.enabled,
                      onChanged: (val) => notifier.setEnabled(val),
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xFF1964B0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Voice Type — wired
              Text(
                'Voice Type',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildVoiceTypeOption(context, 'Calm Female', 'Soothing and clear', voice.voiceType, notifier, 'female'),
              const SizedBox(height: 12),
              _buildVoiceTypeOption(context, 'Friendly Male', 'Warm and helpful', voice.voiceType, notifier, 'male'),
              
              const SizedBox(height: 24),

              // Voice Speed — wired
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voice Speed (Reading Pace)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppTheme.primaryDarkBlue,
                        inactiveTrackColor: AppTheme.primaryLightBlue.withValues(alpha: 0.3),
                        thumbColor: AppTheme.primaryDarkBlue,
                        trackHeight: 8,
                      ),
                      child: Slider(
                        value: voice.speed,
                        onChanged: (val) => notifier.setSpeed(val),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.waves, size: 16, color: AppTheme.primaryDarkBlue),
                            const SizedBox(width: 4),
                            Text('Slower', style: TextStyle(color: AppTheme.primaryDarkBlue, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Faster', style: TextStyle(color: AppTheme.primaryDarkBlue, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            Icon(Icons.fast_forward, size: 16, color: AppTheme.primaryDarkBlue),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              
              // Save Button — calls saveAll() then pops
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1964B0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline),
                      SizedBox(width: 8),
                      Text('Save Voice Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
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

  Widget _buildVoiceTypeOption(BuildContext context, String title, String subtitle, String currentVoiceType, VoiceSettingsNotifier notifier, String gender) {
    final bool isSelected = currentVoiceType == title;
    return GestureDetector(
      onTap: () {
        notifier.setVoiceType(title);
        notifier.setVoiceGender(gender); // apply to TTS engine
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryDarkBlue : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppTheme.primaryDarkBlue : Colors.grey,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textDark),
                  ),
                ],
              ),
            ),
            // Play button — tests TTS with the current settings
            GestureDetector(
              onTap: () => VoiceService.testVoice(),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLightBlue.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow, color: AppTheme.primaryDarkBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
