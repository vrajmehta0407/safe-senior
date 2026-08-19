import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/detection/blocklist_service.dart';
import '../services/guardian_service.dart';

class WarningAlertScreen extends StatelessWidget {
  final String? sender;
  final String? messageBody;

  const WarningAlertScreen({
    super.key,
    this.sender,
    this.messageBody,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSender = sender ?? '+91 11 2309 4712 (CBI Cyber Branch Spoof)';
    final effectiveBody = messageBody ??
        '"Beta/Babuji, I am under Digital Arrest at Delhi Airport Customs regarding a parcel containing contraband. Demand ₹50,000 immediately to avoid arrest. Transfer via UPI QR code attached..."';

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),

              // Urgency Badge
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
                    const Icon(Icons.gavel_rounded, size: 14, color: Color(0xFFAA361F)),
                    const SizedBox(width: 8),
                    Text(
                      'SUSPICIOUS COERCION DETECTED',
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
              const SizedBox(height: 18),

              // Terracotta Warning Shield Icon
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
                    Icons.warning_amber_rounded,
                    color: Color(0xFFAA361F),
                    size: 42,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Text(
                'Scam Alert',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B1C1C),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'High risk message flagged by SafeSenior AI.',
                textAlign: TextAlign.center,
                style: GoogleFonts.atkinsonHyperlegible(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF5E706D),
                ),
              ),
              const SizedBox(height: 22),

              // Threat Card Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFFFDAD3), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.perm_phone_msg_outlined, color: Color(0xFFAA361F), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            effectiveSender,
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1B1C1C),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3F3),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        effectiveBody,
                        style: GoogleFonts.atkinsonHyperlegible(
                          fontSize: 14,
                          color: const Color(0xFF2E3D3A),
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 14, color: Color(0xFFAA361F)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Vector: Digital Arrest / Extortion Impersonation',
                            style: GoogleFonts.atkinsonHyperlegible(fontSize: 11.5, color: const Color(0xFFAA361F), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action 1: Block & Report to 1930
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
                  icon: const Icon(Icons.shield_outlined, size: 20),
                  label: Text(
                    'Block & Report (1930 Helpline)',
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

              // Action 2: Call Guardian for Help
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    GuardianService.sendEmergencyAlert();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Alert dispatched to Amit Patel (Primary Guardian).'),
                        backgroundColor: Color(0xFF006565),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.phone_in_talk, size: 20),
                  label: Text(
                    'Call Guardian (Amit Patel)',
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

              // Action 3: I Trust This Person
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
                    'I Trust This Person - Dismiss',
                    style: GoogleFonts.atkinsonHyperlegible(fontSize: 14.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Bottom Protection Subtext
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 14, color: Color(0xFF6E7979)),
                  const SizedBox(width: 6),
                  Text(
                    'Secured by SafeSenior Defense Suite',
                    style: GoogleFonts.atkinsonHyperlegible(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6E7979),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
