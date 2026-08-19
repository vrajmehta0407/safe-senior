import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'safety_quiz_hub_screen.dart';
import 'achievements_screen.dart';
import 'home_screen.dart';

class QuizResultsScreen extends StatelessWidget {
  final QuizTopic topic;
  final int totalQuestions;
  final int correctCount;

  const QuizResultsScreen({
    super.key,
    required this.topic,
    required this.totalQuestions,
    required this.correctCount,
  });

  @override
  Widget build(BuildContext context) {
    final scorePercent = (correctCount / totalQuestions) * 100;
    final isMastery = scorePercent >= 70;
    final earnedXp = (topic.xpReward * (correctCount / totalQuestions)).round();

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // ── Trophy Celebration Avatar (Stitch Gold Container) ──
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: isMastery ? const Color(0xFFFFE088) : const Color(0xFFE0F2F2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isMastery ? const Color(0xFFCCA830) : AppTheme.primaryTeal)
                          .withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    isMastery ? Icons.emoji_events : Icons.verified,
                    size: 54,
                    color: isMastery ? const Color(0xFF735C00) : AppTheme.primaryTeal,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Title & Subtitle ──
              Text(
                isMastery ? 'Outstanding Defense!' : 'Good Practice Effort!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You successfully identified $correctCount out of $totalQuestions threats in "${topic.title}".',
                textAlign: TextAlign.center,
                style: GoogleFonts.atkinsonHyperlegible(
                  fontSize: 16,
                  color: AppTheme.textLight,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),

              // ── XP & Score Banner ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE3E2E2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${scorePercent.round()}%',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: isMastery ? AppTheme.primaryTeal : const Color(0xFFFE7356),
                          ),
                        ),
                        Text(
                          'Accuracy',
                          style: GoogleFonts.atkinsonHyperlegible(
                            fontSize: 14,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                    Container(height: 48, width: 1, color: const Color(0xFFE3E2E2)),
                    Column(
                      children: [
                        Text(
                          '+$earnedXp XP',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF735C00),
                          ),
                        ),
                        Text(
                          'XP Earned',
                          style: GoogleFonts.atkinsonHyperlegible(
                            fontSize: 14,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Key Learnings Card ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3F3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE3E2E2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: AppTheme.primaryTeal, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Key Safety Rules Mastered:',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...topic.questions.map((q) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check, size: 18, color: AppTheme.primaryTeal),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  q.safetyRule,
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 14.5,
                                    color: const Color(0xFF1B1C1C),
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // ── Action Buttons ──
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCCA830),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 1,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emoji_events_outlined, size: 22, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'View My Trophy Badges',
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
              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryTeal,
                    side: const BorderSide(color: AppTheme.primaryTeal, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'Return to SafeSenior Home',
                    style: GoogleFonts.atkinsonHyperlegible(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
