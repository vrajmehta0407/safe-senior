import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class ScannedWhatsAppFeedScreen extends StatefulWidget {
  const ScannedWhatsAppFeedScreen({super.key});

  @override
  State<ScannedWhatsAppFeedScreen> createState() => _ScannedWhatsAppFeedScreenState();
}

class _ScannedWhatsAppFeedScreenState extends State<ScannedWhatsAppFeedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppTheme.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scanned WhatsApp Messages',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'WhatsApp Scam & APK Protection',
                          style: GoogleFonts.atkinsonHyperlegible(
                            fontSize: 13,
                            color: const Color(0xFF25D366),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  _buildMessageCard(
                    sender: '+92 300 1234567 (Unknown Number)',
                    message: 'Hello Grandma, I lost my phone while traveling in Dubai. Please send ₹50,000 urgently on this UPI ID: emergency@upi',
                    time: '11:45 AM',
                    isThreat: true,
                    threatTitle: 'Grandchild Impersonation Scam',
                    actionLabel: 'Reported & Blocked',
                  ),
                  const SizedBox(height: 12),
                  _buildMessageCard(
                    sender: '+91 91234 56789 (Unknown Number)',
                    message: 'Congratulations! You won ₹25,00,000 in KBC Lottery. Download the attached official winning claim app (kbc-claim.apk) to receive money.',
                    time: 'Yesterday',
                    isThreat: true,
                    threatTitle: 'Malicious APK & Lottery Fraud',
                    actionLabel: 'Dangerous APK Intercepted',
                  ),
                  const SizedBox(height: 12),
                  _buildMessageCard(
                    sender: 'Amit Patel (Son)',
                    message: 'Hi Papa, reaching home by 7:30 PM. Let me know if you need any medicines from the chemist.',
                    time: 'Aug 15',
                    isThreat: false,
                    threatTitle: 'Verified Guardian Contact',
                    actionLabel: 'Safe Message',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard({
    required String sender,
    required String message,
    required String time,
    required bool isThreat,
    required String threatTitle,
    required String actionLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isThreat
            ? const Border(left: BorderSide(color: AppTheme.dangerRed, width: 4))
            : const Border(left: BorderSide(color: Color(0xFF25D366), width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isThreat ? AppTheme.dangerRed.withOpacity(0.1) : const Color(0xFF25D366).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isThreat ? Icons.warning_amber_rounded : Icons.check_circle,
                  color: isThreat ? AppTheme.dangerRed : const Color(0xFF25D366),
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  sender,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Text(
                time,
                style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: GoogleFonts.atkinsonHyperlegible(fontSize: 14.5, color: AppTheme.textPrimary, height: 1.4),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isThreat ? AppTheme.dangerRed.withOpacity(0.08) : const Color(0xFF25D366).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$threatTitle • $actionLabel',
              style: GoogleFonts.atkinsonHyperlegible(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isThreat ? AppTheme.dangerRed : const Color(0xFF25D366),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
