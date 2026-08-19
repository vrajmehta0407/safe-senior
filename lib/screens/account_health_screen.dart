import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'guardian_contacts_screen.dart';

class AccountHealthScreen extends StatefulWidget {
  const AccountHealthScreen({super.key});

  @override
  State<AccountHealthScreen> createState() => _AccountHealthScreenState();
}

class _AccountHealthScreenState extends State<AccountHealthScreen> {
  bool _biometricEnabled = true;
  bool _smsMonitoringEnabled = true;
  bool _callScreeningEnabled = true;
  bool _spendingLimitEnabled = true;
  double _dailySpendingLimit = 15000;

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
                    'Account Security Health',
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
                    // ── Security Health Score Radial ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE3E2E2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFE0F2F2),
                            ),
                            child: Center(
                              child: Text(
                                '96%',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryTeal,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Excellent Protection',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '4 of 4 critical defenses are active and healthy.',
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 14.5,
                                    color: AppTheme.textLight,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Protection Layers Checklist ──
                    Text(
                      'Core Protective Layers',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _layerSwitchTile(
                      title: 'Biometric App Authentication',
                      subtitle: 'Require fingerprint/PIN before modifying security settings.',
                      icon: Icons.fingerprint,
                      value: _biometricEnabled,
                      onChanged: (v) => setState(() => _biometricEnabled = v),
                    ),
                    _layerSwitchTile(
                      title: 'Real-Time SMS & OTP Monitoring',
                      subtitle: 'Intercepts incoming malicious text messages automatically.',
                      icon: Icons.mark_email_unread_outlined,
                      value: _smsMonitoringEnabled,
                      onChanged: (v) => setState(() => _smsMonitoringEnabled = v),
                    ),
                    _layerSwitchTile(
                      title: 'Spam & Robocall Filtering',
                      subtitle: 'Blocks numbers reported for telecom financial fraud.',
                      icon: Icons.phone_disabled_outlined,
                      value: _callScreeningEnabled,
                      onChanged: (v) => setState(() => _callScreeningEnabled = v),
                    ),
                    const SizedBox(height: 24),

                    // ── Financial Spending Limit Controls ──
                    Text(
                      'Financial Safety Safeguards',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE0F2F2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.account_balance_wallet, color: AppTheme.primaryTeal, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Daily High-Value Warning',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _spendingLimitEnabled,
                                activeThumbColor: AppTheme.primaryTeal,
                                activeTrackColor: const Color(0xFF93F2F2),
                                onChanged: (v) => setState(() => _spendingLimitEnabled = v),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'If a single UPI or bank transfer exceeds this threshold, your primary guardian receives an instant courtesy notification.',
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 14,
                              color: AppTheme.textLight,
                              height: 1.4,
                            ),
                          ),
                          if (_spendingLimitEnabled) ...[
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Alert Threshold:',
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                Text(
                                  '₹${_dailySpendingLimit.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primaryTeal,
                                  ),
                                ),
                              ],
                            ),
                            Slider(
                              value: _dailySpendingLimit,
                              min: 5000,
                              max: 50000,
                              divisions: 9,
                              activeColor: AppTheme.primaryTeal,
                              inactiveColor: const Color(0xFFE3E2E2),
                              onChanged: (val) => setState(() => _dailySpendingLimit = val),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Family Guardian Status Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2F2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.people, color: AppTheme.primaryTeal, size: 28),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Family Guardian Connected',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryTeal,
                                  ),
                                ),
                                Text(
                                  'Amit Patel is linked as your primary emergency backup.',
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 13.5,
                                    color: AppTheme.primaryTeal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward, color: AppTheme.primaryTeal),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const GuardianContactsScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _layerSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value ? const Color(0xFFE0F2F2) : const Color(0xFFF5F3F3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: value ? AppTheme.primaryTeal : AppTheme.textLight, size: 22),
          ),
          const SizedBox(width: 14),
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
