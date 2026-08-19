import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../state/auth_provider.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'settings_screen.dart';
import 'tip_detail_screen.dart';
import 'security_status_screen.dart';

class DailySafetyTipsScreen extends ConsumerStatefulWidget {
  const DailySafetyTipsScreen({super.key});

  @override
  ConsumerState<DailySafetyTipsScreen> createState() => _DailySafetyTipsScreenState();
}

class _DailySafetyTipsScreenState extends ConsumerState<DailySafetyTipsScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryTeal,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.shield, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'SafeSenior',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFD6ECE8),
                      backgroundImage: user?.avatarPath != null
                          ? FileImage(File(user!.avatarPath!)) as ImageProvider
                          : const NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150'),
                      child: user?.avatarPath == null && (user?.name.isEmpty ?? true)
                          ? const Icon(Icons.person, color: AppTheme.primaryTeal, size: 20)
                          : null,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // Title & Subtitle
                    Text(
                      'Daily Sanctuary',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Curated cybersecurity insights & practical senior safety guides.',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 14.5,
                        color: const Color(0xFF5E706D),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Featured Tip Card
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TipDetailScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD7EFE6),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'TODAY\'S FEATURED',
                                style: GoogleFonts.atkinsonHyperlegible(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E7558),
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Recognizing Urgency Scams',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryTeal,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Scammers often create a false sense of urgency to rush your decisions. Learn how to pause, verify, and stay protected.',
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 14,
                                color: const Color(0xFF4E5D5A),
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Text(
                                  'Read full article',
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryTeal,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_forward, size: 16, color: AppTheme.primaryTeal),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Device Check Callout Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF3F0),
                        borderRadius: BorderRadius.circular(32),
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
                                  color: AppTheme.primaryTeal,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.security, color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  'Device Check',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryTeal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Are your device's security settings up to date? Run a quick diagnostic to ensure optimal protection.",
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 14,
                              color: const Color(0xFF4E5D5A),
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SecurityStatusScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryTeal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                              child: Text('Run Diagnostic', style: GoogleFonts.atkinsonHyperlegible(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }
}
