import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/guardian_service.dart';

class SimSwapAlertScreen extends StatelessWidget {
  final String carrierName;
  final String phoneNumber;

  const SimSwapAlertScreen({
    super.key,
    this.carrierName = 'Jio Telecom',
    this.phoneNumber = '+91 98250 14820',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFDAD6),
                  border: Border.all(color: const Color(0xFFAA361F), width: 2.5),
                ),
                child: const Center(
                  child: Icon(Icons.sim_card_alert, color: Color(0xFFAA361F), size: 48),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'SIM-Swap Warning Detected!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'A request to transfer your phone number to a new SIM card or eSIM has been initiated with $carrierName.',
                textAlign: TextAlign.center,
                style: GoogleFonts.atkinsonHyperlegible(
                  fontSize: 15.5,
                  color: AppTheme.textLight,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE3E2E2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'If you did NOT request this SIM swap:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFAA361F),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _bullet('Scammers transfer your SIM to intercept your banking OTPs.'),
                    _bullet('Immediately contact $carrierName customer care from a landline or guardian\'s phone.'),
                    _bullet('Lock your bank NetBanking accounts immediately.'),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    await GuardianService.notifyGuardian(
                      sender: carrierName,
                      reason: 'CRITICAL: Unauthorized SIM Swap detected on senior line ($phoneNumber).',
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '🚨 Emergency SIM Alert transmitted to primary guardian!',
                            style: GoogleFonts.atkinsonHyperlegible(color: Colors.white),
                          ),
                          backgroundColor: const Color(0xFFAA361F),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAA361F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emergency, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Alert Family Guardian Now',
                        style: GoogleFonts.atkinsonHyperlegible(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'I requested this SIM upgrade (Dismiss)',
                  style: GoogleFonts.atkinsonHyperlegible(
                    fontSize: 15,
                    color: AppTheme.textLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.arrow_right, color: Color(0xFFAA361F), size: 20),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.atkinsonHyperlegible(
                fontSize: 14,
                color: AppTheme.textDark,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
