import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/guardian_contact.dart';

class GuardianPermissionsScreen extends StatefulWidget {
  final GuardianContact? guardian;

  const GuardianPermissionsScreen({super.key, this.guardian});

  @override
  State<GuardianPermissionsScreen> createState() => _GuardianPermissionsScreenState();
}

class _GuardianPermissionsScreenState extends State<GuardianPermissionsScreen> {
  bool _notifyHighThreats = true;
  bool _notifySosCalls = true;
  bool _notifyDailyHealth = false;
  bool _allowRemoteLocation = true;
  bool _allowSpendingAlerts = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFBF7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Guardian Permissions',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Guardian Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFE3E2E2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE0F2F2),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.person, color: AppTheme.primaryTeal, size: 28),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.guardian?.name ?? 'Amit Patel',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${widget.guardian?.relationship ?? "Family"} • ${widget.guardian?.phone ?? "+91 98250 14820"}',
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 14,
                                    color: AppTheme.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Notification & Alert Controls',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _permTile(
                      title: 'Critical Threat & Scam Alerts',
                      subtitle: 'Notify ${widget.guardian?.name ?? "Guardian"} immediately via SMS if a fake bank link or APK malware is received.',
                      value: _notifyHighThreats,
                      onChanged: (v) => setState(() => _notifyHighThreats = v),
                    ),
                    _permTile(
                      title: 'Emergency SOS Broadcasts',
                      subtitle: 'Transmit GPS location & emergency SMS when you press the 1-tap SOS panic button.',
                      value: _notifySosCalls,
                      onChanged: (v) => setState(() => _notifySosCalls = v),
                    ),
                    _permTile(
                      title: 'High-Value Spending Alert (>₹15,000)',
                      subtitle: 'Send a notification if an outgoing transaction exceeds your preset limit.',
                      value: _allowSpendingAlerts,
                      onChanged: (v) => setState(() => _allowSpendingAlerts = v),
                    ),
                    _permTile(
                      title: 'Weekly Protection Digest',
                      subtitle: 'Deliver summary emails with safety milestones and quizzes completed.',
                      value: _notifyDailyHealth,
                      onChanged: (v) => setState(() => _notifyDailyHealth = v),
                    ),
                    const SizedBox(height: 32),

                    // Save Changes CTA
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '✅ Permissions updated for ${widget.guardian?.name ?? "Guardian"}',
                                style: GoogleFonts.atkinsonHyperlegible(color: Colors.white),
                              ),
                              backgroundColor: AppTheme.primaryTeal,
                            ),
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          'Save Guardian Permissions',
                          style: GoogleFonts.atkinsonHyperlegible(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _permTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3E2E2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.atkinsonHyperlegible(
                    fontSize: 13.5,
                    color: AppTheme.textLight,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppTheme.primaryTeal,
            activeTrackColor: const Color(0xFF93F2F2),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
