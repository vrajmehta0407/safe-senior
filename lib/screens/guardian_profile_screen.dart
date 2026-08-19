import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'guardian_permissions_screen.dart';
import 'activity_feed_screen.dart';

class GuardianProfileScreen extends StatefulWidget {
  final String name;
  final String phone;
  final String relation;
  final bool isPrimary;

  const GuardianProfileScreen({
    super.key,
    required this.name,
    required this.phone,
    this.relation = 'Family Member',
    this.isPrimary = false,
  });

  @override
  State<GuardianProfileScreen> createState() => _GuardianProfileScreenState();
}

class _GuardianProfileScreenState extends State<GuardianProfileScreen> {
  bool _alertsEnabled = true;
  bool _locationEnabled = true;
  bool _callEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.primaryTeal,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              ),
            ),
            actions: [
              IconButton(
                onPressed: _showRemoveDialog,
                icon: const Icon(Icons.more_vert, color: Colors.white),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryTeal, Color(0xFF004D4D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
                      ),
                      child: Center(
                        child: Text(
                          widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.relation,
                          style: GoogleFonts.atkinsonHyperlegible(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                        if (widget.isPrimary) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.celebrationGold,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              '⭐ Primary',
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Quick actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      Icons.call,
                      'Call',
                      AppTheme.primaryTeal,
                      () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      Icons.message_outlined,
                      'Message',
                      AppTheme.celebrationGold,
                      () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      Icons.video_call_outlined,
                      'Video',
                      const Color(0xFF6A1B9A),
                      () {},
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contact info
          SliverToBoxAdapter(
            child: _buildSection(
              title: 'Contact Info',
              child: Column(
                children: [
                  _buildInfoRow(Icons.phone_outlined, 'Phone', widget.phone),
                  const Divider(height: 1),
                  _buildInfoRow(Icons.people_outlined, 'Relation', widget.relation),
                  const Divider(height: 1),
                  _buildInfoRow(Icons.calendar_today_outlined, 'Added', 'June 12, 2026'),
                ],
              ),
            ),
          ),

          // Protection settings
          SliverToBoxAdapter(
            child: _buildSection(
              title: 'Alert Permissions',
              trailing: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GuardianPermissionsScreen()),
                ),
                child: Text(
                  'Manage All',
                  style: GoogleFonts.atkinsonHyperlegible(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryTeal,
                  ),
                ),
              ),
              child: Column(
                children: [
                  _buildToggleRow(
                    Icons.notifications_outlined,
                    'Scam & Fraud Alerts',
                    'Notify when suspicious activity detected',
                    _alertsEnabled,
                    (v) => setState(() => _alertsEnabled = v),
                  ),
                  const Divider(height: 1),
                  _buildToggleRow(
                    Icons.location_on_outlined,
                    'Location Sharing',
                    'Share location in emergencies',
                    _locationEnabled,
                    (v) => setState(() => _locationEnabled = v),
                  ),
                  const Divider(height: 1),
                  _buildToggleRow(
                    Icons.call_outlined,
                    'Call Alerts',
                    'Notify about suspicious incoming calls',
                    _callEnabled,
                    (v) => setState(() => _callEnabled = v),
                  ),
                ],
              ),
            ),
          ),

          // Recent activity
          SliverToBoxAdapter(
            child: _buildSection(
              title: 'Recent Activity',
              trailing: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ActivityFeedScreen()),
                ),
                child: Text(
                  'View All',
                  style: GoogleFonts.atkinsonHyperlegible(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryTeal,
                  ),
                ),
              ),
              child: Column(
                children: [
                  _buildActivityRow('Received scam alert', 'Today, 2:30 PM', Icons.notifications, AppTheme.dangerRed),
                  const Divider(height: 1),
                  _buildActivityRow('Confirmed your safety', 'Yesterday, 8:15 AM', Icons.check_circle, AppTheme.primaryTeal),
                  const Divider(height: 1),
                  _buildActivityRow('Called you', '2 days ago', Icons.call, AppTheme.celebrationGold),
                ],
              ),
            ),
          ),

          // Remove guardian
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: OutlinedButton.icon(
                onPressed: _showRemoveDialog,
                icon: const Icon(Icons.person_remove_outlined, color: AppTheme.dangerRed, size: 18),
                label: Text(
                  'Remove Guardian',
                  style: GoogleFonts.atkinsonHyperlegible(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.dangerRed,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.dangerRed),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
              child: Row(
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                  if (trailing != null) trailing,
                ],
              ),
            ),
            const Divider(height: 1),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.atkinsonHyperlegible(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryTeal),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.atkinsonHyperlegible(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.atkinsonHyperlegible(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppTheme.primaryTeal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.atkinsonHyperlegible(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                Text(subtitle, style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryTeal,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(String title, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: GoogleFonts.atkinsonHyperlegible(fontSize: 14, color: AppTheme.textPrimary)),
          ),
          Text(time, style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  void _showRemoveDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Remove Guardian?', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700)),
        content: Text(
          '${widget.name} will no longer receive alerts or be able to monitor your safety.',
          style: GoogleFonts.atkinsonHyperlegible(fontSize: 15, color: AppTheme.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.atkinsonHyperlegible(fontSize: 15, color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('Remove', style: GoogleFonts.atkinsonHyperlegible(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.dangerRed)),
          ),
        ],
      ),
    );
  }
}
