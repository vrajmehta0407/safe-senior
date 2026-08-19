import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'home_screen.dart';
import 'achievements_screen.dart';

class SafetyMilestoneCelebrationScreen extends StatefulWidget {
  final String milestoneName;
  final String milestoneDescription;
  final String xpEarned;
  final IconData milestoneIcon;
  final Color milestoneColor;

  const SafetyMilestoneCelebrationScreen({
    super.key,
    this.milestoneName = '7-Day Safety Streak!',
    this.milestoneDescription = 'You\'ve been scam-free for a whole week. Your vigilance is protecting you!',
    this.xpEarned = '+150',
    this.milestoneIcon = Icons.local_fire_department,
    this.milestoneColor = AppTheme.celebrationGold,
  });

  @override
  State<SafetyMilestoneCelebrationScreen> createState() => _SafetyMilestoneCelebrationScreenState();
}

class _SafetyMilestoneCelebrationScreenState extends State<SafetyMilestoneCelebrationScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () => _scaleController.forward());
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Background particles effect
            ...List.generate(12, (i) => _buildParticle(i)),

            // Main content
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Celebration icon
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            widget.milestoneColor.withOpacity(0.3),
                            widget.milestoneColor.withOpacity(0.0),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.milestoneColor.withOpacity(0.4),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: widget.milestoneColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: widget.milestoneColor.withOpacity(0.5), width: 2),
                          ),
                          child: Icon(widget.milestoneIcon, color: widget.milestoneColor, size: 52),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Celebration text
                  Text(
                    '🎉 Congratulations!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.7),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      widget.milestoneName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      widget.milestoneDescription,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.75),
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // XP reward box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    decoration: BoxDecoration(
                      color: widget.milestoneColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: widget.milestoneColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: widget.milestoneColor, size: 28),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.xpEarned} XP Earned',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: widget.milestoneColor,
                              ),
                            ),
                            Text(
                              'Added to your safety score',
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.milestoneColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                              elevation: 0,
                            ),
                            child: Text(
                              'View All Achievements',
                              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                            (route) => false,
                          ),
                          child: Text(
                            'Back to Home',
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticle(int index) {
    final positions = [
      [0.1, 0.1], [0.9, 0.1], [0.2, 0.3], [0.8, 0.2], [0.05, 0.5],
      [0.95, 0.5], [0.15, 0.7], [0.85, 0.7], [0.3, 0.9], [0.7, 0.9],
      [0.5, 0.05], [0.5, 0.95],
    ];

    return Positioned(
      left: MediaQuery.of(context).size.width * positions[index][0],
      top: MediaQuery.of(context).size.height * positions[index][1],
      child: AnimatedBuilder(
        animation: _scaleController,
        builder: (_, __) => Opacity(
          opacity: _scaleController.value,
          child: Icon(
            index % 3 == 0 ? Icons.star : index % 3 == 1 ? Icons.circle : Icons.diamond,
            size: (index % 3 + 1) * 8.0,
            color: [widget.milestoneColor, Colors.white, const Color(0xFFFFE082)][index % 3].withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}
