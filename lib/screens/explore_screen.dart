import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'safety_quiz_hub_screen.dart';
import 'scam_library_screen.dart';

class ExploreDiscoverScreen extends StatefulWidget {
  const ExploreDiscoverScreen({super.key});

  @override
  State<ExploreDiscoverScreen> createState() => _ExploreDiscoverScreenState();
}

class _ExploreDiscoverScreenState extends State<ExploreDiscoverScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Scams', 'Quizzes', 'Tips', 'Alerts', 'Financial'];

  final List<_ExploreItem> _items = [
    _ExploreItem(
      title: 'Digital Arrest Scam',
      subtitle: '2026\'s most dangerous scam targeting seniors',
      category: 'Scams',
      icon: Icons.gavel_outlined,
      color: Color(0xFFB71C1C),
      isAlert: true,
      riskLevel: 'CRITICAL',
    ),
    _ExploreItem(
      title: 'Spot the Fake Bank SMS',
      subtitle: 'Can you identify a fake bank message?',
      category: 'Quizzes',
      icon: Icons.quiz_outlined,
      color: Color(0xFF006565),
      isAlert: false,
      riskLevel: '',
    ),
    _ExploreItem(
      title: 'KYC Update Fraud',
      subtitle: 'Don\'t share OTP for fake KYC updates',
      category: 'Financial',
      icon: Icons.credit_card_outlined,
      color: Color(0xFFB71C1C),
      isAlert: true,
      riskLevel: 'HIGH',
    ),
    _ExploreItem(
      title: 'Grandchild Impersonation',
      subtitle: 'Learn how scammers pretend to be family',
      category: 'Scams',
      icon: Icons.family_restroom,
      color: Color(0xFFE65100),
      isAlert: true,
      riskLevel: 'HIGH',
    ),
    _ExploreItem(
      title: '5 Ways to Spot Phishing',
      subtitle: 'Simple tips to stay safe online',
      category: 'Tips',
      icon: Icons.tips_and_updates_outlined,
      color: Color(0xFF006565),
      isAlert: false,
      riskLevel: '',
    ),
    _ExploreItem(
      title: 'Romance Scam Training',
      subtitle: 'How online friendship can become a trap',
      category: 'Quizzes',
      icon: Icons.favorite_border,
      color: Color(0xFF880E4F),
      isAlert: false,
      riskLevel: '',
    ),
    _ExploreItem(
      title: 'Electricity Bill Scam',
      subtitle: 'Never pay via unknown links or apps',
      category: 'Financial',
      icon: Icons.electric_bolt_outlined,
      color: Color(0xFFB71C1C),
      isAlert: true,
      riskLevel: 'MEDIUM',
    ),
    _ExploreItem(
      title: 'Medicare Fraud Alert',
      subtitle: 'Protect your health insurance benefits',
      category: 'Financial',
      icon: Icons.medical_services_outlined,
      color: Color(0xFFB71C1C),
      isAlert: true,
      riskLevel: 'HIGH',
    ),
    _ExploreItem(
      title: 'Tech Support Scam Quiz',
      subtitle: 'Would you fall for a fake Microsoft call?',
      category: 'Quizzes',
      icon: Icons.computer_outlined,
      color: Color(0xFF006565),
      isAlert: false,
      riskLevel: '',
    ),
    _ExploreItem(
      title: 'Part-Time Job Trap',
      subtitle: 'Too-good-to-be-true offers are always scams',
      category: 'Scams',
      icon: Icons.work_outline,
      color: Color(0xFFE65100),
      isAlert: true,
      riskLevel: 'MEDIUM',
    ),
  ];

  List<_ExploreItem> get _filteredItems => _selectedCategory == 'All'
      ? _items
      : _items.where((i) => i.category == _selectedCategory).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppTheme.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Explore & Learn',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ScamLibraryScreen()),
                    ),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.search, size: 20, color: AppTheme.textPrimary),
                    ),
                  ),
                ],
              ),
            ),

            // Category filter
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryTeal : Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryTeal : AppTheme.dividerColor,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: GoogleFonts.atkinsonHyperlegible(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Featured banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SafetyQuizHubScreen())),
                child: Container(
                  height: 100,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryTeal, const Color(0xFF004D4D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                '🔥 TRENDING',
                                style: GoogleFonts.atkinsonHyperlegible(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Take the Safety Quiz',
                              style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                            Text(
                              'Test your scam knowledge',
                              style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, color: Colors.white.withOpacity(0.8)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.quiz_outlined, color: Colors.white, size: 30),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Items grid
            Expanded(
              child: _filteredItems.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filteredItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _buildExploreCard(_filteredItems[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreCard(_ExploreItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: item.color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                      ),
                    ),
                    if (item.isAlert && item.riskLevel.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          item.riskLevel,
                          style: GoogleFonts.atkinsonHyperlegible(fontSize: 10, fontWeight: FontWeight.w700, color: item.color),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    item.category,
                    style: GoogleFonts.atkinsonHyperlegible(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 20),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_outlined, size: 60, color: AppTheme.textSecondary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('No results in "${_selectedCategory}"',
              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _ExploreItem {
  final String title;
  final String subtitle;
  final String category;
  final IconData icon;
  final Color color;
  final bool isAlert;
  final String riskLevel;

  const _ExploreItem({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.color,
    required this.isAlert,
    required this.riskLevel,
  });
}
