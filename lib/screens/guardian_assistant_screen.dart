import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../services/guardian_service.dart';
import '../services/voice_service.dart';
import '../services/openrouter_service.dart';
import '../state/language_provider.dart';
import '../state/guardian_provider.dart';
import '../state/auth_provider.dart';
import '../utils/app_translations.dart';
import 'settings_screen.dart';

class GuardianAssistantScreen extends ConsumerStatefulWidget {
  const GuardianAssistantScreen({super.key});

  @override
  ConsumerState<GuardianAssistantScreen> createState() => _GuardianAssistantScreenState();
}

class _GuardianAssistantScreenState extends ConsumerState<GuardianAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'text': "Hello! I'm your Guardian Assistant. How can I help keep you safe today?",
      'isBot': true,
      'time': 'Just now'
    },
  ];

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    final primaryGuardian = ref.read(primaryGuardianProvider);
    final user = ref.read(authProvider).user;
    final langCode = ref.read(languageProvider);

    setState(() {
      _messages.add({'text': text, 'isBot': false, 'time': 'Sent'});
      _messageController.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final reply = await OpenRouterService.sendMessage(
        userMessage: text,
        history: _messages.map((m) => {
          'sender': (m['isBot'] == true) ? 'assistant' : 'user',
          'text': m['text'] as String,
        }).toList(),
        languageCode: langCode,
        guardianName: primaryGuardian?.name,
        userName: user?.name,
      );

      if (!mounted) return;
      setState(() {
        _messages.add({'text': reply, 'isBot': true, 'time': 'Just now'});
        _isLoading = false;
      });
      VoiceService.speak(reply);
    } catch (_) {
      if (!mounted) return;
      final fallback = AppTranslations.tr(
        'I received your message. If this is an emergency, please press SOS below.',
        langCode,
      );
      setState(() {
        _messages.add({'text': fallback, 'isBot': true, 'time': 'Just now'});
        _isLoading = false;
      });
      VoiceService.speak(fallback);
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _onSosTapped() async {
    final sent = await GuardianService.sendEmergencyAlert(
      message: '🚨 SOS from Guardian Assistant: I need help immediately!',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(sent ? 'Emergency alert sent to your guardian.' : 'No guardian contact set. Please add one first.'),
          backgroundColor: sent ? Colors.green[700] : Colors.red[700],
        ),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langCode = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.circle, size: 4, color: AppTheme.textDark),
        title: Text(
          AppTranslations.tr('Guardian Assistant', langCode),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppTheme.primaryDarkBlue,
              ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.textDark),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.withValues(alpha: 0.2),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Chat Messages Area
            Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20.0),
                    itemCount: _messages.length + (_isLoading ? 1 : 0) + 1,
                    separatorBuilder: (_, _) => const SizedBox(height: 24),
                    itemBuilder: (context, index) {
                      if (index == _messages.length + (_isLoading ? 1 : 0)) {
                        return const SizedBox(height: 140);
                      }
                      if (index == _messages.length && _isLoading) {
                        return _buildChatBubble(
                          text: AppTranslations.tr('Thinking...', langCode),
                          isBot: true,
                          time: '...',
                        );
                      }
                      final m = _messages[index];
                      return _buildChatBubble(
                        text: m['text'] as String,
                        isBot: m['isBot'] as bool,
                        time: m['time'] as String,
                      );
                    },
                  ),
                ),
                
                // Bottom Input Area
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        offset: const Offset(0, -4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.withValues(alpha: 0.6)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _messageController,
                                      onSubmitted: (_) => _sendMessage(),
                                      decoration: InputDecoration(
                                        hintText: AppTranslations.tr('Type your question...', langCode),
                                        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: _isLoading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : const Icon(Icons.send_outlined, color: AppTheme.primaryDarkBlue),
                                    onPressed: _sendMessage,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryDarkBlue,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.mic, color: Colors.white, size: 28),
                              onPressed: () => VoiceService.startListening(
                                onResult: (text) {
                                  _messageController.text = text;
                                  _sendMessage();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppTranslations.tr('Tap to Speak', langCode),
                        style: const TextStyle(
                          color: AppTheme.primaryDarkBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Custom Bottom Nav
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(icon: Icons.chat_bubble, label: 'Chat', isSelected: true),
                      _buildNavItem(icon: Icons.security, label: 'Safety Log', isSelected: false),
                      _buildNavItem(icon: Icons.help_outline, label: 'Support', isSelected: false),
                    ],
                  ),
                ),
              ],
            ),

            // Floating SOS Button
            Positioned(
              left: 20,
              right: 20,
              bottom: 150,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      offset: const Offset(0, 8),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _onSosTapped,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone, size: 32),
                      SizedBox(width: 16),
                      Text(
                        'SOS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble({required String text, required bool isBot, required String time}) {
    return Column(
      crossAxisAlignment: isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isBot ? AppTheme.primaryLightBlue.withValues(alpha: 0.2) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isBot ? 0 : 16),
              bottomRight: Radius.circular(isBot ? 16 : 0),
            ),
            border: isBot ? null : Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required bool isSelected}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? AppTheme.primaryDarkBlue : Colors.grey[500],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryDarkBlue : Colors.grey[500],
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
