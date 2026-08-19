import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import 'admin_network_screen.dart';
import 'admin_rules_screen.dart';
import 'admin_dashboard_screen.dart';

class AdminLogsScreen extends StatelessWidget {
  const AdminLogsScreen({super.key});

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
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150'),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Portal',
                          style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF2C3937)),
                        ),
                        Text(
                          'Guardian Network',
                          style: GoogleFonts.atkinsonHyperlegible(fontSize: 11, color: const Color(0xFF6B7B78)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'v1.0.4',
                  style: GoogleFonts.atkinsonHyperlegible(fontSize: 10, color: const Color(0xFFA2B0AD)),
                ),
                const SizedBox(height: 12),
                Text(
                  'SafeSenior',
                  style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                ),
                const SizedBox(height: 36),

                // Nav Links
                _buildNavItem(context, icon: Icons.grid_view, label: 'Dashboard', onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
                }),
                _buildNavItem(context, icon: Icons.hub_outlined, label: 'Family Network', onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminNetworkScreen()));
                }),
                _buildNavItem(context, icon: Icons.shield_outlined, label: 'Security Logs', isActive: true),
                _buildNavItem(context, icon: Icons.warning_amber_rounded, label: 'Scam Alerts', onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminRulesScreen()));
                }),
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
                            'Security Logs',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Real-time monitoring and threat assessment.',
                            style: GoogleFonts.atkinsonHyperlegible(fontSize: 14, color: const Color(0xFF5E706D)),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download, size: 16),
                        label: Text('Export Report', style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, fontWeight: FontWeight.bold)),
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

                  // Top Metric Cards Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Total Scans',
                          value: '142.8K',
                          sub: '↗ +12% from yesterday',
                          icon: Icons.radar,
                          iconColor: AppTheme.primaryTeal,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Threats Blocked',
                          value: '482',
                          valueColor: AppTheme.terracottaRed,
                          sub: '! Requires review',
                          subColor: AppTheme.terracottaRed,
                          icon: Icons.shield_outlined,
                          iconColor: AppTheme.terracottaRed,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Active Alerts',
                          value: '14',
                          valueColor: const Color(0xFFC85A32),
                          sub: '↘ -3 from last hour',
                          icon: Icons.notifications_none,
                          iconColor: const Color(0xFFC85A32),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Data Table Container: Recent Activity
                  Container(
                    width: double.infinity,
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
                            Text(
                              'Recent Activity',
                              style: GoogleFonts.atkinsonHyperlegible(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2C3937)),
                            ),
                            Row(
                              children: const [
                                Icon(Icons.filter_list, color: Color(0xFF6B7B78), size: 20),
                                SizedBox(width: 14),
                                Icon(Icons.more_vert, color: Color(0xFF6B7B78), size: 20),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Table Header
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Expanded(flex: 2, child: _buildColHeader('Timestamp')),
                              Expanded(flex: 3, child: _buildColHeader('Event Source')),
                              Expanded(flex: 3, child: _buildColHeader('Type')),
                              Expanded(flex: 2, child: _buildColHeader('Status')),
                              Expanded(flex: 1, child: _buildColHeader('Action')),
                            ],
                          ),
                        ),
                        const Divider(color: Color(0xFFEEF3EE)),

                        // Row 1
                        _buildTableRow('Oct 24, 14:32:01', 'Grandma\'s iPad', Icons.tablet_mac, 'Phishing Attempt', 'Blocked', Colors.red),
                        // Row 2
                        _buildTableRow('Oct 24, 12:15:44', 'Home Network', Icons.router, 'Firmware Update', 'Success', AppTheme.primaryTeal),
                        // Row 3
                        _buildTableRow('Oct 24, 09:05:12', 'Dad\'s Account', Icons.person_outline, 'Unusual Login Location', 'Investigating', Colors.orange),
                        // Row 4
                        _buildTableRow('Oct 23, 22:40:00', 'System Core', Icons.shield, 'Daily Scan Complete', 'Success', AppTheme.primaryTeal),

                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            'Load More Logs',
                            style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildMetricCard({
    required String title,
    required String value,
    Color? valueColor,
    required String sub,
    Color? subColor,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
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
              Text(
                title.toUpperCase(),
                style: GoogleFonts.atkinsonHyperlegible(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF6B7B78), letterSpacing: 0.8),
              ),
              Icon(icon, color: iconColor, size: 20),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppTheme.primaryTeal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sub,
            style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, fontWeight: FontWeight.w600, color: subColor ?? const Color(0xFF4E5D5A)),
          ),
        ],
      ),
    );
  }

  Widget _buildColHeader(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.atkinsonHyperlegible(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF6B7B78), letterSpacing: 0.5),
    );
  }

  Widget _buildTableRow(String time, String source, IconData srcIcon, String type, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(time, style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, color: const Color(0xFF4E5D5A))),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(color: Color(0xFFEFF5F3), shape: BoxShape.circle),
                  child: Icon(srcIcon, size: 14, color: AppTheme.primaryTeal),
                ),
                const SizedBox(width: 10),
                Text(source, style: GoogleFonts.atkinsonHyperlegible(fontSize: 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF2C3937))),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(type, style: GoogleFonts.atkinsonHyperlegible(fontSize: 13.5, color: const Color(0xFF2C3937))),
          ),
          Expanded(
            flex: 2,
            child: UnconstrainedBox(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(radius: 3, backgroundColor: Colors.white),
                    const SizedBox(width: 6),
                    Text(status, style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: const Icon(Icons.more_vert, size: 18, color: Color(0xFFA2B0AD)),
          ),
        ],
      ),
    );
  }
}
