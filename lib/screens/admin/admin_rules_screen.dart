import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import 'admin_logs_screen.dart';
import 'admin_network_screen.dart';
import 'admin_dashboard_screen.dart';

class AdminRulesScreen extends StatelessWidget {
  const AdminRulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Row(
        children: [
          // Sidebar Navigation
          Container(
            width: 240,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SafeSenior',
                  style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.primaryTeal,
                      child: Icon(Icons.person, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Admin Portal', style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF2C3937))),
                        Text('Guardian Network', style: GoogleFonts.atkinsonHyperlegible(fontSize: 10, color: const Color(0xFF6B7B78))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // Nav Links
                _buildNavItem(context, icon: Icons.grid_view, label: 'Dashboard', onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
                }),
                _buildNavItem(context, icon: Icons.hub_outlined, label: 'Family Network', onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminNetworkScreen()));
                }),
                _buildNavItem(context, icon: Icons.shield_outlined, label: 'Security Logs', onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminLogsScreen()));
                }),
                _buildNavItem(context, icon: Icons.warning_amber_rounded, label: 'Scam Alerts', isActive: true),
                _buildNavItem(context, icon: Icons.bolt_outlined, label: 'System Health'),
              ],
            ),
          ),

          // Main Body Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Header Title Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detection Rules',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage heuristic patterns and machine learning thresholds for anomaly detection across the sanctuary network.',
                            style: GoogleFonts.atkinsonHyperlegible(fontSize: 14, color: const Color(0xFF5E706D)),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add, size: 16),
                        label: Text('NEW RULE', style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Filter & Search Bar Container
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
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
                        const Icon(Icons.tune, color: Color(0xFF6B7B78), size: 18),
                        const SizedBox(width: 10),
                        Text('Filter:', style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF6B7B78))),
                        const SizedBox(width: 14),

                        _buildFilterChip('All', isSelected: true),
                        const SizedBox(width: 8),
                        _buildFilterChip('High Risk'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Network'),

                        const Spacer(),

                        Container(
                          width: 240,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF7F5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search rules...',
                              hintStyle: GoogleFonts.atkinsonHyperlegible(color: const Color(0xFF9EAEA8), fontSize: 13),
                              icon: const Icon(Icons.search, color: Color(0xFF9EAEA8), size: 18),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 2x2 Grid of Detection Rule Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildRuleCard(
                          icon: Icons.cell_tower,
                          iconBg: const Color(0xFFFBE0D8),
                          iconColor: AppTheme.terracottaRed,
                          severity: 'CRITICAL',
                          severityColor: const Color(0xFFFBE0D8),
                          severityTextColor: AppTheme.terracottaRed,
                          title: 'Unauthorized Device Sync',
                          desc: 'Detects connection attempts from unrecognized MAC addresses attempting to pair with sanctuary IoT devices.',
                          status: 'Active',
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildRuleCard(
                          icon: Icons.account_balance_wallet_outlined,
                          iconBg: const Color(0xFFFDE8DF),
                          iconColor: const Color(0xFFD8572A),
                          severity: 'ELEVATED',
                          severityColor: const Color(0xFFFDE8DF),
                          severityTextColor: const Color(0xFFD8572A),
                          title: 'Anomalous Transfer Volume',
                          desc: 'Flags outbound network traffic exceeding standard baseline by 300% within a 5-minute window.',
                          status: 'Active',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _buildRuleCard(
                          icon: Icons.location_on_outlined,
                          iconBg: const Color(0xFFD7EFE6),
                          iconColor: AppTheme.primaryTeal,
                          severity: 'MONITOR',
                          severityColor: const Color(0xFFD7EFE6),
                          severityTextColor: const Color(0xFF1E7558),
                          title: 'Geofence Boundary Drift',
                          desc: 'Logs instances where tracked assets hover near the edge of established safe zones without crossing.',
                          status: 'Paused',
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildRuleCard(
                          icon: Icons.phishing,
                          iconBg: const Color(0xFFFBE0D8),
                          iconColor: AppTheme.terracottaRed,
                          severity: 'CRITICAL',
                          severityColor: const Color(0xFFFBE0D8),
                          severityTextColor: AppTheme.terracottaRed,
                          title: 'Social Engineering Patterns',
                          desc: 'NLP analysis on incoming text streams detecting urgency keywords coupled with financial requests.',
                          status: 'Active',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {required IconData icon, required String label, bool isActive = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEFF5F3) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isActive ? const Border(left: BorderSide(color: AppTheme.terracottaRed, width: 3)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? AppTheme.primaryTeal : const Color(0xFF6B7B78), size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.atkinsonHyperlegible(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? AppTheme.primaryTeal : const Color(0xFF4E5D5A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryTeal : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? AppTheme.primaryTeal : const Color(0xFFE2EFEA)),
      ),
      child: Text(
        label,
        style: GoogleFonts.atkinsonHyperlegible(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : const Color(0xFF4E5D5A),
        ),
      ),
    );
  }

  Widget _buildRuleCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String severity,
    required Color severityColor,
    required Color severityTextColor,
    required String title,
    required String desc,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: severityColor, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  severity,
                  style: GoogleFonts.atkinsonHyperlegible(fontSize: 10, fontWeight: FontWeight.bold, color: severityTextColor, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.atkinsonHyperlegible(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2C3937)),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: GoogleFonts.atkinsonHyperlegible(fontSize: 13.5, color: const Color(0xFF4E5D5A), height: 1.45),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 3.5, backgroundColor: status == 'Active' ? AppTheme.primaryTeal : const Color(0xFFA2B0AD)),
                  const SizedBox(width: 8),
                  Text(
                    status,
                    style: GoogleFonts.atkinsonHyperlegible(fontSize: 12.5, fontWeight: FontWeight.w600, color: const Color(0xFF4E5D5A)),
                  ),
                ],
              ),
              const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF6B7B78)),
            ],
          ),
        ],
      ),
    );
  }
}
