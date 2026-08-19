import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../state/language_provider.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'settings_screen.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  final List<Map<String, String>> _languages = [
    {'code': 'en', 'badge': 'EN', 'title': 'English', 'sub': 'US / UK'},
    {'code': 'es', 'badge': 'ES', 'title': 'Español', 'sub': 'Spanish'},
    {'code': 'fr', 'badge': 'FR', 'title': 'Français', 'sub': 'French'},
    {'code': 'de', 'badge': 'DE', 'title': 'Deutsch', 'sub': 'German'},
  ];

  @override
  Widget build(BuildContext context) {
    final currentCode = ref.watch(languageProvider);

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
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFFD6ECE8),
                      child: Icon(Icons.person, color: AppTheme.primaryTeal, size: 20),
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

                    // Section Title & Subtitle
                    Text(
                      'Language',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Select your primary display & translation language.',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 14.5,
                        color: const Color(0xFF5E706D),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Language Cards List
                    ..._languages.map((lang) {
                      final isSelected = lang['code'] == currentCode;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: GestureDetector(
                          onTap: () {
                            ref.read(languageProvider.notifier).state = lang['code']!;
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: isSelected
                                  ? Border.all(color: AppTheme.primaryTeal, width: 2)
                                  : Border.all(color: Colors.transparent),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppTheme.primaryTeal : const Color(0xFFE5EFEC),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      lang['badge']!,
                                      style: GoogleFonts.atkinsonHyperlegible(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : AppTheme.primaryTeal,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lang['title']!,
                                        style: GoogleFonts.atkinsonHyperlegible(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF2C3937),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        lang['sub']!,
                                        style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, color: const Color(0xFF6B7B78)),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle, color: AppTheme.primaryTeal, size: 22)
                                else
                                  const Icon(Icons.radio_button_unchecked, color: Color(0xFFA2B0AD), size: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 16),

                    // Information Card
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF3F0),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.translate, color: AppTheme.primaryTeal, size: 24),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Scam alerts and high-urgency notifications are automatically translated into your active language.',
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 13.5,
                                color: const Color(0xFF2C3937),
                                height: 1.4,
                              ),
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
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
    );
  }
}
