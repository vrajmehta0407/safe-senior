import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../theme.dart';
import '../services/guardian_service.dart';
import 'emergency_screen.dart';
import 'guardian_contacts_screen.dart';

class UnusualLocationScreen extends StatelessWidget {
  final String detectedLocation;
  final String expectedLocation;
  final String timeDetected;

  const UnusualLocationScreen({
    super.key,
    this.detectedLocation = 'Connaught Place, Delhi',
    this.expectedLocation = 'Malviya Nagar, Delhi',
    this.timeDetected = '3:47 PM',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Alert header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFF6F00),
              ),
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
                        '⚠️ LOCATION ALERT',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Unusual Location Pattern',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Detected at $timeDetected today',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.atkinsonHyperlegible(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Map placeholder
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFF6F00).withValues(alpha: 0.3)),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.map_outlined, size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                Text(
                                  'Location Map',
                                  style: GoogleFonts.atkinsonHyperlegible(fontSize: 14, color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                          // Current location pin
                          Positioned(
                            top: 60,
                            left: 100,
                            child: Column(
                              children: [
                                Icon(Icons.location_on, color: const Color(0xFFFF6F00), size: 32),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6F00),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('Current', style: GoogleFonts.atkinsonHyperlegible(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ),
                          // Home location pin
                          Positioned(
                            top: 90,
                            right: 80,
                            child: Column(
                              children: [
                                const Icon(Icons.home, color: AppTheme.primaryTeal, size: 28),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryTeal,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('Home', style: GoogleFonts.atkinsonHyperlegible(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Location details
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildLocationRow(
                            Icons.location_on,
                            const Color(0xFFFF6F00),
                            'Current Location',
                            detectedLocation,
                            'Unusual — not your typical area',
                          ),
                          const Divider(height: 24),
                          _buildLocationRow(
                            Icons.home_outlined,
                            AppTheme.primaryTeal,
                            'Your Home Area',
                            expectedLocation,
                            'Your usual location',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Guardian notification status & Live Share
                    Builder(
                      builder: (ctx) {
                        final primaryGuardian = GuardianService.getPrimaryGuardian();
                        final gName = primaryGuardian != null
                            ? '${primaryGuardian.name}${primaryGuardian.relationship != null ? ' (${primaryGuardian.relationship})' : ''}'
                            : null;

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6F00).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFF6F00).withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.notifications_active, color: Color(0xFFFF6F00), size: 22),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      gName != null
                                          ? '$gName is linked for location safety updates.'
                                          : 'No guardian linked yet. Share your location with family below.',
                                      style: GoogleFonts.atkinsonHyperlegible(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFFF6F00),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: TextButton.icon(
                                  onPressed: () async {
                                    final box = ctx.findRenderObject() as RenderBox?;
                                    final origin = box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;
                                    final locMsg = '📍 SafeSenior Location Notice:\nI am currently at $detectedLocation (Expected: $expectedLocation at $timeDetected).\n\nSent from SafeSenior Protection App.';
                                    await SharePlus.instance.share(
                                      ShareParams(
                                        text: locMsg,
                                        subject: 'SafeSenior Location Update',
                                        sharePositionOrigin: origin,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.share, size: 16, color: Color(0xFFFF6F00)),
                                  label: Text(
                                    'Share Current Location with Family',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFFF6F00),
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // What to do section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('What should you do?', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                          const SizedBox(height: 14),
                          _buildAdvice('If you went out intentionally, you\'re safe. Just confirm below.'),
                          const SizedBox(height: 8),
                          _buildAdvice('If you\'re confused or feel unsafe, call a guardian immediately.'),
                          const SizedBox(height: 8),
                          _buildAdvice('If someone forced you to go somewhere, press the SOS button.'),
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
                      child: Text("I'm Safe — Went Out Intentionally", style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuardianContactsScreen())),
                          icon: const Icon(Icons.call, size: 18),
                          label: const Text('Call Guardian'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primaryTeal),
                            foregroundColor: AppTheme.primaryTeal,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyScreen())),
                          icon: const Icon(Icons.sos, size: 18),
                          label: const Text('SOS'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.dangerRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                            elevation: 0,
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

  Widget _buildLocationRow(IconData icon, Color color, String label, String location, String note) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary, letterSpacing: 0.3)),
              const SizedBox(height: 2),
              Text(location, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 2),
              Text(note, style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, color: color)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdvice(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.arrow_right, color: AppTheme.primaryTeal, size: 20),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text, style: GoogleFonts.atkinsonHyperlegible(fontSize: 14, color: AppTheme.textPrimary, height: 1.4)),
        ),
      ],
    );
  }
}
