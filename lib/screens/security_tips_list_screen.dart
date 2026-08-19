import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import '../state/auth_provider.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'settings_screen.dart';
import 'tip_detail_screen.dart';

class SecurityTipsListScreen extends ConsumerStatefulWidget {
  const SecurityTipsListScreen({super.key});

  @override
  ConsumerState<SecurityTipsListScreen> createState() => _SecurityTipsListScreenState();
}

class _SecurityTipsListScreenState extends ConsumerState<SecurityTipsListScreen> {
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
                      backgroundColor: AppTheme.primaryTeal,
                      child: Text(
                        'SU',
                        style: GoogleFonts.atkinsonHyperlegible(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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

                    // Title & Description
                    Text(
                      'Sanctuary Insights',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Vigilant curation for a secure digital life.',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 14.5,
                        color: const Color(0xFF5E706D),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Featured Card: The Anatomy of a Phishing Attack in 2024
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TipDetailScreen()),
                        );
                      },
                      child: Container(
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
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                                  child: Image.network(
                                    'https://images.unsplash.com/photo-1563986768609-322da13575f3?w=600',
                                    height: 190,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 16,
                                  left: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryTeal,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      'ESSENTIAL',
                                      style: GoogleFonts.atkinsonHyperlegible(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(22),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'The Anatomy of a Phishing Attack in 2024',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2C3937),
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Understanding the subtle psychological triggers modern...',
                                    style: GoogleFonts.atkinsonHyperlegible(
                                      fontSize: 14,
                                      color: const Color(0xFF4E5D5A),
                                      height: 1.45,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Text(
                                        'READ MORE',
                                        style: GoogleFonts.atkinsonHyperlegible(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryTeal,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.arrow_forward, size: 16, color: AppTheme.primaryTeal),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 2: NETWORK: Securing the Family Wi-Fi
                    Container(
                      padding: const EdgeInsets.all(16),
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
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              'https://images.unsplash.com/photo-1544717305-2782549b5136?w=150',
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NETWORK',
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.terracottaRed,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Securing the Family Wi-Fi',
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2C3937),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 3: DEVICES: Zero-Day Vulnerability Guide
                    Container(
                      padding: const EdgeInsets.all(16),
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
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DEVICES',
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryTeal,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Zero-Day Vulnerability Guide',
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2C3937),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=150',
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 4: WEEKLY DIGEST: 5 Habits for a Calmer Digital Presence
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
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
                            'WEEKLY DIGEST',
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTeal,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '5 Habits for a Calmer Digital Presence',
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2C3937),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // List Items
                    _buildTipCard(
                      icon: Icons.phone_in_talk,
                      title: 'Phone Safety',
                      subtitle: 'Simple tricks to identify and block suspicious scam callers instantly.',
                    ),
                    const SizedBox(height: 16),
                    _buildTipCard(
                      icon: Icons.lock_outline,
                      title: 'Strong Passwords',
                      subtitle: 'Easy methods to create passwords that are easy to remember but hard to hack.',
                    ),
                    const SizedBox(height: 16),
                    _buildTipCard(
                      icon: Icons.share_outlined,
                      title: 'Social Media',
                      subtitle: 'Keep your private family moments shared safely without unwanted eyes.',
                    ),
                    const SizedBox(height: 16),
                    _buildTipCard(
                      icon: Icons.alternate_email,
                      title: 'Email Security',
                      subtitle: 'Your guide to opening links safely and spotting fake business emails.',
                    ),
                    const SizedBox(height: 24),

                    // Feeling Unsure Footer
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBE9E7), // Light red bg
                        borderRadius: BorderRadius.circular(8),
                        border: const Border(
                          left: BorderSide(color: Color(0xFFC62828), width: 4), // Red left border
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Feeling Unsure?',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC62828), fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'If you think you\'ve clicked something suspicious, call our support team immediately.',
                            style: TextStyle(color: Color(0xFF8B0000), fontSize: 13, height: 1.5),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final uri = Uri(scheme: 'tel', path: '100');
                                if (await canLaunchUrl(uri)) await launchUrl(uri);
                              },
                              icon: const Icon(Icons.call_outlined),
                              label: const Text('Call Guardian Support', style: TextStyle(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC62828), // Dark red
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4FA),
          border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomNavItem(icon: Icons.home_outlined, label: 'Home', isSelected: false),
            _buildBottomNavItem(icon: Icons.shield_outlined, label: 'Security', isSelected: false),
            _buildBottomNavItem(icon: Icons.people_outline, label: 'Family', isSelected: false),
            _buildBottomNavItem(icon: Icons.help_outline, label: 'Support', isSelected: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard({required IconData icon, required String title, required String subtitle}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFE3EBF8), // Light blue circle
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryDarkBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem({required IconData icon, required String label, required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: isSelected
          ? BoxDecoration(
              color: const Color(0xFF82B1FF).withValues(alpha: 0.8), // Light blue pill
              borderRadius: BorderRadius.circular(20),
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? AppTheme.primaryDarkBlue : Colors.black87),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.primaryDarkBlue : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
