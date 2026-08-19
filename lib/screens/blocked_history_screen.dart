import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../state/auth_provider.dart';
import '../services/platform_capabilities.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'settings_screen.dart';

class BlockedHistoryScreen extends ConsumerStatefulWidget {
  const BlockedHistoryScreen({super.key});

  @override
  ConsumerState<BlockedHistoryScreen> createState() => _BlockedHistoryScreenState();
}

class _BlockedHistoryScreenState extends ConsumerState<BlockedHistoryScreen> {
  Widget _buildAndroidOnlyBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFB74D), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFF57C00), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'SMS scanning and call blocking require Android system permissions '
              "that Apple doesn't allow — but your Guardian alerts and manual "
              'scam checks still work here.',
              style: GoogleFonts.atkinsonHyperlegible(
                fontSize: 13,
                color: const Color(0xFF5D4037),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
  final List<Map<String, String>> _blockedItems = [
    {
      'sender': '+91 98210 44921',
      'reason': 'Digital Arrest & Bail Extortion Demand',
      'time': 'Today, 10:42 AM',
      'body': 'Babuji, I am under Customs arrest at Delhi Airport. Transfer ₹50,000 immediately via UPI to avoid jail...',
    },
    {
      'sender': 'SBI YONO KYC Helpline',
      'reason': 'Phishing Link & False Account Lock',
      'time': 'Yesterday, 4:15 PM',
      'body': 'Your SBI YONO access expires today. Update PAN card at http://sbi-kyc-verify.in to prevent ₹5,000 fine.',
    },
    {
      'sender': 'MSEDCL Bijli Alert',
      'reason': 'Fake Disconnection Threat & APK',
      'time': '3 days ago',
      'body': 'Dear consumer, your electricity will be disconnected tonight at 9:30 PM. Call officer at +91 98765 43210 immediately.',
    },
  ];

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

            if (!PlatformCapabilities.canMonitorSms) _buildAndroidOnlyBanner(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // Title & Subtitle
                    Text(
                      'Blocked Threats',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Messages and calls neutralized by your sanctuary defenses.',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 14.5,
                        color: const Color(0xFF5E706D),
                      ),
                    ),
                    const SizedBox(height: 24),

                    ..._blockedItems.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
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
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFBE0D8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.block, color: AppTheme.terracottaRed, size: 20),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['sender']!,
                                          style: GoogleFonts.atkinsonHyperlegible(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF2C3937),
                                          ),
                                        ),
                                        Text(
                                          item['time']!,
                                          style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, color: const Color(0xFF8FA19E)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFBE0D8),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Blocked',
                                      style: GoogleFonts.atkinsonHyperlegible(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.terracottaRed,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                item['body']!,
                                style: GoogleFonts.atkinsonHyperlegible(
                                  fontSize: 14,
                                  color: const Color(0xFF4E5D5A),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
    );
  }
}
