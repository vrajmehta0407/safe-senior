import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../state/auth_provider.dart';
import '../state/guardian_provider.dart';
import '../state/language_provider.dart';
import '../services/openrouter_service.dart';
import '../utils/app_translations.dart';
import 'voice_listening_screen.dart';
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

  final List<Map<String, String>> _messages = [
    {
      'sender': 'assistant',
      'text': 'Hello! I am your SafeSenior AI Assistant. Ask me anything about suspicious calls, messages, OTP safety, or how to use the app.'
    },
  ];

  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty || _isLoading) return;

    final primaryGuardian = ref.read(primaryGuardianProvider);
    final user = ref.read(authProvider).user;
    final langCode = ref.read(languageProvider);

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _messageCtrl.clear();
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
          _scrollCtrl.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.primaryTeal, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'SafeSenior',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFD6ECE8),
                      backgroundImage: user?.avatarPath != null
                          ? FileImage(File(user!.avatarPath!)) as ImageProvider
                          : const AssetImage('assets/images/app_logo.jpg'),
                      child: user?.avatarPath == null && (user?.name.isEmpty ?? true)
                          ? const Icon(Icons.person, color: AppTheme.primaryTeal, size: 20)
                          : null,
                    ),
                  ),
                ],
              ),
            ),

            // AI Support Hero Shield & Greeting
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD7EFE6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_outlined, color: AppTheme.primaryTeal, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppTranslations.tr('Hello there.', langCode),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppTranslations.tr('How can I help protect your sanctuary today?', langCode),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.atkinsonHyperlegible(
                      fontSize: 14.5,
                      color: const Color(0xFF5E706D),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Chat Messages Feed
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                      decoration: BoxDecoration(
                        color: isUser ? AppTheme.primaryTeal : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(24),
                          topRight: const Radius.circular(24),
                          bottomLeft: Radius.circular(isUser ? 24 : 6),
                          bottomRight: Radius.circular(isUser ? 6 : 24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        msg['text']!,
                        style: GoogleFonts.atkinsonHyperlegible(
                          fontSize: 14.5,
                          color: isUser ? Colors.white : const Color(0xFF2C3937),
                          height: 1.45,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const VoiceListeningScreen()),
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF5F3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mic, color: AppTheme.primaryTeal, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF7F5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageCtrl,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: AppTranslations.tr('Type a message...', langCode),
                          hintStyle: GoogleFonts.atkinsonHyperlegible(color: const Color(0xFF9EAEA8), fontSize: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendMessage,
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
                          : const Icon(Icons.arrow_upward, color: Colors.white, size: 20),
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
