import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import 'admin_logs_screen.dart';
import 'admin_network_screen.dart';
import 'admin_rules_screen.dart';
import 'admin_scam_reports_screen.dart';
import 'admin_dashboard_screen.dart';

class AdminAuditLogScreen extends StatelessWidget {
  const AdminAuditLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Top Header Navigation Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            color: Colors.white,
            child: Row(
              children: [
                Text(
                  'security SafeSenior',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTeal,
                  ),
                ),
                const Spacer(),
                Text('Dashboard', style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF4E5D5A))),
                const SizedBox(width: 24),
                Text('Family Network', style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF4E5D5A))),
                const SizedBox(width: 24),
                Text('Security Logs', style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                const SizedBox(width: 24),
                Text('Scam Alerts', style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF4E5D5A))),
                const SizedBox(width: 24),
                const CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150'),
                ),
              ],
            ),
          ),

          Expanded(
            child: Row(
              children: [
                // Sidebar Navigation
                Container(
                  width: 220,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: AppTheme.primaryTeal,
                            child: Icon(Icons.shield, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Admin Portal', style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF2C3937))),
                              Text('v1.0.4', style: GoogleFonts.atkinsonHyperlegible(fontSize: 10, color: const Color(0xFFA2B0AD))),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      _buildNavItem(context, icon: Icons.grid_view, label: 'Dashboard', onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
                      }),
                      _buildNavItem(context, icon: Icons.hub_outlined, label: 'Family Network', onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminNetworkScreen()));
                      }),
                      _buildNavItem(context, icon: Icons.shield_outlined, label: 'Security Logs', isActive: true),
                      _buildNavItem(context, icon: Icons.warning_amber_rounded, label: 'Scam Alerts', onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminScamReportsScreen()));
                      }),
                      _buildNavItem(context, icon: Icons.bolt_outlined, label: 'System Health'),
                    ],
                  ),
                ),

                // Main Body Content (Audit Log Timeline)
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(36),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title & Top Filter Bar
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Audit Log',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 34,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryTeal,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'A glowing connected-timeline of administrative actions across the Guardian network.',
                                        style: GoogleFonts.atkinsonHyperlegible(fontSize: 14, color: const Color(0xFF5E706D)),
                                      ),
                                    ],
                                  ),

                                  // Filter Controls Box
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Admin', style: GoogleFonts.atkinsonHyperlegible(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF6B7B78))),
                                            Text('All Admins v', style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF2C3937))),
                                          ],
                                        ),
                                        const SizedBox(width: 20),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Action', style: GoogleFonts.atkinsonHyperlegible(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF6B7B78))),
                                            Text('All Actions v', style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF2C3937))),
                                          ],
                                        ),
                                        const SizedBox(width: 20),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Date Range', style: GoogleFonts.atkinsonHyperlegible(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF6B7B78))),
                                            Text('mm/dd/yyyy', style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, color: const Color(0xFF9EAEA8))),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),

                              // Central Connected Timeline
                              Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  // Central Glowing Vertical Line
                                  Positioned(
                                    top: 40,
                                    bottom: 40,
                                    child: Container(
                                      width: 2,
                                      color: const Color(0xFFC7DCD5),
                                    ),
                                  ),

                                  Column(
                                    children: [
                                      // Timeline Event 1 (Left Card)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildTimelineCard(
                                              icon: Icons.shield_outlined,
                                              iconBg: AppTheme.primaryTeal,
                                              title: 'Policy Updated',
                                              author: 'System Auto',
                                              time: '10:42 AM',
                                              desc: 'Automated scam-filter ruleset v2.1 applied across all monitored communication nodes.',
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          const CircleAvatar(radius: 6, backgroundColor: AppTheme.primaryTeal),
                                          const Expanded(child: SizedBox()),
                                        ],
                                      ),
                                      const SizedBox(height: 36),

                                      // Timeline Event 2 (Right Card)
                                      Row(
                                        children: [
                                          const Expanded(child: SizedBox()),
                                          const CircleAvatar(radius: 6, backgroundColor: AppTheme.terracottaRed),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: _buildTimelineCard(
                                              icon: Icons.shield_outlined,
                                              iconBg: AppTheme.terracottaRed,
                                              title: 'Threat Blocked',
                                              author: 'Guardian Core',
                                              time: '09:15 AM',
                                              desc: 'Intercepted known phishing pattern from unrecognized number attempting contact.',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 36),

                                      // Timeline Event 3 (Left Card)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildTimelineCard(
                                              icon: Icons.person_outline,
                                              iconBg: const Color(0xFF4E7869),
                                              title: 'Access Granted',
                                              author: 'Controller 1',
                                              time: 'Yesterday',
                                              desc: 'Approved temporary location viewing access for \'Family Member B\' for 24 hours.',
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          const CircleAvatar(radius: 6, backgroundColor: AppTheme.primaryTeal),
                                          const Expanded(child: SizedBox()),
                                        ],
                                      ),
                                      const SizedBox(height: 40),

                                      // Load Earlier Logs Button
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE5EEEC),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.keyboard_arrow_down, size: 18, color: AppTheme.primaryTeal),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Load Earlier Logs',
                                              style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Footer Bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                        color: const Color(0xFFE0E7E4),
                        child: Row(
                          children: [
                            Text('SafeSenior', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                            const Spacer(),
                            Text('© 2024 SafeSenior. Secure Sanctuary.', style: GoogleFonts.atkinsonHyperlegible(fontSize: 11, color: const Color(0xFF6B7B78))),
                            const SizedBox(width: 24),
                            Text('Privacy Shield    Terms of Protection', style: GoogleFonts.atkinsonHyperlegible(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF4E5D5A))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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

  Widget _buildTimelineCard({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String author,
    required String time,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
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
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.atkinsonHyperlegible(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF2C3937))),
                  Text(author, style: GoogleFonts.atkinsonHyperlegible(fontSize: 11, color: const Color(0xFF6B7B78))),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFEFF5F3), borderRadius: BorderRadius.circular(10)),
                child: Text(time, style: GoogleFonts.atkinsonHyperlegible(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(desc, style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, color: const Color(0xFF4E5D5A), height: 1.4)),
        ],
      ),
    );
  }
}
