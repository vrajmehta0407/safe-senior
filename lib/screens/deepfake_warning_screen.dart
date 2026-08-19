import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/guardian_service.dart';

class DeepfakeWarningScreen extends StatelessWidget {
  final String callerNumber;
  final String callerName;
  final double syntheticProbability; // e.g. 0.94

  const DeepfakeWarningScreen({
    super.key,
    this.callerNumber = '+91 70123 45678',
    this.callerName = 'Suspected Voice Impersonation',
    this.syntheticProbability = 0.92,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1C1C),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Terracotta pulsing wave icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFAA361F).withValues(alpha: 0.2),
                  border: Border.all(color: const Color(0xFFAA361F), width: 3),
                ),
                child: const Center(
                  child: Icon(Icons.record_voice_over, color: Color(0xFFFE7356), size: 52),
                ),
              ),
              const SizedBox(height: 28),

              // Title
              Text(
                'AI Voice Clone Alert!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),

              // Confidence badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFAA361F),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(syntheticProbability * 100).round()}% Synthetic Audio Probability',
                  style: GoogleFonts.atkinsonHyperlegible(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Details card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF303031),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF6E7979)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Caller: $callerNumber',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The speech characteristics on this incoming call match an AI-generated synthetic voice clone. The caller may be impersonating a grandchild, spouse, or family member asking for urgent funds.',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 14.5,
                        color: const Color(0xFFE3E2E2),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F3E00),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.key, color: Color(0xFFFFE088), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Defense Rule: Ask your secret family codeword or hang up immediately.',
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFFFE088),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Disconnect Call & Notify Guardian CTA
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () async {
                    await GuardianService.notifyGuardian(
                      sender: callerNumber,
                      reason: 'AI Deepfake voice clone call intercepted on device.',
                    );
                    if (context.mounted) {
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
                      const Icon(Icons.call_end, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Disconnect & Alert Guardian',
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
              const SizedBox(height: 14),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Dismiss Warning (I know this caller)',
                  style: GoogleFonts.atkinsonHyperlegible(
                    fontSize: 15,
                    color: const Color(0xFFBDC9C8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
