import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../state/auth_provider.dart';
import '../state/guardian_provider.dart';
import '../state/language_provider.dart';
import '../services/openrouter_service.dart';
import '../services/voice_service.dart';
import '../utils/app_translations.dart';
import 'settings_screen.dart';

class HelpSupportScreen extends ConsumerStatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  ConsumerState<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends ConsumerState<HelpSupportScreen> {
  final TextEditingController _messageCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _isLoading = false;
  bool _isListening = false;
  int? _speakingMessageIndex;

  final List<Map<String, String>> _messages = [
    {
      'sender': 'assistant',
      'text': 'Hello! I am your SafeSenior AI Assistant. Ask me anything about suspicious calls, messages, OTP safety, or how to use the app.'
    },
  ];

  final List<String> _suggestedPrompts = [
    'Is this OTP call real?',
    'Bank KYC SMS check',
    'What is Digital Arrest?',
    'Electricity bill warning',
    'How does SOS button work?',
  ];

  Future<void> _sendMessage([String? presetText]) async {
    final text = (presetText ?? _messageCtrl.text).trim();
    if (text.isEmpty || _isLoading) return;

    final primaryGuardian = ref.read(primaryGuardianProvider);
    final user = ref.read(authProvider).user;
    final langCode = ref.read(languageProvider);

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      if (presetText == null) {
        _messageCtrl.clear();
      }
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final reply = await OpenRouterService.sendMessage(
        userMessage: text,
        history: _messages,
        languageCode: langCode,
        guardianName: primaryGuardian?.name,
        userName: user?.name,
      );

      if (!mounted) return;
      setState(() {
        _messages.add({'sender': 'assistant', 'text': reply});
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'sender': 'assistant',
          'text': AppTranslations.tr(
            'I am here to protect you. Never share your OTP or banking passwords with anyone. If this is an emergency, press the red SOS button.',
            langCode,
          )
        });
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _toggleSpeechToText() async {
    if (_isListening) {
      await VoiceService.stopListening();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    final langCode = ref.read(languageProvider);
    String? localeId;
    if (langCode == 'hi') localeId = 'hi_IN';
    if (langCode == 'gu') localeId = 'gu_IN';

    setState(() => _isListening = true);

    try {
      await VoiceService.startListening(
        localeId: localeId,
        onResult: (text) {
          if (mounted && text.isNotEmpty) {
            setState(() {
              _messageCtrl.text = text;
            });
          }
        },
        onDone: () {
          if (mounted) {
            setState(() => _isListening = false);
            if (_messageCtrl.text.trim().isNotEmpty) {
              _sendMessage();
            }
          }
        },
      );
    } catch (_) {
      if (mounted) setState(() => _isListening = false);
    }
  }

  Future<void> _toggleSpeakMessage(int index, String text) async {
    if (_speakingMessageIndex == index) {
      await VoiceService.stop();
      if (mounted) setState(() => _speakingMessageIndex = null);
    } else {
      await VoiceService.stop();
      if (mounted) setState(() => _speakingMessageIndex = index);
      try {
        await VoiceService.speak(text);
      } finally {
        if (mounted && _speakingMessageIndex == index) {
          setState(() => _speakingMessageIndex = null);
        }
      }
    }
  }

  @override
  void dispose() {
    VoiceService.stop();
    VoiceService.stopListening();
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final langCode = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.primaryTeal, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD7EFE6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.smart_toy_outlined, color: AppTheme.primaryTeal, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SafeSenior AI Assistant',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'AI Guardian Active • 24/7',
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 11.5,
                                color: const Color(0xFF5E706D),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                    child: CircleAvatar(
                      radius: 19,
                      backgroundColor: const Color(0xFFD6ECE8),
                      backgroundImage: user?.avatarPath != null
                          ? FileImage(File(user!.avatarPath!)) as ImageProvider
                          : const AssetImage('assets/images/app_logo.jpg'),
                      child: user?.avatarPath == null && (user?.name.isEmpty ?? true)
                          ? const Icon(Icons.person, color: AppTheme.primaryTeal, size: 18)
                          : null,
                    ),
                  ),
                ],
              ),
            ),

            // AI Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFE0F2F2),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: AppTheme.primaryTeal, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppTranslations.tr('Ask about suspicious calls, SMS, OTPs, or safety guidance.', langCode),
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 12,
                        color: AppTheme.primaryTeal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Chat Messages Feed
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == _messages.length && _isLoading) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primaryTeal,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              AppTranslations.tr('Thinking...', langCode),
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 13.5,
                                color: const Color(0xFF5E706D),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final msg = _messages[i];
                  final isUser = msg['sender'] == 'user';
                  final isSpeaking = _speakingMessageIndex == i;

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
                      child: Column(
                        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            decoration: BoxDecoration(
                              color: isUser ? AppTheme.primaryTeal : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft: Radius.circular(isUser ? 20 : 4),
                                bottomRight: Radius.circular(isUser ? 4 : 20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              msg['text']!,
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 15,
                                color: isUser ? Colors.white : const Color(0xFF2C3937),
                                height: 1.45,
                              ),
                            ),
                          ),
                          if (!isUser) ...[
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () => _toggleSpeakMessage(i, msg['text']!),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isSpeaking ? Icons.volume_off : Icons.volume_up_outlined,
                                      size: 16,
                                      color: isSpeaking ? AppTheme.terracottaRed : AppTheme.primaryTeal,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isSpeaking ? 'Stop voice' : 'Listen',
                                      style: GoogleFonts.atkinsonHyperlegible(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isSpeaking ? AppTheme.terracottaRed : AppTheme.primaryTeal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Suggested Prompts Horizontal Scroll
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _suggestedPrompts.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final prompt = _suggestedPrompts[i];
                  return ActionChip(
                    label: Text(
                      AppTranslations.tr(prompt, langCode),
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFBDC9C8), width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    onPressed: () => _sendMessage(prompt),
                  );
                },
              ),
            ),
            const SizedBox(height: 6),

            // Bottom Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Mic button with live listening animation
                  GestureDetector(
                    onTap: _toggleSpeechToText,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _isListening ? const Color(0xFFFFDAD6) : const Color(0xFFEFF5F3),
                        shape: BoxShape.circle,
                        border: _isListening ? Border.all(color: AppTheme.terracottaRed, width: 1.5) : null,
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening ? AppTheme.terracottaRed : AppTheme.primaryTeal,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF7F5),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE5ECE9)),
                      ),
                      child: TextField(
                        controller: _messageCtrl,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: _isListening
                              ? AppTranslations.tr('Listening...', langCode)
                              : AppTranslations.tr('Type a question or message...', langCode),
                          hintStyle: GoogleFonts.atkinsonHyperlegible(
                            color: _isListening ? AppTheme.terracottaRed : const Color(0xFF9EAEA8),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _sendMessage(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryTeal,
                        shape: BoxShape.circle,
                      ),
                      child: _isLoading
                          ? const Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.arrow_upward, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
