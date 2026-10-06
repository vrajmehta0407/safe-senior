import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../theme.dart';
import '../services/detection/blocklist_service.dart';
import '../services/guardian_service.dart';
import '../services/trusted_sender_cache.dart';

class SmsScamAlertScreen extends StatelessWidget {
  final String senderNumber;
  final String messageBody;
  final String scamType;
  final List<String> redFlags;

  const SmsScamAlertScreen({
    super.key,
    this.senderNumber = '+91 98765 43210',
    this.messageBody = 'Dear Customer, Your HDFC Bank account will be blocked. Update your KYC immediately at http://hdfc-kyc-update.xyz to avoid suspension.',
    this.scamType = 'KYC Update Fraud',
    this.redFlags = const [
      'Suspicious link domain (not hdfc.com)',
      'Urgent language to create panic',
      'Requests personal/KYC information',
      'Not from official bank short-code',
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Danger header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: AppTheme.dangerRed),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      ),
                      const Spacer(),
                      Text(
                        '🚨 SCAM DETECTED',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 20),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      scamType,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // The suspicious message
                    Text(
                      'Suspicious Message',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.dangerRed.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.dangerRed.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.sms_outlined, size: 16, color: AppTheme.textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                senderNumber,
                                style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: AppTheme.dangerRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(50)),
                                child: Text('BLOCKED', style: GoogleFonts.atkinsonHyperlegible(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.dangerRed)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            messageBody,
                            style: GoogleFonts.atkinsonHyperlegible(fontSize: 15, color: AppTheme.textPrimary, height: 1.5),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Red flags
                    Text(
                      'Red Flags Detected',
                      style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    ...redFlags.map((flag) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(color: AppTheme.dangerRed.withValues(alpha: 0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.warning_amber_outlined, size: 18, color: AppTheme.dangerRed),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(flag, style: GoogleFonts.atkinsonHyperlegible(fontSize: 14, color: AppTheme.textPrimary, height: 1.3)),
                            ),
                          ],
                        ),
                      ),
                    )),

                    const SizedBox(height: 16),

                    // Safety advice
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.shield_outlined, color: AppTheme.primaryTeal, size: 20),
                              const SizedBox(width: 8),
                              Text('SafeSenior Advice', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryTeal)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Do NOT click any links in this message. Real banks never ask you to update KYC via SMS links. This message has been blocked and your guardian has been notified.',
                            style: GoogleFonts.atkinsonHyperlegible(fontSize: 14, color: AppTheme.primaryTeal, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        elevation: 0,
                      ),
                      child: Text('Message Blocked — I\'m Safe', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final box = context.findRenderObject() as RenderBox?;
                        final origin = box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;
                        final shareMsg = '''🚨 SafeSenior Phishing Alert!

A fraudulent SMS was intercepted and blocked on my phone:
⚠️ Type: $scamType
📞 Sender: $senderNumber
💬 Message: "$messageBody"

SafeSenior has secured my phone. Please do not open links from this sender!''';

                        await SharePlus.instance.share(
                          ShareParams(
                            text: shareMsg,
                            subject: '⚠️ Phishing Scam Warning: $scamType',
                            sharePositionOrigin: origin,
                          ),
                        );
                      },
                      icon: const Icon(Icons.share, size: 16, color: AppTheme.primaryTeal),
                      label: Text('Share Warning with Family / WhatsApp', style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryTeal, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            BlocklistService.blockSender(senderNumber);
                            GuardianService.notifyAllGuardiansAboutScam(sender: senderNumber, reason: scamType).ignore();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Sender $senderNumber blocked & guardians notified.'),
                                backgroundColor: AppTheme.dangerRed,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.report_outlined, size: 16),
                          label: const Text('Block & Report'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.dangerRed),
                            foregroundColor: AppTheme.dangerRed,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            TrustedSenderCache.addLocal(senderNumber);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Sender $senderNumber added to trusted safe list.'),
                                backgroundColor: AppTheme.primaryTeal,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.check_circle_outline, size: 16),
                          label: const Text('Mark as Safe'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primaryTeal),
                            foregroundColor: AppTheme.primaryTeal,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                          ),
                        ),
                      ),
                    ],
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
