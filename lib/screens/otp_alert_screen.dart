import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/guardian_service.dart';
import '../services/detection/blocklist_service.dart';
import '../services/detection/otp_masking_service.dart';

class OtpAlertScreen extends StatelessWidget {
  final String? code;
  final String? sender;
  final String? message;

  const OtpAlertScreen({
    super.key,
    this.code,
    this.sender,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSender = sender ?? '+91 98210 44921 (Unknown / Spoofed)';
    final rawMessage = message ?? 'Your SBI NetBanking OTP is 849201 for payment of Rs 45,000 to Unknown Beneficiary. Valid for 5 mins. Do not share with anyone.';
    final maskedMessage = OtpMaskingService.maskCodes(rawMessage);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),

              // Top Pulsing Critical Alert Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBE6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFE7356), width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFAA361F),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CRITICAL THREAT INTERCEPTED',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFAA361F),
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Warning Shield Icon
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECE8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFAA361F).withValues(alpha: 0.18),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.security_update_warning,
                    color: Color(0xFFAA361F),
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title
              Text(
                'OTP Safety Shield',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B1C1C),
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Verification code hidden to prevent theft.',
                textAlign: TextAlign.center,
                style: GoogleFonts.atkinsonHyperlegible(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF5E706D),
                ),
              ),
              const SizedBox(height: 20),

              // ── STYLIZED MASKED OTP CARD ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFFFDAD3), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_rounded, size: 16, color: Color(0xFFAA361F)),
                        const SizedBox(width: 6),
                        Text(
                          'CONFIDENTIAL CODE MASKED',
                          style: GoogleFonts.atkinsonHyperlegible(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFAA361F),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 6-Pin Lock Block Display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: 42,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F3F3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE3E2E2), width: 1.5),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.circle,
                              size: 14,
                              color: Color(0xFFAA361F),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4E5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shield, size: 14, color: Color(0xFFB5431F)),
                          const SizedBox(width: 6),
                          Text(
                            'Protected by SafeSenior Security Vault',
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF735C00),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── INTERCEPTED MESSAGE DETAILS CARD ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
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
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFECE8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.sms_failed_outlined, size: 16, color: Color(0xFFAA361F)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sender / Originator',
                                style: GoogleFonts.atkinsonHyperlegible(fontSize: 11, color: const Color(0xFF6E7979), fontWeight: FontWeight.w600),
                              ),
                              Text(
                                effectiveSender,
                                style: GoogleFonts.atkinsonHyperlegible(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1B1C1C),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFDAD3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Flagged',
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFAA361F),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: Color(0xFFEFEDED)),
                    Text(
                      'Intercepted Message Preview:',
                      style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF6E7979)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3F3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        maskedMessage,
                        style: GoogleFonts.atkinsonHyperlegible(
                          fontSize: 13.5,
                          color: const Color(0xFF1B1C1C),
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── CRITICAL WARNING ADVISORY ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFAF8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFB4A5), width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFAA361F), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'DO NOT read this OTP to anyone calling about SBI YONO, Electricity bills, CBI Digital Arrest, or lottery prizes. Real officials never ask for OTPs.',
                        style: GoogleFonts.atkinsonHyperlegible(
                          fontSize: 12.5,
                          color: const Color(0xFF3E4949),
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── ACTION 1: Block Sender & Report to 1930 ──
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    BlocklistService.blockSender(effectiveSender);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sender permanently blocked & reported to Cybercrime Helpline 1930.'),
                        backgroundColor: Color(0xFFAA361F),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.block, size: 20),
                  label: Text(
                    'Block & Report to 1930 Helpline',
                    style: GoogleFonts.atkinsonHyperlegible(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAA361F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 3,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── ACTION 2: Alert Guardian (Family) ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    GuardianService.sendEmergencyAlert();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Emergency OTP Alert sent to your Guardian (Amit Patel).'),
                        backgroundColor: Color(0xFF006565),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.shield_outlined, size: 20),
                  label: Text(
                    'Alert Guardian (Family Help)',
                    style: GoogleFonts.atkinsonHyperlegible(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006565),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── ACTION 3: I Understand - Dismiss ──
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5E706D),
                    side: const BorderSide(color: Color(0xFFBDC9C8), width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: Text(
                    'I Will Not Share - Close Safely',
                    style: GoogleFonts.atkinsonHyperlegible(fontWeight: FontWeight.bold, fontSize: 14.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
