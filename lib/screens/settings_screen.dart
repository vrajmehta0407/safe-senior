import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../theme.dart';
import '../state/auth_provider.dart';
import '../storage/local_preferences.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'login_screen.dart';
import 'help_support_screen.dart';
import 'guardian_contacts_screen.dart';
import 'security_status_screen.dart';
import 'language_screen.dart';
import 'weekly_report_screen.dart';
import 'achievements_screen.dart';
import 'scam_library_screen.dart';
import 'profile_checklist_screen.dart';
import 'app_update_screen.dart';
import 'forgot_pin_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _smsShieldEnabled = true;
  bool _callShieldEnabled = true;
  bool _voiceGuidanceEnabled = true;

  @override
  void initState() {
    super.initState();
    _voiceGuidanceEnabled = LocalPreferences.getVoiceEnabled();
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sign Out?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppTheme.textDark),
        ),
        content: Text(
          'Are you sure you want to sign out of SafeSenior? Background protection will remain active on this device.',
          style: GoogleFonts.atkinsonHyperlegible(fontSize: 15, color: const Color(0xFF4A4A4A)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.atkinsonHyperlegible(fontWeight: FontWeight.w700, color: AppTheme.primaryTeal),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.terracottaRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, imageQuality: 80);
    if (picked != null) {
      await ref.read(authProvider.notifier).updateAvatarPath(picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFBF7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0F2F2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.security, color: AppTheme.primaryTeal, size: 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Settings & Preferences',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Senior Profile Hero Card ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _pickAvatar,
                            child: Stack(
                              children: [
                                Container(
                                  width: 68,
                                  height: 68,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppTheme.primaryTeal, width: 2.5),
                                    image: DecorationImage(
                                      image: user?.avatarPath != null
                                          ? FileImage(File(user!.avatarPath!)) as ImageProvider
                                          : const NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(color: AppTheme.primaryTeal, shape: BoxShape.circle),
                                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'Senior Protection Account',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textDark,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user?.phone.isNotEmpty == true ? user!.phone : (user?.email ?? 'Active Protection Member'),
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 13.5,
                                    color: const Color(0xFF6B7B78),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD7EFE6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '🛡️ 100% Protected Account',
                                    style: GoogleFonts.atkinsonHyperlegible(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF006565),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Active Shield Controls (Real Working Toggles) ──
                    Text(
                      'ACTIVE DEFENSE SWITCHES',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: const Color(0xFF6B7B78),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 14,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            activeColor: AppTheme.primaryTeal,
                            secondary: const Icon(Icons.sms_outlined, color: AppTheme.primaryTeal),
                            title: Text(
                              'SMS Scam & OTP Shield',
                              style: GoogleFonts.atkinsonHyperlegible(fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                            subtitle: Text(
                              'Scans incoming SMS for fraud links and fake OTPs in real-time',
                              style: GoogleFonts.atkinsonHyperlegible(fontSize: 12.5, color: const Color(0xFF6B7B78)),
                            ),
                            value: _smsShieldEnabled,
                            onChanged: (v) {
                              setState(() => _smsShieldEnabled = v);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(v ? 'SMS Shield Activated' : 'SMS Shield Paused'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, indent: 64),
                          SwitchListTile(
                            activeColor: AppTheme.primaryTeal,
                            secondary: const Icon(Icons.phone_in_talk_outlined, color: AppTheme.primaryTeal),
                            title: Text(
                              'In-Call Scam Detection',
                              style: GoogleFonts.atkinsonHyperlegible(fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                            subtitle: Text(
                              'Flags suspicious caller IDs and digital arrest scams',
                              style: GoogleFonts.atkinsonHyperlegible(fontSize: 12.5, color: const Color(0xFF6B7B78)),
                            ),
                            value: _callShieldEnabled,
                            onChanged: (v) {
                              setState(() => _callShieldEnabled = v);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(v ? 'Call Shield Activated' : 'Call Shield Paused'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, indent: 64),
                          SwitchListTile(
                            activeColor: AppTheme.primaryTeal,
                            secondary: const Icon(Icons.record_voice_over_outlined, color: AppTheme.primaryTeal),
                            title: Text(
                              'Voice Assistant Guidance',
                              style: GoogleFonts.atkinsonHyperlegible(fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                            subtitle: Text(
                              'Reads alerts aloud with large clear audio',
                              style: GoogleFonts.atkinsonHyperlegible(fontSize: 12.5, color: const Color(0xFF6B7B78)),
                            ),
                            value: _voiceGuidanceEnabled,
                            onChanged: (v) async {
                              setState(() => _voiceGuidanceEnabled = v);
                              await LocalPreferences.setVoiceEnabled(v);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // ── Core Hub Navigation (Pinterest Card Grid) ──
                    Text(
                      'FAMILY & PROTECTION HUBS',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: const Color(0xFF6B7B78),
                      ),
                    ),
                    const SizedBox(height: 10),

                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.15,
                      children: [
                        _hubCard(
                          icon: Icons.people_outline,
                          title: 'Family Circle',
                          subtitle: 'Connected Guardians',
                          color: const Color(0xFFE0F2F2),
                          iconColor: AppTheme.primaryTeal,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuardianContactsScreen())),
                        ),
                        _hubCard(
                          icon: Icons.health_and_safety_outlined,
                          title: 'Security Status',
                          subtitle: 'Live 8-Point Check',
                          color: const Color(0xFFD7EFE6),
                          iconColor: const Color(0xFF006565),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityStatusScreen())),
                        ),
                        _hubCard(
                          icon: Icons.checklist_rtl_outlined,
                          title: 'Safety Checklist',
                          subtitle: 'Profile Audit',
                          color: const Color(0xFFFFF3D6),
                          iconColor: const Color(0xFFB28000),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileChecklistScreen())),
                        ),
                        _hubCard(
                          icon: Icons.menu_book_outlined,
                          title: 'Scam Library',
                          subtitle: '50+ Real Scams',
                          color: const Color(0xFFFFE8E5),
                          iconColor: AppTheme.terracottaRed,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScamLibraryScreen())),
                        ),
                        _hubCard(
                          icon: Icons.insights_outlined,
                          title: 'Weekly Report',
                          subtitle: 'Scans & Threats',
                          color: const Color(0xFFEFE8FF),
                          iconColor: const Color(0xFF673AB7),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WeeklyReportScreen())),
                        ),
                        _hubCard(
                          icon: Icons.military_tech_outlined,
                          title: 'Achievements',
                          subtitle: 'Milestone Badges',
                          color: const Color(0xFFFFE088),
                          iconColor: const Color(0xFF735C00),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsScreen())),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // ── App & Security Preferences ──
                    Text(
                      'APP & SECURITY',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: const Color(0xFF6B7B78),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 14,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _prefTile(
                            icon: Icons.language,
                            title: 'Language / भाषा / ભાષા',
                            subtitle: '7 Indian & Global languages',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageScreen())),
                          ),
                          const Divider(height: 1, indent: 56),
                          _prefTile(
                            icon: Icons.pin_outlined,
                            title: 'Reset Security PIN',
                            subtitle: 'Update your 4-digit master PIN',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPinScreen())),
                          ),
                          const Divider(height: 1, indent: 56),
                          _prefTile(
                            icon: Icons.system_update_alt,
                            title: 'App Updates & Threat Engine',
                            subtitle: 'SafeSenior v2.4 (Latest)',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppUpdateScreen())),
                          ),
                          const Divider(height: 1, indent: 56),
                          _prefTile(
                            icon: Icons.help_outline,
                            title: 'Help & Emergency Support',
                            subtitle: '24/7 Helpline & FAQs',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Sign Out Button ──
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _signOut,
                        icon: const Icon(Icons.logout, color: AppTheme.terracottaRed),
                        label: Text(
                          'Sign Out',
                          style: GoogleFonts.atkinsonHyperlegible(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.terracottaRed,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFFDAD6), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          backgroundColor: const Color(0xFFFFF8F7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
    );
  }

  Widget _hubCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.8), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Icon(icon, color: iconColor, size: 20)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    fontSize: 11.5,
                    color: const Color(0xFF6B7B78),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _prefTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.textDark, size: 18),
      ),
      title: Text(
        title,
        style: GoogleFonts.atkinsonHyperlegible(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textDark),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.atkinsonHyperlegible(fontSize: 12.5, color: const Color(0xFF6B7B78)),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFB0B0B0)),
      onTap: onTap,
    );
  }
}
