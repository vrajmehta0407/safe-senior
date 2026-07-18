import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/guardian_service.dart';
import '../services/voice_service.dart';
import 'settings_screen.dart';

class GuardianAssistantScreen extends StatefulWidget {
  const GuardianAssistantScreen({super.key});

  @override
  State<GuardianAssistantScreen> createState() => _GuardianAssistantScreenState();
}

class _GuardianAssistantScreenState extends State<GuardianAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'text': "Hello! I'm your Guardian Assistant. How can I help keep you safe today?", 'isBot': true, 'time': 'Just now'},
  ];

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'text': text, 'isBot': false, 'time': 'Sent'});
      _messages.add({'text': 'I received your message. If this is an emergency, please press SOS below.', 'isBot': true, 'time': 'Just now'});
    });
    _messageController.clear();
    VoiceService.speak('I received your message.');
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC), // Very light blue/grey from image
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.circle, size: 4, color: AppTheme.textDark), // Small dot from image
        title: Text(
          'Guardian Assistant',
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
                    padding: const EdgeInsets.all(20.0),
                    itemCount: _messages.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(height: 24),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) return const SizedBox(height: 140);
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
                                      decoration: InputDecoration(
                                        hintText: 'Type your question...',
                                        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.send_outlined, color: AppTheme.primaryDarkBlue),
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
                              onPressed: () => VoiceService.startListening(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap to Speak',
                        style: TextStyle(
                          color: AppTheme.primaryDarkBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Custom Bottom Nav from Image 0 (Chat, Safety Log, Support)
                // Assuming we might want to replicate this exactly for this screen
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
              bottom: 150, // Positioned above the input area
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
                    backgroundColor: const Color(0xFFC62828), // Dark red
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
            color: isBot ? AppTheme.primaryDarkBlue : const Color(0xFFE3EBF8), // Bot: Dark Blue, User: Light Blue
            borderRadius: BorderRadius.only(
              topLeft: isBot ? const Radius.circular(4) : const Radius.circular(16),
              topRight: isBot ? const Radius.circular(16) : const Radius.circular(16),
              bottomLeft: const Radius.circular(16),
              bottomRight: isBot ? const Radius.circular(16) : const Radius.circular(16),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isBot ? Colors.white : AppTheme.textDark,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
        if (time.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: isSelected
          ? BoxDecoration(
              color: AppTheme.primaryLightBlue.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? AppTheme.primaryDarkBlue : Colors.grey[700]),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.primaryDarkBlue : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
