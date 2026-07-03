import 'package:flutter/material.dart';
import '../theme.dart';
import 'phishing_guide_screen.dart';

class SecurityTipsListScreen extends StatefulWidget {
  const SecurityTipsListScreen({super.key});

  @override
  State<SecurityTipsListScreen> createState() => _SecurityTipsListScreenState();
}

class _SecurityTipsListScreenState extends State<SecurityTipsListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC), // Very light blue/grey
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Security Tips',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryDarkBlue,
              ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search security tips...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Featured Tip
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                          child: Image.network(
                            'https://images.unsplash.com/photo-1563206767-5b18f218e8de?q=80&w=2069&auto=format&fit=crop', // Tech/Security placeholder
                            height: 140,
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
                              color: AppTheme.primaryDarkBlue,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'Featured Tip',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How to Spot a Phishing\nEmail',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryDarkBlue,
                                  height: 1.2,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Learn the simple red flags that show an email might be trying to trick you into sharing passwords.',
                            style: TextStyle(color: Colors.black87, height: 1.5, fontSize: 14),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const PhishingGuideScreen()));
                              },
                              icon: const Icon(Icons.menu_book),
                              label: const Text('Read Guide', style: TextStyle(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1964B0), // Blue
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
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
                        onPressed: () {},
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
            _buildBottomNavItem(icon: Icons.people_outline, label: 'Family', isSelected: false), // In image 2, family is 3rd
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
