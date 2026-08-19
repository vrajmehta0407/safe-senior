import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import '../services/guardian_service.dart';
import '../state/guardian_provider.dart';
import 'sos_notifying_screen.dart';

class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({super.key});

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen> {
  bool _isActivating = false;

  Future<void> _triggerSOS() async {
    setState(() => _isActivating = true);
    await GuardianService.sendEmergencyAlert();
    if (!mounted) return;
    setState(() => _isActivating = false);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SosNotifyingScreen()),
    );
  }

  Future<void> _callPhone(String number) async {
    final Uri uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      await GuardianService.sendEmergencyAlert();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryGuardian = ref.watch(primaryGuardianProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Header Title
              Text(
                'Emergency',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tap to dispatch immediate help',
                style: GoogleFonts.atkinsonHyperlegible(
                  fontSize: 14.5,
                  color: const Color(0xFF5E706D),
                ),
              ),
              const Spacer(),

              // Giant Red Circular SOS Button
              GestureDetector(
                onTap: _isActivating ? null : _triggerSOS,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.terracottaRed,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.terracottaRed.withValues(alpha: 0.35),
                        blurRadius: 40,
                        spreadRadius: 10,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                      ),
                      child: Center(
                        child: _isActivating
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'SOS',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Quick Connect Label
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'QUICK CONNECT',
                  style: GoogleFonts.atkinsonHyperlegible(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5E706D),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Emergency Option 1: National Emergency Response (112)
              GestureDetector(
                onTap: () => _callPhone('112'),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFBE0D8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.local_police_outlined, color: AppTheme.terracottaRed, size: 22),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Police / Emergency (112)',
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C3937),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'National Emergency Hotline (India 112)',
                              style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, color: const Color(0xFF6B7B78)),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.phone_forwarded_outlined, size: 20, color: AppTheme.terracottaRed),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Emergency Option 2: Cybercrime Reporting Helpline (1930)
              GestureDetector(
                onTap: () => _callPhone('1930'),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFECE8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.security, color: Color(0xFFAA361F), size: 22),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cybercrime Helpline (1930)',
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C3937),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'MHA Cyber Financial Fraud Hotline',
                              style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, color: const Color(0xFF6B7B78)),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.phone_forwarded_outlined, size: 20, color: Color(0xFFAA361F)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Emergency Option 3: Primary Guardian (Amit Patel)
              GestureDetector(
                onTap: () => _callPhone(primaryGuardian?.phone ?? '+91 98250 14820'),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD7EFE6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shield_outlined, color: AppTheme.primaryTeal, size: 22),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              primaryGuardian != null ? 'Call ${primaryGuardian.name}' : 'Guardian (Amit Patel)',
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C3937),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              primaryGuardian?.phone ?? '+91 98250 14820 (Family Response)',
                              style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, color: const Color(0xFF6B7B78)),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.phone_forwarded_outlined, size: 20, color: AppTheme.primaryTeal),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Cancel Link
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'CANCEL & RETURN',
                  style: GoogleFonts.atkinsonHyperlegible(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5E706D),
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
