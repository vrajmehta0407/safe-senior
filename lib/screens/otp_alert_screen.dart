// lib/screens/otp_alert_screen.dart
// Scam-warning screen — populated with real ScannedMessage data.
// Layout and styling are UNCHANGED from the original; only dead data is replaced.

import 'package:flutter/material.dart';
import '../models/scanned_message.dart';
import '../services/guardian_service.dart';
import '../services/voice_service.dart';

class OtpAlertScreen extends StatefulWidget {
  /// The detected scam message this warning refers to.
  /// If null, the screen shows generic hardcoded copy (backwards-compat).
  final ScannedMessage? message;

  const OtpAlertScreen({super.key, this.message});

  @override
  State<OtpAlertScreen> createState() => _OtpAlertScreenState();
}

class _OtpAlertScreenState extends State<OtpAlertScreen> {
  bool _notified = false;

  @override
  void initState() {
    super.initState();
    // Speak the scam alert on screen entry
    final sender = widget.message?.sender ?? 'Unknown';
    VoiceService.speakScamAlert(sender);
  }

  Future<void> _onDidNotShare() async {
    // Notify guardian that user was targeted but did NOT share the code
    if (!_notified) {
      final sender = widget.message?.sender ?? 'Unknown';
      final reason = widget.message?.reasons.isNotEmpty == true
          ? widget.message!.reasons.first
          : 'OTP scam detected';
      await GuardianService.notifyGuardian(sender: sender, reason: reason);
      setState(() => _notified = true);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final Color redTheme = const Color(0xFFC62828);
    final msg = widget.message;
    final senderDisplay = msg?.sender ?? 'UNKNOWN';
    final reasons = msg?.reasons ?? [];

    return Scaffold(
      backgroundColor: redTheme,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              const Icon(Icons.warning_amber_rounded, size: 60, color: Colors.white),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🚨', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 8),
                  Text(
                    'STOP! DO NOT\nSHARE!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(width: 8),
                  const Text('🚨', style: TextStyle(fontSize: 32)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'A highly suspicious activity has been\ndetected. Protect your account\nimmediately.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 32),

              // Suspicious Message Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.person_outline, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                const WidgetSpan(
                                  child: Icon(Icons.warning, color: Colors.amber, size: 20),
                                  alignment: PlaceholderAlignment.middle,
                                ),
                                const TextSpan(text: ' '),
                                TextSpan(
                                  // Populated from real ScannedMessage.sender
                                  text: 'SUSPICIOUS MESSAGE FROM: $senderDisplay',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.red[900],
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Code hidden for your\nsafety',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '*   *   *\n*   *   *',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Show detected risk reasons if available
                    if (reasons.isNotEmpty)
                      ...reasons.map((r) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    r,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.red[800], fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ))
                    else
                      Text(
                        'If someone is asking for this code right now, they are trying to steal your access.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Colors.black87,
                            ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Checklist Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEAEA), // Light Pink — unchanged
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified_user_outlined, color: Colors.red[900]),
                        const SizedBox(width: 8),
                        Text(
                          'Safety Verification Checklist',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.red[900],
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildChecklistItem(context, 'NEVER share this code with anyone, even family or "bank staff".'),
                    const SizedBox(height: 12),
                    _buildChecklistItem(context, 'Banks NEVER ask for OTP via phone call or text.'),
                    const SizedBox(height: 12),
                    _buildChecklistItem(context, 'This could be a SCAM intended to lock you out.'),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // I Did NOT Share Button — now fires guardian notification
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onDidNotShare,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: redTheme,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, color: redTheme),
                      const SizedBox(width: 8),
                      Text(
                        'I Did NOT Share This Code',
                        style: TextStyle(fontSize: 18, color: redTheme),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 1),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'I Understand - Close',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Text(
                'Safe Senior Security System is monitoring this\nsession. Your protection is our priority.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistItem(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.remove_circle, color: Colors.red[600], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red[900],
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
