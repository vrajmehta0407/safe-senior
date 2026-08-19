// lib/screens/admin/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/admin_provider.dart';
import '../../services/admin_api_client.dart';
import '../../screens/login_screen.dart';
import 'admin_users_screen.dart';
import 'admin_scam_reports_screen.dart';
import 'admin_patterns_screen.dart';
import 'admin_audit_log_screen.dart';
import 'admin_guardians_screen.dart';

// ── Stat card widget ──────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2035),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Icon(Icons.trending_up,
                  size: 14, color: Colors.white.withValues(alpha: 0.3)),
            ],
          ),
          const SizedBox(height: 14),
          Text(value,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
        ],
      ),
    );
  }
}

// ── Mini bar chart ────────────────────────────────────────────────────────────
class _MiniBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data; // [{day, signups}]

  const _MiniBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No signup data',
            style: TextStyle(color: Colors.white38, fontSize: 13)),
      );
    }
    final maxVal =
        data.map((e) => (e['signups'] as num? ?? 0).toDouble()).reduce(
              (a, b) => a > b ? a : b,
            );

    return LayoutBuilder(builder: (ctx, constraints) {
      final barW = (constraints.maxWidth - (data.length - 1) * 4) / data.length;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((e) {
                final val = (e['signups'] as num? ?? 0).toDouble();
                final frac = maxVal == 0 ? 0.0 : val / maxVal;
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        width: barW.clamp(6.0, 32.0),
                        height: (frac * 80).clamp(4.0, 80.0),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4F8EF7), Color(0xFF7C4DFF)],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: data.map((e) {
              final day = (e['day'] as String? ?? '').replaceAll(
                  RegExp(r'^\d{4}-'), '');
              return SizedBox(
                width: (barW + 4).clamp(6.0, 36.0),
                child: Text(day,
                    style: const TextStyle(
                        fontSize: 9, color: Colors.white38),
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.center),
              );
            }).toList(),
          ),
        ],
      );
    });
  }
}

// ── Dashboard screen ──────────────────────────────────────────────────────────
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends ConsumerState<AdminDashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    final result = await ref.read(adminApiProvider).getStats();
    if (mounted) {
      setState(() {
        _stats = result?['stats'] as Map<String, dynamic>?;
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    ref.read(adminProvider.notifier).logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label,
      Widget screen) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70, size: 20),
      title:
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => screen));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(adminProvider);
    final signups = (_stats?['signupsLast30Days'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .take(14)
        .toList()
        .reversed
        .toList();

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0D14),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111521),
          elevation: 0,
        ),
      ),
      child: Scaffold(
        drawer: Drawer(
          backgroundColor: const Color(0xFF111521),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4F8EF7), Color(0xFF7C4DFF)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.admin_panel_settings,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(admin.adminName ?? 'Admin',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            Text(admin.adminRole ?? '',
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12),
                _navItem(context, Icons.people_outline, 'Users',
                    const AdminUsersScreen()),
                _navItem(context, Icons.shield_outlined, 'Scam Reports',
                    const AdminScamReportsScreen()),
                _navItem(context, Icons.security, 'Patterns',
                    const AdminPatternsScreen()),
                _navItem(context, Icons.family_restroom, 'Guardians',
                    const AdminGuardiansScreen()),
                _navItem(context, Icons.assignment_outlined, 'Audit Log',
                    const AdminAuditLogScreen()),
                const Spacer(),
                const Divider(color: Colors.white12),
                ListTile(
                  leading:
                      const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                  title: const Text('Sign Out',
                      style:
                          TextStyle(color: Colors.redAccent, fontSize: 14)),
                  onTap: _logout,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          title: const Text('Admin Dashboard',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_outlined),
              onPressed: _loadStats,
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Color(0xFF4F8EF7))))
            : RefreshIndicator(
                onRefresh: _loadStats,
                color: const Color(0xFF4F8EF7),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // ── Live badge ─────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Overview',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.green.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.circle,
                                  color: Colors.greenAccent, size: 8),
                              SizedBox(width: 6),
                              Text('Live',
                                  style: TextStyle(
                                      color: Colors.greenAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Stat cards grid ────────────────────────────────────
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        _StatCard(
                          label: 'Total Users',
                          value: '${_stats?['totalUsers'] ?? 0}',
                          icon: Icons.people_outline,
                          color: const Color(0xFF4F8EF7),
                        ),
                        _StatCard(
                          label: 'Active Users',
                          value: '${_stats?['activeUsers'] ?? 0}',
                          icon: Icons.person_outline,
                          color: Colors.greenAccent,
                        ),
                        _StatCard(
                          label: 'Scam Reports',
                          value: '${_stats?['totalScamReports'] ?? 0}',
                          icon: Icons.shield_outlined,
                          color: Colors.orangeAccent,
                        ),
                        _StatCard(
                          label: 'Guardians',
                          value: '${_stats?['totalGuardians'] ?? '—'}',
                          icon: Icons.family_restroom,
                          color: Colors.purpleAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Signup chart ───────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2035),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.07)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('User Signups — Last 14 Days',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                          const SizedBox(height: 16),
                          _MiniBarChart(data: signups),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Quick links ────────────────────────────────────────
                    const Text('Quick Access',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8)),
                    const SizedBox(height: 12),
                    _QuickLinkRow(children: [
                      _QuickLink(
                        label: 'Users',
                        icon: Icons.people_outline,
                        color: const Color(0xFF4F8EF7),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const AdminUsersScreen())),
                      ),
                      _QuickLink(
                        label: 'Reports',
                        icon: Icons.shield_outlined,
                        color: Colors.orangeAccent,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const AdminScamReportsScreen())),
                      ),
                      _QuickLink(
                        label: 'Patterns',
                        icon: Icons.security,
                        color: Colors.purpleAccent,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const AdminPatternsScreen())),
                      ),
                      _QuickLink(
                        label: 'Audit',
                        icon: Icons.assignment_outlined,
                        color: Colors.tealAccent,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const AdminAuditLogScreen())),
                      ),
                    ]),
                  ],
                ),
              ),
      ),
    );
  }
}

class _QuickLinkRow extends StatelessWidget {
  final List<Widget> children;
  const _QuickLinkRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children
          .map((c) => Expanded(child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: c,
              )))
          .toList(),
    );
  }
}

class _QuickLink extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickLink({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2035),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
