import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../state/auth_provider.dart';
import '../state/guardian_provider.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'settings_screen.dart';

class ActivityFeedScreen extends ConsumerStatefulWidget {
  const ActivityFeedScreen({super.key});

  @override
  ConsumerState<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends ConsumerState<ActivityFeedScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final guardians = ref.watch(guardianListProvider);
    final primaryGuardian = ref.watch(primaryGuardianProvider);

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

                    // Top Hero Card: NETWORK STATUS
                    Container(
                      width: double.infinity,
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
                          Text(
                            'NETWORK STATUS',
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF5E706D),
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Secure & Active',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F6F4),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.people_alt_outlined, color: AppTheme.terracottaRed, size: 22),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${guardians.length + 1} Members',
                                        style: GoogleFonts.atkinsonHyperlegible(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF2C3937),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F6F4),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.cast_outlined, color: AppTheme.primaryTeal, size: 22),
                                      const SizedBox(height: 6),
                                      Text(
                                        '3 Devices',
                                        style: GoogleFonts.atkinsonHyperlegible(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF2C3937),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Section Title: ACTIVITY FEED
                    Text(
                      'ACTIVITY FEED',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5E706D),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Activity Item 1: Guardian Connection Event
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${primaryGuardian?.name ?? "Guardian"} Connected',
                                style: GoogleFonts.atkinsonHyperlegible(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryTeal,
                                ),
                              ),
                              Text(
                                'Just Now',
                                style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, color: const Color(0xFF8FA19E)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Active protective session established with ${primaryGuardian?.name ?? "Mom"}.',
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 14,
                              color: const Color(0xFF4E5D5A),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Activity Item 2: System Update
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'System Update',
                                style: GoogleFonts.atkinsonHyperlegible(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryTeal,
                                ),
                              ),
                              Text(
                                '10:42 AM',
                                style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, color: const Color(0xFF8FA19E)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Security definitions successfully updated for the home network.',
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 14,
                              color: const Color(0xFF4E5D5A),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Activity Item 2: New Device Detected
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'New Device Detected',
                                style: GoogleFonts.atkinsonHyperlegible(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.terracottaRed,
                                ),
                              ),
                              Text(
                                'Yesterday, 8:15 PM',
                                style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, color: const Color(0xFF8FA19E)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'An unrecognized phone attempted to connect to the guest network.',
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 14,
                              color: const Color(0xFF4E5D5A),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBE0D8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                'Review Connection',
                                style: GoogleFonts.atkinsonHyperlegible(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.terracottaRed,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Activity Item 3: Family Member Arrived
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Family Member\nArrived',
                                style: GoogleFonts.atkinsonHyperlegible(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryTeal,
                                  height: 1.2,
                                ),
                              ),
                              Text(
                                'Yesterday, 5:30\nPM',
                                textAlign: TextAlign.right,
                                style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, color: const Color(0xFF8FA19E)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sarah\'s device connected to the home network.',
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 14,
                              color: const Color(0xFF4E5D5A),
                              height: 1.4,
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
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }
}
