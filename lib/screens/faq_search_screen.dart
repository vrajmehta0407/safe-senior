import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import '../state/auth_provider.dart';
import '../widgets/app_bottom_nav_bar.dart';

class FaqSearchScreen extends ConsumerStatefulWidget {
  const FaqSearchScreen({super.key});

  @override
  ConsumerState<FaqSearchScreen> createState() => _FaqSearchScreenState();
}

class _FaqSearchScreenState extends ConsumerState<FaqSearchScreen> {
  final Map<String, bool> _expanded = {
    'How do I add a family member?': false,
    'What does the amber alert mean?': false,
    'How to update emergency contacts?': false,
  };

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
                  children: [
                    const SizedBox(height: 10),

                    // Support Arc Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F6F4),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryTeal,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.headset_mic_outlined, color: Colors.white, size: 26),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'How can we help?',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We\'re here to ensure your safety and peace of mind.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 14.5,
                              color: const Color(0xFF5E706D),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Search Field
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0xFFE2EFEA)),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search for answers...',
                          hintStyle: GoogleFonts.atkinsonHyperlegible(color: const Color(0xFF8FA19E), fontSize: 14),
                          icon: const Icon(Icons.search, color: Color(0xFF8FA19E), size: 22),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category Filter Pills
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTeal,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Security',
                              style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE2EFEA)),
                            ),
                            child: Text(
                              'Account',
                              style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF2C3937)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE2EFEA)),
                            ),
                            child: Text(
                              'Alerts',
                              style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF2C3937)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Common Questions Card Container
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Common Questions',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                          const SizedBox(height: 20),

                          ..._expanded.entries.map((entry) {
                            final question = entry.key;
                            final isExp = entry.value;

                            return Column(
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    question,
                                    style: GoogleFonts.atkinsonHyperlegible(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2C3937),
                                    ),
                                  ),
                                  trailing: Icon(
                                    isExp ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                    color: AppTheme.primaryTeal,
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _expanded[question] = !isExp;
                                    });
                                  },
                                ),
                                if (isExp)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Text(
                                      'You can manage this directly from your Guardian Contacts and Security Preferences settings.',
                                      style: GoogleFonts.atkinsonHyperlegible(fontSize: 13.5, color: const Color(0xFF5E706D), height: 1.4),
                                    ),
                                  ),
                                const Divider(height: 1, color: Color(0xFFEEF3EE)),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Call Helpline Dark Teal Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final Uri uri = Uri(scheme: 'tel', path: '18005550199');
                          if (await canLaunchUrl(uri)) await launchUrl(uri);
                        },
                        icon: const Icon(Icons.phone_outlined, size: 20),
                        label: Text(
                          'Call Helpline',
                          style: GoogleFonts.atkinsonHyperlegible(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                          shadowColor: AppTheme.primaryTeal.withValues(alpha: 0.3),
                        ),
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
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
    );
  }
}
