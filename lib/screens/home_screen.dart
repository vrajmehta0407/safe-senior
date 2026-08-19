import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../state/guardian_provider.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'security_status_screen.dart';
import 'scanned_messages_screen.dart';
import 'emergency_screen.dart';
import 'guardian_contacts_screen.dart';
import 'settings_screen.dart';
import 'phishing_guide_screen.dart';
import 'warning_alert_screen.dart';
import 'safety_quiz_hub_screen.dart';
import 'achievements_screen.dart';
import 'scam_library_screen.dart';
import 'weekly_report_screen.dart';
import 'account_health_screen.dart';
import 'qr_safety_screen.dart';
import 'deepfake_warning_screen.dart';
import 'sim_swap_alert_screen.dart';
import 'voice_assistant_screen.dart';
import 'family_circle_board_screen.dart';
import 'explore_screen.dart';
import 'unusual_location_screen.dart';
import 'safety_milestone_screen.dart';
import 'sms_scam_alert_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Alerts',
    'Tips',
    'Quizzes',
    'Badges',
    'Reports',
    'Family',
  ];

  @override
  Widget build(BuildContext context) {
    final primaryGuardian = ref.watch(primaryGuardianProvider);
    final gName = primaryGuardian?.name ?? 'Amit Patel';
    final gPhone = primaryGuardian?.phone ?? '+91 98250 14820';

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: Column(
          children: [
            // ── TopAppBar (Stitch Header with Voice & Badges) ──
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Brand & Shield Icon
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE0F2F2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.security, color: AppTheme.primaryTeal, size: 22),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'SafeSenior',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryTeal,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),

                  // Quick Action Icons (Voice Assistant & Settings)
                  Row(
                    children: [
                      // Voice Assistant Mic Button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const VoiceAssistantScreen()),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE0F2F2),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.mic, color: AppTheme.primaryTeal, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Trophy Badges Button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFE088),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.emoji_events, color: Color(0xFF735C00), size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Settings Gear
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SettingsScreen()),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE3E2E2),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.settings_outlined, color: AppTheme.textLight, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Filter Pills (Stitch Horizontal Scroll) ──
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filters.map((filter) {
                          final isActive = _selectedFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedFilter = filter),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                                decoration: BoxDecoration(
                                  color: isActive ? AppTheme.primaryTeal : const Color(0xFFE0F2F2),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: isActive ? AppTheme.primaryTeal : const Color(0xFFBDC9C8),
                                  ),
                                ),
                                child: Text(
                                  filter,
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isActive ? Colors.white : AppTheme.primaryTeal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Hero Status Card (Stitch: Home Feed - All Clear State) ──
                    if (_selectedFilter == 'All' || _selectedFilter == 'Alerts') ...[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SecurityStatusScreen()),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF006565), Color(0xFF007A7A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryTeal.withValues(alpha: 0.18),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.verified_user_rounded, color: Colors.white, size: 22),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Protection Active',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '100% Safe',
                                      style: GoogleFonts.atkinsonHyperlegible(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'All background defenses active. 0 threats detected in last 24h.',
                                style: GoogleFonts.atkinsonHyperlegible(
                                  fontSize: 13.5,
                                  color: const Color(0xFFE0F7F6),
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Shield Center',
                                            style: GoogleFonts.atkinsonHyperlegible(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.primaryTeal,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.arrow_forward_rounded, size: 14, color: AppTheme.primaryTeal),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const AccountHealthScreen()),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                                      ),
                                      child: Text(
                                        'Score: 96%',
                                        style: GoogleFonts.atkinsonHyperlegible(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Card: Interactive Safety Quiz Card (Stitch: Safety Quiz) ──
                    if (_selectedFilter == 'All' || _selectedFilter == 'Quizzes') ...[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SafetyQuizHubScreen()),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: const Color(0xFFBDC9C8), width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFFE088),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.school, color: Color(0xFF735C00), size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'DAILY SAFETY QUIZ',
                                    style: GoogleFonts.atkinsonHyperlegible(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF735C00),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0F2F2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '+50 XP',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.primaryTeal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Spot the Fake SBI KYC SMS',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Test your scam reflexes against real SMS scenarios received by seniors this week.',
                                style: GoogleFonts.atkinsonHyperlegible(
                                  fontSize: 14.5,
                                  color: AppTheme.textLight,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryTeal,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Take Quiz (3 Questions)',
                                      style: GoogleFonts.atkinsonHyperlegible(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.play_arrow, color: Colors.white, size: 18),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Card: High Risk Alert (Stitch: Digital Arrest) ──
                    if (_selectedFilter == 'All' || _selectedFilter == 'Alerts') ...[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const WarningAlertScreen()),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: const Border(
                              top: BorderSide(color: Color(0xFFAA361F), width: 4),
                              left: BorderSide(color: Color(0xFFE3E2E2)),
                              right: BorderSide(color: Color(0xFFE3E2E2)),
                              bottom: BorderSide(color: Color(0xFFE3E2E2)),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFAA361F), size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'HIGH RISK THREAT ALERT',
                                    style: GoogleFonts.atkinsonHyperlegible(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFFAA361F),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Digital Arrest Police Video Call Scam',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Scammers posing as CBI/Police demanding instant bail payment over Skype. Real police never conduct court trials on video calls.',
                                style: GoogleFonts.atkinsonHyperlegible(
                                  fontSize: 14.5,
                                  color: AppTheme.textLight,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tap to read emergency response protocol →',
                                style: GoogleFonts.atkinsonHyperlegible(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFAA361F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Card: Scam Pattern Library (Stitch: Scam Pattern Library) ──
                    if (_selectedFilter == 'All' || _selectedFilter == 'Tips') ...[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ScamLibraryScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(18),
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
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE0F2F2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.menu_book, color: AppTheme.primaryTeal, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Scam Pattern Library',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Explore 50+ verified fraud tactics & red flags.',
                                      style: GoogleFonts.atkinsonHyperlegible(
                                        fontSize: 13.5,
                                        color: AppTheme.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textLight),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Card: Quick Scanners Grid (QR Safety + Message Scanner) ──
                    if (_selectedFilter == 'All' || _selectedFilter == 'Tips') ...[
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const QrSafetyScreen()),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFE3E2E2)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE0F2F2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.qr_code_scanner, color: AppTheme.primaryTeal, size: 22),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'QR Safety Check',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Scan before paying',
                                      style: GoogleFonts.atkinsonHyperlegible(
                                        fontSize: 12.5,
                                        color: AppTheme.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ScannedMessagesScreen()),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFE3E2E2)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFFDAD6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.sms_outlined, color: Color(0xFFAA361F), size: 22),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Scanned Messages',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'SMS & WhatsApp feed',
                                      style: GoogleFonts.atkinsonHyperlegible(
                                        fontSize: 12.5,
                                        color: AppTheme.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Card: Weekly Report (Stitch: Weekly Protection Report) ──
                    if (_selectedFilter == 'All' || _selectedFilter == 'Reports') ...[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const WeeklyReportScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(18),
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
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE0F2F2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.analytics_outlined, color: AppTheme.primaryTeal, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Weekly Protection Report',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '4 threats intercepted this week • 0 breaches.',
                                      style: GoogleFonts.atkinsonHyperlegible(
                                        fontSize: 13.5,
                                        color: AppTheme.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textLight),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Card: Family Guardian Check-in (Stitch: Family Circle Board) ──
                    if (_selectedFilter == 'All' || _selectedFilter == 'Family') ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFFBDC9C8)),
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
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE0F2F2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.people, color: AppTheme.primaryTeal, size: 24),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Primary Guardian: $gName',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                      Text(
                                        'Connected • $gPhone',
                                        style: GoogleFonts.atkinsonHyperlegible(
                                          fontSize: 13.5,
                                          color: AppTheme.textLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const FamilyCircleBoardScreen()),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFEDED),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Manage Family Circle',
                                          style: GoogleFonts.atkinsonHyperlegible(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Card: 7-Day Milestone Celebration (Stitch: Milestone Celebration) ──
                    if (_selectedFilter == 'All' || _selectedFilter == 'Badges') ...[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SafetyMilestoneCelebrationScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF735C00), Color(0xFFCCA830)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFCCA830).withValues(alpha: 0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.emoji_events, color: Colors.white, size: 26),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '7-Day Safety Streak!',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Zero fraud attacks fallen for • Tap to view XP reward',
                                      style: GoogleFonts.atkinsonHyperlegible(
                                        fontSize: 13.5,
                                        color: const Color(0xFFFFF9E5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Card: Unusual Location Alert (Stitch: Location Anomaly) ──
                    if (_selectedFilter == 'All' || _selectedFilter == 'Alerts') ...[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const UnusualLocationScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: const Border(
                              top: BorderSide(color: Color(0xFFFF6F00), width: 4),
                              left: BorderSide(color: Color(0xFFE3E2E2)),
                              right: BorderSide(color: Color(0xFFE3E2E2)),
                              bottom: BorderSide(color: Color(0xFFE3E2E2)),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6F00).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.location_on, color: Color(0xFFFF6F00), size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Unusual Location Alert',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    Text(
                                      'Connaught Place, Delhi (Unusual area)',
                                      style: GoogleFonts.atkinsonHyperlegible(
                                        fontSize: 13,
                                        color: AppTheme.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textLight),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Card: Explore Scam Encyclopedia (Stitch: Discover Board) ──
                    if (_selectedFilter == 'All' || _selectedFilter == 'Tips') ...[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ExploreDiscoverScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: const Color(0xFFE3E2E2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE0F2F2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.explore, color: AppTheme.primaryTeal, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Explore & Discover',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    Text(
                                      'Browse all scam categories & safety guides',
                                      style: GoogleFonts.atkinsonHyperlegible(
                                        fontSize: 13,
                                        color: AppTheme.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textLight),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Card: Emergency SOS (Stitch: SOS Screen) ──
                    if (_selectedFilter == 'All' || _selectedFilter == 'Alerts' || _selectedFilter == 'Family') ...[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EmergencyScreen()),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFDAD6),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: const Color(0xFFAA361F), width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFAA361F),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.emergency, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Emergency SOS Panic Button',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFFAA361F),
                                      ),
                                    ),
                                    Text(
                                      '1-Tap notify $gName & National Helpline (1930)',
                                      style: GoogleFonts.atkinsonHyperlegible(
                                        fontSize: 13.5,
                                        color: const Color(0xFF6D0F00),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFAA361F)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),

            // ── Floating Bottom Navigation Bar (Stitch 4-Tab) ──
            const AppBottomNavBar(currentIndex: 0),
          ],
        ),
      ),
    );
  }
}
