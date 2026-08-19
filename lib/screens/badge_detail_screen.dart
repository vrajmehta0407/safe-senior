import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class BadgeItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final IconData icon;
  final Color primaryColor;
  final Color bgTint;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int currentProgress;
  final int targetProgress;

  const BadgeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.primaryColor,
    required this.bgTint,
    required this.isUnlocked,
    this.unlockedAt,
    required this.currentProgress,
    required this.targetProgress,
  });
}

class BadgeDetailScreen extends StatelessWidget {
  final BadgeItem badge;

  const BadgeDetailScreen({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    final progressFraction = (badge.currentProgress / badge.targetProgress).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Trophy Detail',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // Badge Icon Ring
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: badge.bgTint,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: badge.primaryColor.withValues(alpha: 0.25),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(color: badge.primaryColor, width: 3),
                      ),
                      child: Center(
                        child: Icon(badge.icon, size: 60, color: badge.primaryColor),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Badge Title
                    Text(
                      badge.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Unlocked Status Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: badge.isUnlocked ? const Color(0xFFE0F2F2) : const Color(0xFFEFEDED),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            badge.isUnlocked ? Icons.check_circle : Icons.lock_outline,
                            size: 16,
                            color: badge.isUnlocked ? AppTheme.primaryTeal : AppTheme.textLight,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            badge.isUnlocked ? 'Unlocked & Active' : 'In Progress',
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: badge.isUnlocked ? AppTheme.primaryTeal : AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Description Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE3E2E2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How you earned this badge:',
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            badge.description,
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 16,
                              color: AppTheme.textDark,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Divider(color: Color(0xFFEFEDED)),
                          const SizedBox(height: 12),

                          // Progress tracker
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Requirement Progress',
                                style: GoogleFonts.atkinsonHyperlegible(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              Text(
                                '${badge.currentProgress} / ${badge.targetProgress}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: badge.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progressFraction,
                              backgroundColor: const Color(0xFFE3E2E2),
                              valueColor: AlwaysStoppedAnimation<Color>(badge.primaryColor),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Share button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '🎉 Badge shared with your family guardians!',
                                style: GoogleFonts.atkinsonHyperlegible(color: Colors.white),
                              ),
                              backgroundColor: AppTheme.primaryTeal,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.share, size: 20, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Share Milestone with Family',
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
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
    );
  }
}
