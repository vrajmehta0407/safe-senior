import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import 'admin_logs_screen.dart';
import 'admin_network_screen.dart';
import 'admin_rules_screen.dart';
import 'admin_dashboard_screen.dart';

class AdminScamReportsScreen extends StatelessWidget {
  const AdminScamReportsScreen({super.key});

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
                          'Guardian Network v1.0.4',
                          style: GoogleFonts.atkinsonHyperlegible(fontSize: 10, color: const Color(0xFF6B7B78)),
                        ),
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
                            'Scam Reports Pipeline',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Active triage and resolution board.',
                            style: GoogleFonts.atkinsonHyperlegible(fontSize: 14, color: const Color(0xFF5E706D)),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add, size: 16),
                        label: Text('MANUAL ENTRY', style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
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

                  // 3-Column Kanban Board Layout
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Column 1: NEW REPORTS
                      Expanded(
                        child: _buildKanbanColumn(
                          title: 'NEW REPORTS',
                          count: '12',
                          dotColor: AppTheme.terracottaRed,
                          cards: [
                            _buildKanbanCard(
                              tag: 'PHISHING SMS',
                              tagColor: const Color(0xFFFBE0D8),
                              tagTextColor: AppTheme.terracottaRed,
                              time: '10m ago',
                              title: 'Dadaji\'s Mobile',
                              desc: 'Received suspicious text claiming a parcel is detained at Delhi Airport from "India Post"...',
                              hasAlertIcon: true,
                            ),
                            const SizedBox(height: 16),
                            _buildKanbanCard(
                              tag: 'UNKNOWN CALLER',
                              tagColor: const Color(0xFFFBE0D8),
                              tagTextColor: AppTheme.terracottaRed,
                              time: '45m ago',
                              title: 'Shanti Patel\'s Phone',
                              desc: 'Repeated spoofed calls from CBI Customs asking for immediate RTGS transfer.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Column 2: REVIEWING
                      Expanded(
                        child: _buildKanbanColumn(
                          title: 'REVIEWING',
                          count: '5',
                          dotColor: const Color(0xFFD8572A),
                          cards: [
                            _buildKanbanCard(
                              tag: 'EMAIL SCAM',
                              tagColor: const Color(0xFFFDE8DF),
                              tagTextColor: const Color(0xFFD8572A),
                              time: '',
                              statusBadge: 'Active Review',
                              title: 'Harish Verma\'s Device',
                              desc: 'Fake Antivirus / MSEDCL electricity invoice for ₹24,999 with malicious APK download...',
                              attachmentCount: '1 File',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Column 3: RESOLVED
                      Expanded(
                        child: _buildKanbanColumn(
                          title: 'RESOLVED',
                          count: '2',
                          dotColor: const Color(0xFF4DB6AC),
                          cards: [
                            _buildKanbanCard(
                              tag: 'BLOCKED NUMBER',
                              tagColor: const Color(0xFFD7EFE6),
                              tagTextColor: const Color(0xFF1E7558),
                              time: 'Yesterday',
                              title: 'SBI YONO Phishing Call (+91 11 2309 XXXX)',
                              desc: '',
                              isStrikethrough: true,
                            ),
                          ],
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

  Widget _buildKanbanColumn({
    required String title,
    required String count,
    required Color dotColor,
    required List<Widget> cards,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7F5),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 4, backgroundColor: dotColor),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF2C3937), letterSpacing: 0.8),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFE2EFEA), borderRadius: BorderRadius.circular(10)),
                child: Text(count, style: GoogleFonts.atkinsonHyperlegible(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...cards,
        ],
      ),
    );
  }

  Widget _buildKanbanCard({
    required String tag,
    required Color tagColor,
    required Color tagTextColor,
    required String time,
    String? statusBadge,
    required String title,
    required String desc,
    bool hasAlertIcon = false,
    String? attachmentCount,
    bool isStrikethrough = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: tagColor, borderRadius: BorderRadius.circular(12)),
                child: Text(tag, style: GoogleFonts.atkinsonHyperlegible(fontSize: 10, fontWeight: FontWeight.bold, color: tagTextColor)),
              ),
              if (time.isNotEmpty)
                Text(time, style: GoogleFonts.atkinsonHyperlegible(fontSize: 11, color: const Color(0xFF6B7B78)))
              else if (statusBadge != null)
                Text(statusBadge, style: GoogleFonts.atkinsonHyperlegible(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.terracottaRed)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.atkinsonHyperlegible(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isStrikethrough ? const Color(0xFFA2B0AD) : const Color(0xFF2C3937),
              decoration: isStrikethrough ? TextDecoration.lineThrough : null,
            ),
          ),
          if (desc.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              desc,
              style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, color: const Color(0xFF4E5D5A), height: 1.4),
            ),
          ],
          if (hasAlertIcon || attachmentCount != null) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (attachmentCount != null)
                  Row(
                    children: [
                      const Icon(Icons.attach_file, size: 14, color: Color(0xFF6B7B78)),
                      const SizedBox(width: 4),
                      Text(attachmentCount, style: GoogleFonts.atkinsonHyperlegible(fontSize: 11, color: const Color(0xFF6B7B78))),
                    ],
                  )
                else
                  const SizedBox(),
                if (hasAlertIcon)
                  const Text('!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.terracottaRed)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
