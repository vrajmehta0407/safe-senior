import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../state/auth_provider.dart';
import '../state/scanned_messages_provider.dart';
import '../services/platform_capabilities.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'settings_screen.dart';
import 'warning_alert_screen.dart';

class ScannedMessagesScreen extends ConsumerStatefulWidget {
  const ScannedMessagesScreen({super.key});

  @override
  ConsumerState<ScannedMessagesScreen> createState() => _ScannedMessagesScreenState();
}

class _ScannedMessagesScreenState extends ConsumerState<ScannedMessagesScreen> {
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
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final messages = ref.watch(scannedMessagesProvider);

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

                    // Section Title: Scanned Messages
                    Text(
                      'Scanned Messages',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Automated SMS & email threat analysis feed.',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 14.5,
                        color: const Color(0xFF5E706D),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Dynamic List of Messages from Riverpod
                    ...messages.map((msg) {
                      final isScam = msg.riskLevelIndex == 2 || msg.isBlocked;
                      final isSuspicious = msg.riskLevelIndex == 1 && !msg.isBlocked;

                      String tagText = '✓ Safe';
                      Color tagBgColor = const Color(0xFFD7EFE6);
                      Color tagTextColor = const Color(0xFF1E7558);

                      if (isScam) {
                        tagText = '⚠ Scam';
                        tagBgColor = const Color(0xFFFBE0D8);
                        tagTextColor = AppTheme.terracottaRed;
                      } else if (isSuspicious) {
                        tagText = '⚡ Suspicious';
                        tagBgColor = const Color(0xFFFFF3CD);
                        tagTextColor = const Color(0xFF856404);
                      }

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
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: tagBgColor,
                                    child: Text(
                                      msg.sender.isNotEmpty ? msg.sender[0].toUpperCase() : '?',
                                      style: GoogleFonts.atkinsonHyperlegible(
                                        color: tagTextColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          msg.sender,
                                          style: GoogleFonts.atkinsonHyperlegible(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF2C3937),
                                          ),
                                        ),
                                        Text(
                                          '${msg.receivedAt.hour}:${msg.receivedAt.minute.toString().padLeft(2, '0')}',
                                          style: GoogleFonts.atkinsonHyperlegible(
                                            fontSize: 12,
                                            color: const Color(0xFF8FA19E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: tagBgColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      tagText,
                                      style: GoogleFonts.atkinsonHyperlegible(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: tagTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                msg.maskedBody,
                                style: GoogleFonts.atkinsonHyperlegible(
                                  fontSize: 14.5,
                                  color: const Color(0xFF4E5D5A),
                                  height: 1.45,
                                ),
                              ),
                              if (isScam || isSuspicious) ...[
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          ref.read(scannedMessagesProvider.notifier).markReported(msg);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => const WarningAlertScreen()),
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppTheme.terracottaRed,
                                          side: const BorderSide(color: AppTheme.terracottaRed),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        ),
                                        child: Text('Block & Report', style: GoogleFonts.atkinsonHyperlegible(fontWeight: FontWeight.bold, fontSize: 13)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 12),
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
