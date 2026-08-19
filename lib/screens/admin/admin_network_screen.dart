import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import 'admin_logs_screen.dart';
import 'admin_rules_screen.dart';
import 'admin_dashboard_screen.dart';

class AdminNetworkScreen extends StatelessWidget {
  const AdminNetworkScreen({super.key});

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
                Text(
                  'Admin Portal',
                  style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, color: const Color(0xFF6B7B78)),
                ),
                const SizedBox(height: 36),

                // Nav Links
                _buildNavItem(context, icon: Icons.grid_view, label: 'Dashboard', onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
                }),
                _buildNavItem(context, icon: Icons.hub_outlined, label: 'Family Network', isActive: true),
                _buildNavItem(context, icon: Icons.shield_outlined, label: 'Security Logs', onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminLogsScreen()));
                }),
                _buildNavItem(context, icon: Icons.warning_amber_rounded, label: 'Scam Alerts', onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminRulesScreen()));
                }),
                _buildNavItem(context, icon: Icons.bolt_outlined, label: 'System Health'),

                const Spacer(),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150'),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Admin Controller', style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF2C3937))),
                        Text('v1.0.4', style: GoogleFonts.atkinsonHyperlegible(fontSize: 10, color: const Color(0xFFA2B0AD))),
                      ],
                    ),
                  ],
                ),
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
                            'Guardian Network',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Active command overview of registered protective agents, oversight relationships, and real-time posture.',
                            style: GoogleFonts.atkinsonHyperlegible(fontSize: 14, color: const Color(0xFF5E706D)),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add, size: 16),
                        label: Text('Register Guardian', style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, fontWeight: FontWeight.bold)),
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

                  // Topology Graph & Metrics Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Topology Graph Container (Left 2/3)
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 300,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F5F3),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: const Color(0xFFE2EFEA)),
                          ),
                          child: Stack(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Sanctuary Mesh Topology', style: GoogleFonts.atkinsonHyperlegible(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                                      Text('Real-time relationship mapping', style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, color: const Color(0xFF6B7B78))),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                    child: Row(
                                      children: [
                                        const CircleAvatar(radius: 4, backgroundColor: AppTheme.primaryTeal),
                                        const SizedBox(width: 6),
                                        Text('Live', style: GoogleFonts.atkinsonHyperlegible(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // Centered Orbital Nodes
                              Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 54,
                                      height: 54,
                                      decoration: BoxDecoration(color: const Color(0xFFC7E5DC), shape: BoxShape.circle, border: Border.all(color: AppTheme.primaryTeal, width: 2)),
                                      child: const Icon(Icons.home, color: AppTheme.primaryTeal, size: 26),
                                    ),
                                    Positioned(
                                      left: 20,
                                      top: 20,
                                      child: const CircleAvatar(radius: 18, backgroundImage: NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150')),
                                    ),
                                    Positioned(
                                      left: 50,
                                      bottom: 20,
                                      child: const CircleAvatar(radius: 18, backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150')),
                                    ),
                                    Positioned(
                                      right: 30,
                                      top: 40,
                                      child: Container(width: 32, height: 32, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.devices, color: AppTheme.primaryTeal, size: 16)),
                                    ),
                                    Positioned(
                                      right: 10,
                                      bottom: 30,
                                      child: Container(width: 32, height: 32, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.local_hospital, color: AppTheme.terracottaRed, size: 16)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Metric Stack Column (Right 1/3)
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.shield_outlined, color: AppTheme.primaryTeal, size: 18),
                                      const SizedBox(width: 8),
                                      Text('Active Guardians', style: GoogleFonts.atkinsonHyperlegible(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF6B7B78))),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text('12', style: GoogleFonts.plusJakartaSans(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                                  const SizedBox(height: 4),
                                  Text('↗ 2 added this week', style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.terracottaRed)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.verified_user_outlined, color: AppTheme.primaryTeal, size: 18),
                                      const SizedBox(width: 8),
                                      Text('Oversight Coverage', style: GoogleFonts.atkinsonHyperlegible(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF6B7B78))),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text('98%', style: GoogleFonts.plusJakartaSans(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                                  const SizedBox(height: 10),
                                  LinearProgressIndicator(value: 0.98, color: AppTheme.primaryTeal, backgroundColor: const Color(0xFFEEF3EE), minHeight: 4),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Guardian Roster Data Table Container
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
                        Text('Guardian Roster', style: GoogleFonts.atkinsonHyperlegible(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2C3937))),
                        const SizedBox(height: 20),

                        // Header Row
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Expanded(flex: 3, child: _buildColHeader('Identity')),
                              Expanded(flex: 2, child: _buildColHeader('Role Designation')),
                              Expanded(flex: 2, child: _buildColHeader('Status / Posture')),
                              Expanded(flex: 2, child: _buildColHeader('Last Contact')),
                              Expanded(flex: 1, child: _buildColHeader('Actions')),
                            ],
                          ),
                        ),
                        const Divider(color: Color(0xFFEEF3EE)),

                        // Row 1
                        _buildRosterRow(
                          name: 'Marcus Thorne',
                          id: 'GA-8842',
                          img: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
                          role: 'Primary Responder',
                          status: 'Vigilant',
                          statusColor: AppTheme.primaryTeal,
                          lastContact: '2 mins ago',
                        ),
                        // Row 2
                        _buildRosterRow(
                          name: 'Dr. Sarah Vance',
                          id: 'GA-3319',
                          img: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
                          role: 'Medical Proxy',
                          status: 'Review Needed',
                          statusColor: AppTheme.terracottaRed,
                          lastContact: '14 hours ago',
                          isHighlight: true,
                        ),
                        // Row 3
                        _buildRosterRow(
                          name: 'Automated Sentinel',
                          id: 'SYS-001',
                          icon: Icons.smart_toy_outlined,
                          role: 'System Monitor',
                          status: 'Active',
                          statusColor: AppTheme.primaryTeal,
                          lastContact: 'Real-time',
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

  Widget _buildColHeader(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.atkinsonHyperlegible(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF6B7B78), letterSpacing: 0.5),
    );
  }

  Widget _buildRosterRow({
    required String name,
    required String id,
    String? img,
    IconData? icon,
    required String role,
    required String status,
    required Color statusColor,
    required String lastContact,
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFFFDF4F2) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                if (img != null)
                  CircleAvatar(radius: 18, backgroundImage: NetworkImage(img))
                else
                  Container(width: 36, height: 36, decoration: const BoxDecoration(color: Color(0xFFE5EEEC), shape: BoxShape.circle), child: Icon(icon ?? Icons.person, size: 18, color: AppTheme.primaryTeal)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: GoogleFonts.atkinsonHyperlegible(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF2C3937))),
                    Text('ID: $id', style: GoogleFonts.atkinsonHyperlegible(fontSize: 11, color: const Color(0xFF6B7B78))),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: UnconstrainedBox(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFEFF3F2), borderRadius: BorderRadius.circular(16)),
                child: Text(role, style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, color: const Color(0xFF4E5D5A))),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(radius: 3.5, backgroundColor: statusColor),
                const SizedBox(width: 8),
                Text(status, style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, fontWeight: FontWeight.bold, color: statusColor)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(lastContact, style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, color: const Color(0xFF4E5D5A))),
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
