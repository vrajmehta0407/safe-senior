import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../storage/local_preferences.dart';
import '../state/guardian_provider.dart';
import '../state/language_provider.dart';
import '../utils/app_translations.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'security_status_screen.dart';
import 'scanned_messages_screen.dart';
import 'emergency_screen.dart';
import 'settings_screen.dart';
import 'warning_alert_screen.dart';
import 'safety_quiz_hub_screen.dart';
import 'achievements_screen.dart';
import 'badge_detail_screen.dart';
import 'scam_library_screen.dart';
import 'weekly_report_screen.dart';
import 'account_health_screen.dart';
import 'voice_assistant_screen.dart';
import 'help_support_screen.dart';
import 'family_circle_board_screen.dart';
import 'dart:async';
import 'unusual_location_screen.dart';
import 'safety_milestone_screen.dart';
import 'safety_quiz_screen.dart';
import 'blocked_history_screen.dart';
import 'family_invite_screen.dart';
import 'daily_safety_tips_screen.dart';
import 'security_tips_list_screen.dart';
import 'otp_alert_screen.dart';
import 'sim_swap_alert_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../models/scanned_message.dart';
import '../state/scanned_messages_provider.dart';
import '../services/pattern_cache_service.dart';
import '../services/sms_service.dart';
import '../services/call_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedFilter = 'All';
  StreamSubscription? _patternSub;

  final List<String> _filters = [
    'All',
    'Alerts',
    'Tips',
    'Quizzes',
    'Badges',
    'Reports',
    'Family',
  ];

  bool _streakClaimed = false;

  Future<void> _makePhoneCall(String phoneNumber) async {
    final clean = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not place call to $phoneNumber')),
      );
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final clean = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final target = clean.startsWith('91') ? clean : '91$clean';
    final uri = Uri.parse('https://wa.me/$target');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open WhatsApp for $phoneNumber')),
      );
    }
  }

  void _shareFamilyReport() {
    Share.share(
      '🛡️ SafeSenior Weekly Protection Report:\n'
      '• Status: 100% Protected\n'
      '• Blocked Threats: 15 Phishing SMS & 3 Scam Calls\n'
      '• Safe Score: 98%\n'
      '• Protected by SafeSenior AI Guardian.',
      subject: 'SafeSenior Family Safety Report',
    );
  }

  void _openUnusualLocationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UnusualLocationScreen(
          detectedLocation: LocalPreferences.getLastKnownLocationAddress(),
          expectedLocation: LocalPreferences.getHomeLocationAddress(),
          currentLat: LocalPreferences.getLastKnownLat(),
          currentLng: LocalPreferences.getLastKnownLng(),
          homeLat: LocalPreferences.getHomeLat(),
          homeLng: LocalPreferences.getHomeLng(),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _patternSub = PatternCacheService.onPatternUpdate.listen((data) {
      if (!mounted) return;
      final title = data['title'] ?? 'Scam Defense';
      final preview = data['preview'] ?? 'Protection filters updated';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.shield, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🛡️ Defense Active: $title',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                    ),
                    Text(
                      preview.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF006565),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          duration: const Duration(seconds: 5),
        ),
      );
    });
  }

  @override
  void dispose() {
    _patternSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryGuardian = ref.watch(primaryGuardianProvider);
    final langCode = ref.watch(languageProvider);
    final gName = primaryGuardian?.name ?? 'Family Guardian';
    final gPhone = primaryGuardian?.phone ?? '';
    final scannedMessages = ref.watch(scannedMessagesProvider);

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
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(21),
                          child: Image.asset(
                            'assets/images/app_logo.jpg',
                            width: 42,
                            height: 42,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(
                              color: const Color(0xFFE0F2F2),
                              child: const Icon(Icons.security, color: AppTheme.primaryTeal, size: 22),
                            ),
                          ),
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

                      // AI Guardian Chatbot Button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD7EFE6),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.smart_toy_outlined, color: AppTheme.primaryTeal, size: 20),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                              key: ValueKey('filter_$filter'),
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
                                  AppTranslations.tr(filter, langCode),
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

                    // ── Dynamic Filter Views (100% Full Screen Coverage) ──
                    if (_selectedFilter == 'Badges')
                      ..._buildBadgesView(langCode)
                    else if (_selectedFilter == 'Reports')
                      ..._buildReportsView(langCode, scannedMessages)
                    else if (_selectedFilter == 'Family')
                      ..._buildFamilyView(langCode, gName, gPhone)
                    else if (_selectedFilter == 'Quizzes')
                      ..._buildQuizzesView(langCode)
                    else if (_selectedFilter == 'Alerts')
                      ..._buildAlertsView(langCode, gName)
                    else if (_selectedFilter == 'Tips')
                      ..._buildTipsView(langCode)
                    else
                      ..._buildAllView(langCode, gName, gPhone, scannedMessages),
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

  // ─────────────────────────────────────────────────────────────
  // ── BADGES VIEW: 100% full-page options & working actions ──
  // ─────────────────────────────────────────────────────────────
  List<Widget> _buildBadgesView(String langCode) {
    final earnedBadges = kSampleBadges.where((b) => b.isUnlocked).toList();
    final nextGoals = kSampleBadges.where((b) => !b.isUnlocked).take(2).toList();
    return [
      // 1. 7-Day Streak & Senior Defense XP Card
      Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                        '7-Day Safety Streak! 🏆',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Level 4 Cyber Sentinel • 1,240 XP',
                        style: GoogleFonts.atkinsonHyperlegible(
                          fontSize: 13.5,
                          color: const Color(0xFFFFF9E5),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+25 XP Daily',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: const LinearProgressIndicator(
                value: 0.8,
                minHeight: 7,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '260 XP until Level 5 Shield Master',
                  style: GoogleFonts.atkinsonHyperlegible(
                    fontSize: 12,
                    color: const Color(0xFFFFF9E5),
                  ),
                ),
                Text(
                  '80%',
                  style: GoogleFonts.atkinsonHyperlegible(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () {
                if (!_streakClaimed) {
                  setState(() => _streakClaimed = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎉 +25 XP Added! Daily Safety Streak maintained!'),
                      backgroundColor: Color(0xFF006565),
                    ),
                  );
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                decoration: BoxDecoration(
                  color: _streakClaimed ? const Color(0xFFE8F5E9) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _streakClaimed ? Icons.check_circle : Icons.stars_rounded,
                      color: _streakClaimed ? const Color(0xFF2E7D32) : const Color(0xFF735C00),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _streakClaimed ? 'Streak Bonus Claimed Today ✓' : 'Claim Daily Streak Bonus (+25 XP)',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.atkinsonHyperlegible(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _streakClaimed ? const Color(0xFF2E7D32) : const Color(0xFF735C00),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // 2. 7-Day Milestone Celebration Card
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
                  color: Color(0xFFFFE088),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.celebration, color: Color(0xFF735C00), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '7-Day Milestone Celebration',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Zero fraud attacks fallen for • Tap to view celebration animation & certificate',
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

      // 3. Earned Senior Badges Gallery Card
      Container(
        width: double.infinity,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.military_tech, color: Color(0xFF735C00), size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your Earned Badges',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${earnedBadges.length} Unlocked',
                    style: GoogleFonts.atkinsonHyperlegible(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            for (int i = 0; i < earnedBadges.length; i++) ...[
              if (i > 0) const Divider(color: Color(0xFFEFEDED), height: 18),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BadgeDetailScreen(badge: earnedBadges[i])),
                  );
                },
                child: _buildBadgeRow(
                  icon: earnedBadges[i].icon,
                  color: earnedBadges[i].primaryColor,
                  bg: earnedBadges[i].bgTint,
                  title: earnedBadges[i].title,
                  subtitle: earnedBadges[i].description,
                  status: 'Active ✓',
                ),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 16),

      // 4. Upcoming Badges to Unlock Card
      Container(
        width: double.infinity,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.lock_open, color: AppTheme.primaryTeal, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Next Goals to Unlock',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final goal in nextGoals)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE8E8E8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(goal.icon, size: 18, color: goal.primaryColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  goal.title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${goal.currentProgress} / ${goal.targetProgress} ${goal.id == "cyber_scholar" ? "Quizzes" : (goal.id == "zero_leak" ? "Days" : "Steps")}',
                          style: GoogleFonts.atkinsonHyperlegible(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      goal.description,
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 12.5,
                        color: AppTheme.textLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          backgroundColor: goal.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          if (goal.id == 'cyber_scholar') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SafetyQuizScreen(topic: kSafetyQuizTopics[1]),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => BadgeDetailScreen(badge: goal)),
                            );
                          }
                        },
                        child: Text(
                          goal.id == 'cyber_scholar' ? 'Take Next Quiz (+60 XP) →' : 'View Goal Details →',
                          style: GoogleFonts.atkinsonHyperlegible(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // 5. Full Trophy Hall & Leaderboard Card
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AchievementsScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2F2),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppTheme.primaryTeal, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryTeal,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events_outlined, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Senior Trophy Hall',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    Text(
                      'View all 12 defense badges, rankings, and unlocked safety perks.',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 13,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.primaryTeal),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
    ];
  }

  Widget _buildBadgeRow({
    required IconData icon,
    required Color color,
    required Color bg,
    required String title,
    required String subtitle,
    required String status,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.atkinsonHyperlegible(
                  fontSize: 12.5,
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: GoogleFonts.atkinsonHyperlegible(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2E7D32),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // ── REPORTS VIEW: 100% full-page options & working actions ──
  // ─────────────────────────────────────────────────────────────
  List<Widget> _buildReportsView(String langCode, List<ScannedMessage> scannedMessages) {
    final dangerCount = scannedMessages.where((m) => m.riskLevelIndex > 0).length;

    return [
      // 1. Weekly Protection Report Hero Card
      Container(
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 5, width: double.infinity, color: AppTheme.primaryTeal),
              Padding(
                padding: const EdgeInsets.all(18),
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
                          child: const Icon(Icons.analytics_outlined, color: AppTheme.primaryTeal, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Weekly Protection Report',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              Text(
                                'Rolling 7-day fraud surveillance telemetry',
                                style: GoogleFonts.atkinsonHyperlegible(
                                  fontSize: 12.5,
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2F2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Live Feed',
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFDAD6),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '$dangerCount',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFAA361F),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Threats Intercepted',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFAA361F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '0',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF2E7D32),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Breaches / Loss',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2F2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '98%',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primaryTeal,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Safe Score',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryTeal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryTeal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const WeeklyReportScreen()),
                              );
                            },
                            child: Text(
                              'Open Full Report →',
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),

      // 2. Account Health Diagnostics Card
      Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.health_and_safety_outlined, color: AppTheme.primaryTeal, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Device Security Health Audit',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Score: 96%',
                    style: GoogleFonts.atkinsonHyperlegible(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Continuous background monitoring is running properly:',
              style: GoogleFonts.atkinsonHyperlegible(
                fontSize: 13,
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 10),
            _buildCheckItem('SMS Phishing Sandbox & Keyword Interceptor: ACTIVE'),
            _buildCheckItem('Robocall Telecom Spam Screen (+140 blocklist): ACTIVE'),
            _buildCheckItem('Emergency Guardian Broadcast & Geofence Ping: CONNECTED'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primaryTeal),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AccountHealthScreen()),
                  );
                },
                child: Text(
                  'Run Instant Health Diagnostics →',
                  style: GoogleFonts.atkinsonHyperlegible(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryTeal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // 3. Blocked Threat Incident History Card
      Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.block_flipped, color: Color(0xFFAA361F), size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Blocked Incident History',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '15 Fraudulent SMS neutralized and 3 spoofed police robocalls auto-screened before phone rang.',
              style: GoogleFonts.atkinsonHyperlegible(
                fontSize: 13,
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEFEDED),
                  foregroundColor: AppTheme.textDark,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BlockedHistoryScreen()),
                  );
                },
                child: Text(
                  'View Blocked Incident History Logs →',
                  style: GoogleFonts.atkinsonHyperlegible(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // 4. Live Scanned Messages Feed Card
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScannedMessagesScreen()),
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
                  color: Color(0xFFFFDAD6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.radar_outlined, color: Color(0xFFAA361F), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Real-Time Message Radar',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Monitoring incoming SMS & WhatsApp streams in real-time.',
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

      // 5. Share Safety Summary with Family Card
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFE0F2F2),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.primaryTeal, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.share_outlined, color: AppTheme.primaryTeal, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Share Safety Status with Family',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Send a 1-tap WhatsApp or SMS update to your loved ones reassuring them that your phone has 0 security breaches.',
              style: GoogleFonts.atkinsonHyperlegible(
                fontSize: 13,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _shareFamilyReport,
                icon: const Icon(Icons.send_rounded, size: 16),
                label: Text(
                  'Share Summary via WhatsApp / SMS',
                  style: GoogleFonts.atkinsonHyperlegible(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
    ];
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.atkinsonHyperlegible(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // ── FAMILY VIEW: 100% full-page options & working actions ──
  // ─────────────────────────────────────────────────────────────
  List<Widget> _buildFamilyView(String langCode, String gName, String gPhone) {
    final effectivePhone = gPhone.isNotEmpty ? gPhone : '9978785480';

    return [
      // 1. Primary Guardian Status & Direct Actions Card
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
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0F2F2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.person, color: AppTheme.primaryTeal, size: 26),
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
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        'Connected • $effectivePhone',
                        style: GoogleFonts.atkinsonHyperlegible(
                          fontSize: 13.5,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Online',
                        style: GoogleFonts.atkinsonHyperlegible(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E7D32),
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
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _makePhoneCall(effectivePhone),
                    icon: const Icon(Icons.call, size: 16),
                    label: Text(
                      'Call Guardian',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2E7D32)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _openWhatsApp(effectivePhone),
                    icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF2E7D32), size: 16),
                    label: Text(
                      'WhatsApp',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFEFEDED),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FamilyCircleBoardScreen()),
                  );
                },
                child: Text(
                  'Manage Family Circle Settings →',
                  style: GoogleFonts.atkinsonHyperlegible(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // 2. Emergency SOS Panic Button Card
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
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFAA361F).withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
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

      // 3. Family Protection Circle Members Card
      Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.groups_outlined, color: AppTheme.primaryTeal, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your Safety Circle',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '2 Active',
                    style: GoogleFonts.atkinsonHyperlegible(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildFamilyMemberItem(
              name: gName,
              phone: effectivePhone,
              role: 'Primary Guardian (Full Alerts)',
              isPrimary: true,
            ),
            const Divider(color: Color(0xFFEFEDED), height: 16),
            _buildFamilyMemberItem(
              name: 'Priya',
              phone: '+91 98250 12345',
              role: 'Secondary Guardian (Emergency Backup)',
              isPrimary: false,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primaryTeal),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FamilyInviteScreen()),
                  );
                },
                icon: const Icon(Icons.person_add_alt_1, color: AppTheme.primaryTeal, size: 16),
                label: Text(
                  '+ Invite Another Family Guardian',
                  style: GoogleFonts.atkinsonHyperlegible(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryTeal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // SafeSenior AI Chatbot Card
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.35), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryTeal.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD7EFE6),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.smart_toy_outlined, color: AppTheme.primaryTeal, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SafeSenior AI Chatbot',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        'Ask questions about suspicious calls, SMS & OTPs',
                        style: GoogleFonts.atkinsonHyperlegible(
                          fontSize: 12.5,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: Text(
                'Open AI Guardian Chatbot →',
                style: GoogleFonts.atkinsonHyperlegible(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // 4. Emergency & Cyber Helplines Card
      Container(
        width: double.infinity,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.support_agent_outlined, color: AppTheme.primaryTeal, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Emergency & Cyber Helplines',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '24/7 Toll-Free',
                    style: GoogleFonts.atkinsonHyperlegible(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'National emergency support for senior citizen safety and instant cyber fraud reporting:',
              style: GoogleFonts.atkinsonHyperlegible(
                fontSize: 13,
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 14),
            // Helpline 1: 1930 Cyber Fraud
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF9F6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEFEDED)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFDAD6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(Icons.security, color: Color(0xFFAA361F), size: 22),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '1930 — National Cyber Crime',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Instant freeze for scam bank & UPI transfers',
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 12,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFAA361F),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size.fromHeight(50),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => _makePhoneCall('1930'),
                      icon: const Icon(Icons.call, size: 20),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Call 1930 Cyber Helpline',
                          style: GoogleFonts.atkinsonHyperlegible(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Helpline 2: 14567 Elder Line
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF9F6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEFEDED)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2F2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(Icons.volunteer_activism_outlined, color: AppTheme.primaryTeal, size: 22),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '14567 — Elder Line',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Senior citizen guidance, healthcare & emergency support',
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 12,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size.fromHeight(50),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => _makePhoneCall('14567'),
                      icon: const Icon(Icons.call, size: 20),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Call 14567 Elder Line',
                          style: GoogleFonts.atkinsonHyperlegible(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // 5. Safe Geofence & Location Tracker Card
      Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on_outlined, color: Color(0xFFFF6F00), size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Safe Zones & Geofencing',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Within Safe Area',
                    style: GoogleFonts.atkinsonHyperlegible(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Home Safe Zone Active (${LocalPreferences.getHomeLocationAddress()}). GPS coordinates automatically sync with Dad.',
              style: GoogleFonts.atkinsonHyperlegible(
                fontSize: 13,
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFF6F00)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _openUnusualLocationScreen,
                child: Text(
                  'View Map & Location Anomaly Monitor →',
                  style: GoogleFonts.atkinsonHyperlegible(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFF6F00),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
    ];
  }

  Widget _buildFamilyMemberItem({
    required String name,
    required String phone,
    required String role,
    required bool isPrimary,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isPrimary ? const Color(0xFFE0F2F2) : const Color(0xFFF0F0F0),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPrimary ? Icons.star_rounded : Icons.person_outline,
            color: isPrimary ? AppTheme.primaryTeal : AppTheme.textLight,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$name ($phone)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              Text(
                role,
                style: GoogleFonts.atkinsonHyperlegible(
                  fontSize: 12,
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // ── QUIZZES VIEW: 100% full-page options & working actions ──
  // ─────────────────────────────────────────────────────────────
  List<Widget> _buildQuizzesView(String langCode) {
    return [
      // 1. Daily Featured Challenge Card
      Container(
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
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SafetyQuizScreen(topic: kSafetyQuizTopics[0]),
                  ),
                );
              },
              child: Container(
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
                      'Take Daily Quiz (3 Questions)',
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
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // 2. Weekly Senior Quiz Mastery & XP Card
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF006565), Color(0xFF007A7A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryTeal.withValues(alpha: 0.2),
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
                const Icon(Icons.shield_outlined, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Senior Cyber Shield Reflexes',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '60% This Week',
                    style: GoogleFonts.atkinsonHyperlegible(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '3 of 5 weekly drills completed • +250 XP earned so far',
              style: GoogleFonts.atkinsonHyperlegible(
                fontSize: 13.5,
                color: const Color(0xFFE0F7F6),
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: const LinearProgressIndicator(
                value: 0.6,
                minHeight: 7,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '💡 Complete 2 more drills to unlock the "Quiz Champion" badge bonus!',
              style: GoogleFonts.atkinsonHyperlegible(
                fontSize: 12.5,
                color: const Color(0xFFFFE088),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // 3. Drill Card 1: Digital Arrest Police Threat Drill
      _buildQuizDrillCard(
        category: 'GOVERNMENT / LAW',
        title: 'Digital Arrest & Police Video Scam',
        subtitle: 'Spot fake CBI, ED, and Mumbai Police video interrogation threats on Skype.',
        xp: '+70 XP',
        icon: Icons.gavel,
        color: const Color(0xFFAA361F),
        topicIndex: 2,
      ),
      const SizedBox(height: 16),

      // 4. Drill Card 2: Grandchild SOS & AI Voice Clones
      _buildQuizDrillCard(
        category: 'FAMILY IMPERSONATION',
        title: 'Grandchild SOS & AI Voice Clones',
        subtitle: 'Recognize synthetic voice calls and frantic family emergency money demands.',
        xp: '+60 XP',
        icon: Icons.record_voice_over,
        color: const Color(0xFFFE7356),
        topicIndex: 1,
      ),
      const SizedBox(height: 16),

      // 5. Drill Card 3: AnyDesk & Remote Screen Control Trap
      _buildQuizDrillCard(
        category: 'TECH SUPPORT',
        title: 'AnyDesk & Remote Desktop Scams',
        subtitle: 'Prevent scammers from tricking you into installing remote screen sharing apps.',
        xp: '+60 XP',
        icon: Icons.phonelink_setup,
        color: const Color(0xFF735C00),
        topicIndex: 3,
      ),
      const SizedBox(height: 16),

      // 6. Full Safety Quiz Hub Action Card
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SafetyQuizHubScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2F2),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppTheme.primaryTeal, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryTeal,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.menu_book, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore Full Safety Quiz Hub',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    Text(
                      '10+ categories: parcel delivery, KBC lottery, electricity bill traps.',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 13,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.primaryTeal),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
    ];
  }

  Widget _buildQuizDrillCard({
    required String category,
    required String title,
    required String subtitle,
    required String xp,
    required IconData icon,
    required Color color,
    required int topicIndex,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                category,
                style: GoogleFonts.atkinsonHyperlegible(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: 0.6,
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
                  xp,
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
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.atkinsonHyperlegible(
              fontSize: 13.5,
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final topic = topicIndex < kSafetyQuizTopics.length
                    ? kSafetyQuizTopics[topicIndex]
                    : kSafetyQuizTopics.first;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SafetyQuizScreen(topic: topic)),
                );
              },
              child: Text(
                'Start Drill (3 Questions) ▶',
                style: GoogleFonts.atkinsonHyperlegible(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // ── ALERTS VIEW: 100% full-page options & working actions ──
  // ─────────────────────────────────────────────────────────────
  List<Widget> _buildAlertsView(String langCode, String gName) {
    return [
      // 1. Hero Status Card
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
                      AppTranslations.tr('Protection Active', langCode),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      AppTranslations.tr('100% Safe', langCode),
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
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),

      // 2. High Risk Threat Alert: Digital Arrest
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WarningAlertScreen()),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE3E2E2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 4, width: double.infinity, color: const Color(0xFFAA361F)),
                Padding(
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
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),

      // 3. Bank OTP & UPI Harvest Trap Alert Card
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OtpAlertScreen()),
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
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFDAD6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.password_rounded, color: Color(0xFFAA361F), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fake Bank OTP Intercept Alert',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      'Fraudsters claiming electricity will be cut unless you share 6-digit OTP.',
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

      // 4. SIM Swap & Telecom Hijack Alert Card
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SimSwapAlertScreen()),
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
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.sim_card_alert_outlined, color: Color(0xFFFF6F00), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SIM Swap & Porting Fraud Alert',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      'Fake Airtel/Jio messages asking to send SIMREQ code to 121.',
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

      // 5. Unusual Location Alert
      GestureDetector(
        onTap: _openUnusualLocationScreen,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE3E2E2)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 4, width: double.infinity, color: const Color(0xFFFF6F00)),
                Padding(
                  padding: const EdgeInsets.all(18),
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
                              context.tr('Unusual Location Alert'),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark,
                              ),
                            ),
                            Text(
                              '${LocalPreferences.getLastKnownLocationAddress()} (${context.tr('Unusual — not your typical area')})',
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
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),

      // 6. Emergency SOS Panic Button
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
    ];
  }

  // ─────────────────────────────────────────────────────────────
  // ── TIPS VIEW: 100% full-page options & working actions ──
  // ─────────────────────────────────────────────────────────────
  List<Widget> _buildTipsView(String langCode) {
    return [
      // 1. Scam Pattern Library
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

      // 2. Daily Senior Safety Tips Card
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DailySafetyTipsScreen()),
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
                  color: Color(0xFFFFE088),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lightbulb_outline, color: Color(0xFF735C00), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Safety Tips & Rules',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rule #1: Never share an OTP. Rule #2: Real police never video call.',
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

      // 3. Phishing Links & Spoofed Websites Guide
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SecurityTipsListScreen()),
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
                child: const Icon(Icons.link_off_outlined, color: AppTheme.primaryTeal, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phishing & Spoofed Sites Guide',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'How scammers fake bank URLs with .top and .xyz domains.',
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

      // 4. Scanned Messages Feed
      GestureDetector(
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFDAD6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.sms_outlined, color: Color(0xFFAA361F), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scanned Messages Feed',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Live SMS & WhatsApp feed monitoring and analysis',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 12.5,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textLight),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),

      // 5. Account Health & Device Security Checklist
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AccountHealthScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2F2),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppTheme.primaryTeal, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryTeal,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.health_and_safety_outlined, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Health & Safety Checklist',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    Text(
                      'Review app permissions, biometric locking, and daily protection limits.',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 13,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.primaryTeal),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
    ];
  }

  // ─────────────────────────────────────────────────────────────
  // ── ALL VIEW: Curated top highlights across the platform ──
  // ─────────────────────────────────────────────────────────────
  List<Widget> _buildAllView(
    String langCode,
    String gName,
    String gPhone,
    List<ScannedMessage> scannedMessages,
  ) {
    return [
      // 1. Hero Status Card
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
                      AppTranslations.tr('Protection Active', langCode),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      AppTranslations.tr('100% Safe', langCode),
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
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),

      // 2. High Risk Threat Alert
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WarningAlertScreen()),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE3E2E2)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 4, width: double.infinity, color: const Color(0xFFAA361F)),
                Padding(
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
                        'Scammers posing as CBI/Police demanding instant bail payment over Skype.',
                        style: GoogleFonts.atkinsonHyperlegible(
                          fontSize: 14.5,
                          color: AppTheme.textLight,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
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
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),

      // 3. Daily Safety Quiz
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SafetyQuizScreen(topic: kSafetyQuizTopics[0])),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFBDC9C8)),
          ),
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
              const SizedBox(height: 8),
              Text(
                'Spot the Fake SBI KYC SMS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Test your scam reflexes against real SMS scenarios received by seniors this week.',
                style: GoogleFonts.atkinsonHyperlegible(
                  fontSize: 13.5,
                  color: AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Take Quiz (3 Questions) ▶',
                    style: GoogleFonts.atkinsonHyperlegible(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),

      // 4. Scam Pattern Library
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

      // 5. Scanned Messages Feed
      GestureDetector(
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFDAD6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.sms_outlined, color: Color(0xFFAA361F), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      'Live SMS & WhatsApp feed monitoring',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 12.5,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textLight),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),

      // 6. Weekly Protection Report
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
                      '${scannedMessages.where((m) => m.riskLevelIndex > 0).length} threats intercepted this week • 0 breaches.',
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

      // 7. Primary Guardian Check-in
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFBDC9C8)),
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
            const SizedBox(height: 14),
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

      // 8. 7-Day Safety Streak Banner
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

      // 9. Unusual Location Alert
      GestureDetector(
        onTap: _openUnusualLocationScreen,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE3E2E2)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 4, width: double.infinity, color: const Color(0xFFFF6F00)),
                Padding(
                  padding: const EdgeInsets.all(18),
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
                              context.tr('Unusual Location Alert'),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark,
                              ),
                            ),
                            Text(
                              '${LocalPreferences.getLastKnownLocationAddress()} (${context.tr('Unusual — not your typical area')})',
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
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),

      // 10. Emergency SOS Panic Button
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
    ];
  }
}
