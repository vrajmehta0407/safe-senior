import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'badge_detail_screen.dart';

final List<BadgeItem> kSampleBadges = [
  const BadgeItem(
    id: 'phishing_sentinel',
    title: 'Phishing Sentinel (Level 2)',
    description: '10+ spoofed bank SMS and malicious links inspected and avoided without clicking.',
    category: 'SMS & Web Defense',
    icon: Icons.shield,
    primaryColor: AppTheme.primaryTeal,
    bgTint: Color(0xFFE0F2F2),
    isUnlocked: true,
    currentProgress: 12,
    targetProgress: 10,
  ),
  const BadgeItem(
    id: 'spam_neutralizer',
    title: 'Spam Neutralizer (Level 3)',
    description: '15+ scam robocalls, spoofed police numbers and fake CBI calls screened and auto-blocked.',
    category: 'Call Protection',
    icon: Icons.phone_callback,
    primaryColor: Color(0xFFFE7356),
    bgTint: Color(0xFFFFDAD3),
    isUnlocked: true,
    currentProgress: 18,
    targetProgress: 15,
  ),
  const BadgeItem(
    id: 'quiz_champion',
    title: 'Quiz Champion (Level 1)',
    description: 'Achieved 100% accuracy on interactive senior fraud scenario drills in the Quiz Hub.',
    category: 'Knowledge',
    icon: Icons.school,
    primaryColor: Color(0xFFCCA830),
    bgTint: Color(0xFFFFE088),
    isUnlocked: true,
    currentProgress: 5,
    targetProgress: 5,
  ),
  const BadgeItem(
    id: 'family_protector',
    title: 'Family Protector (Level 1)',
    description: 'Primary guardian linked, emergency contacts verified, and 1-tap SOS connection established.',
    category: 'Family Care',
    icon: Icons.people,
    primaryColor: Color(0xFF006565),
    bgTint: Color(0xFF93F2F2),
    isUnlocked: true,
    currentProgress: 1,
    targetProgress: 1,
  ),
  const BadgeItem(
    id: 'shield_bearer',
    title: 'Shield Bearer',
    description: 'Maintained continuous 24/7 AI background protection for over 14 consecutive days.',
    category: 'Protection',
    icon: Icons.verified_user,
    primaryColor: AppTheme.primaryTeal,
    bgTint: Color(0xFFE0F2F2),
    isUnlocked: true,
    currentProgress: 14,
    targetProgress: 14,
  ),
  const BadgeItem(
    id: 'voice_shield',
    title: 'Voice Shield',
    description: 'Enabled microphone scanning, voice alerts, and verified AI deepfake voice protection.',
    category: 'AI Defense',
    icon: Icons.record_voice_over,
    primaryColor: Color(0xFF735C00),
    bgTint: Color(0xFFFFE088),
    isUnlocked: true,
    currentProgress: 1,
    targetProgress: 1,
  ),
  const BadgeItem(
    id: 'zero_leak',
    title: 'Zero Leak Master',
    description: 'Kept OTP credentials secure for 30 consecutive days without any unauthorized exposure.',
    category: 'Privacy',
    icon: Icons.lock,
    primaryColor: AppTheme.primaryTeal,
    bgTint: Color(0xFFE0F2F2),
    isUnlocked: false,
    currentProgress: 18,
    targetProgress: 30,
  ),
  const BadgeItem(
    id: 'cyber_scholar',
    title: 'Cyber Scholar',
    description: 'Complete 5 comprehensive interactive fraud scenario drills to master cyber safety.',
    category: 'Knowledge',
    icon: Icons.psychology,
    primaryColor: Color(0xFF735C00),
    bgTint: Color(0xFFFFE088),
    isUnlocked: false,
    currentProgress: 3,
    targetProgress: 5,
  ),
  const BadgeItem(
    id: 'safe_surfer',
    title: 'Safe Surfer',
    description: 'Inspect and verify 20+ URLs without visiting any blacklisted or fraudulent domains.',
    category: 'Threat Radar',
    icon: Icons.language,
    primaryColor: AppTheme.primaryTeal,
    bgTint: Color(0xFFE0F2F2),
    isUnlocked: false,
    currentProgress: 12,
    targetProgress: 20,
  ),
  const BadgeItem(
    id: 'emergency_ready',
    title: 'Emergency Ready',
    description: 'Configure emergency contacts, blood group, medical notes, and speed dials in emergency profile.',
    category: 'Emergency',
    icon: Icons.emergency,
    primaryColor: Color(0xFFAA361F),
    bgTint: Color(0xFFFFDAD6),
    isUnlocked: false,
    currentProgress: 2,
    targetProgress: 3,
  ),
  const BadgeItem(
    id: 'app_armor',
    title: 'App Armor',
    description: 'Complete device security audit and ensure camera, microphone, and SMS permissions are secured.',
    category: 'Device Security',
    icon: Icons.security,
    primaryColor: Color(0xFF006565),
    bgTint: Color(0xFFE0F2F2),
    isUnlocked: false,
    currentProgress: 3,
    targetProgress: 4,
  ),
  const BadgeItem(
    id: 'century_sentinel',
    title: 'Century Sentinel',
    description: 'Maintain uninterrupted senior cyber protection and threat monitoring for 100 consecutive days.',
    category: 'Milestone',
    icon: Icons.emoji_events,
    primaryColor: Color(0xFFCCA830),
    bgTint: Color(0xFFFFE088),
    isUnlocked: false,
    currentProgress: 14,
    targetProgress: 100,
  ),
];

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
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
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Achievements & Badges',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Senior Level Progress Card ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF735C00), Color(0xFFCCA830)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFCCA830).withValues(alpha: 0.3),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Guardian Rank',
                                    style: GoogleFonts.atkinsonHyperlegible(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFFFE088),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Level 3: Vigilant Scout',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(Icons.emoji_events, color: Colors.white, size: 28),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '320 / 500 XP to Level 4',
                                style: GoogleFonts.atkinsonHyperlegible(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '64%',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: const LinearProgressIndicator(
                              value: 0.64,
                              backgroundColor: Color(0x40FFFFFF),
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ── Safety Streak Banner ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                          const Text('🔥', style: TextStyle(fontSize: 28)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '14-Day Scam-Free Streak!',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                Text(
                                  'No malicious links opened this month. Keep it up!',
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
                    ),
                    const SizedBox(height: 24),

                    // ── Badges Grid ──
                    Text(
                      'Trophies & Badges (${kSampleBadges.where((b) => b.isUnlocked).length}/${kSampleBadges.length} Unlocked)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 14),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: kSampleBadges.length,
                      itemBuilder: (context, idx) {
                        final badge = kSampleBadges[idx];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BadgeDetailScreen(badge: badge),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: badge.isUnlocked ? const Color(0xFFBDC9C8) : const Color(0xFFE3E2E2),
                                width: badge.isUnlocked ? 1.5 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: badge.isUnlocked ? badge.bgTint : const Color(0xFFF5F3F3),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        badge.icon,
                                        size: 32,
                                        color: badge.isUnlocked ? badge.primaryColor : const Color(0xFF9E9E9E),
                                      ),
                                    ),
                                    if (!badge.isUnlocked)
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF717171),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.lock, size: 12, color: Colors.white),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  badge.title,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: badge.isUnlocked ? AppTheme.textDark : const Color(0xFF9E9E9E),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  badge.isUnlocked ? 'Unlocked' : '${badge.currentProgress}/${badge.targetProgress}',
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: badge.isUnlocked ? AppTheme.primaryTeal : const Color(0xFF717171),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
