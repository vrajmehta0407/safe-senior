import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../state/auth_provider.dart';

class TipDetailScreen extends ConsumerWidget {
  const TipDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar with Back Arrow
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.primaryTeal, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'SafeSenior',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFD6ECE8),
                    backgroundImage: user?.avatarPath != null
                        ? FileImage(File(user!.avatarPath!)) as ImageProvider
                        : const NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150'),
                    child: user?.avatarPath == null && (user?.name.isEmpty ?? true)
                        ? const Icon(Icons.person, color: AppTheme.primaryTeal, size: 20)
                        : null,
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
                    // Hero Banner Card
                    Container(
                      height: 260,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1563986768609-322da13575f3?w=800'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.95),
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'SCAM ALERTS',
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.terracottaRed,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'The Anatomy\nof a Phish',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryTeal,
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Article Paragraph 1
                    Text(
                      'Modern deception rarely arrives with obvious warnings. Instead, it carefully mimics the familiar voices of institutions we trust. Recognizing these subtle manipulations is the cornerstone of personal digital sovereignty.',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 15,
                        color: const Color(0xFF4E5D5A),
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Quote Callout Container
                    Container(
                      padding: const EdgeInsets.all(24),
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 4,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppTheme.terracottaRed,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              '"They don\'t hack systems anymore. They hack human trust."',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                color: AppTheme.primaryTeal,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Article Paragraph 2
                    Text(
                      'The most sophisticated attacks create artificial urgency. A message claiming a suspended account or a compromised password forces a visceral reaction, bypassing logical scrutiny.',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 15,
                        color: const Color(0xFF4E5D5A),
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Key Takeaway Card 1: Urgency Triggers
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFBE0D8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.warning_amber_rounded, color: AppTheme.terracottaRed, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Urgency Triggers',
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2C3937),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Phrases like "Act Now" or "Immediate Action Required" are designed to induce panic.',
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 13.5,
                                    color: const Color(0xFF4E5D5A),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Key Takeaway Card 2: Mismatched Links
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFDE8DF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.link_off_outlined, color: Color(0xFFD8572A), size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mismatched Links',
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2C3937),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'The displayed text rarely matches the actual destination URL when closely examined.',
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 13.5,
                                    color: const Color(0xFF4E5D5A),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
