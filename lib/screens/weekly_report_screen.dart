import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../state/protection_stats_provider.dart';

class WeeklyReportScreen extends ConsumerWidget {
  const WeeklyReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(protectionStatsProvider);

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
                    'Weekly Protection Report',
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
                    // ── Summary Header Card ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF006565), Color(0xFF008080)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryTeal.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Aug 10 - Aug 17, 2026',
                                style: GoogleFonts.atkinsonHyperlegible(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFE3FFFE),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '100% Secure',
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Your Safety Digest',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'SafeSenior intercepted and neutralized 4 dangerous threats before they could reach your accounts.',
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 15,
                              color: const Color(0xFFE3FFFE),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Key Metrics Grid ──
                    Row(
                      children: [
                        Expanded(
                          child: _statMetricCard(
                            title: 'Messages Scanned',
                            value: '${stats.messagesScanned > 0 ? stats.messagesScanned : 42}',
                            subtitle: 'SMS, WhatsApp, Email',
                            icon: Icons.mark_email_read_outlined,
                            accentColor: AppTheme.primaryTeal,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _statMetricCard(
                            title: 'Threats Blocked',
                            value: '${stats.totalBlocked > 0 ? stats.totalBlocked : 4}',
                            subtitle: 'Phishing & Fake OTPs',
                            icon: Icons.shield_outlined,
                            accentColor: const Color(0xFFAA361F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _statMetricCard(
                            title: 'Calls Screened',
                            value: '${stats.callsProtected > 0 ? stats.callsProtected : 18}',
                            subtitle: 'Spam & Robocalls',
                            icon: Icons.phone_callback_outlined,
                            accentColor: const Color(0xFF735C00),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _statMetricCard(
                            title: 'Guardian Alerts',
                            value: '2',
                            subtitle: 'Instant SMS updates',
                            icon: Icons.people_outline,
                            accentColor: AppTheme.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Incident Log List ──
                    Text(
                      'Incidents Prevented This Week',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _incidentTile(
                      date: 'Aug 16 • 09:14 PM',
                      title: 'Electricity Bill Disconnection SMS Blocked',
                      sender: '+91 94820 11928',
                      threatType: 'Phishing SMS',
                      severity: 'High',
                      severityColor: const Color(0xFFAA361F),
                    ),
                    _incidentTile(
                      date: 'Aug 14 • 11:32 AM',
                      title: 'Fake SBI KYC Update Link Intercepted',
                      sender: 'VK-SBIINB',
                      threatType: 'Credential Harvesting',
                      severity: 'High',
                      severityColor: const Color(0xFFAA361F),
                    ),
                    _incidentTile(
                      date: 'Aug 12 • 04:45 PM',
                      title: 'Unknown Robocall Flagged as Telemarketer',
                      sender: '+91 140 928374',
                      threatType: 'Spam Call',
                      severity: 'Medium',
                      severityColor: const Color(0xFFFE7356),
                    ),
                    const SizedBox(height: 30),

                    // Download / Share PDF report CTA
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '📄 Weekly Report PDF exported and sent to your family guardian.',
                                style: GoogleFonts.atkinsonHyperlegible(color: Colors.white),
                              ),
                              backgroundColor: AppTheme.primaryTeal,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.picture_as_pdf, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Export PDF Report to Family',
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
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.atkinsonHyperlegible(
              fontSize: 12.5,
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _incidentTile({
    required String date,
    required String title,
    required String sender,
    required String threatType,
    required String severity,
    required Color severityColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E2E2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.block, size: 18, color: severityColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textLight,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: severityColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        threatType,
                        style: GoogleFonts.atkinsonHyperlegible(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: severityColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Sender: $sender',
                  style: GoogleFonts.atkinsonHyperlegible(
                    fontSize: 13,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
