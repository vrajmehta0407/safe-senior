import 'package:flutter/material.dart';
import '../theme.dart';
import 'settings_screen.dart';
import 'guardian_assistant_screen.dart';
import 'security_tips_list_screen.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
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
          'Help & Support',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryDarkBlue,
              ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.textDark),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How can we help you today?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDarkBlue,
                    ),
              ),
              const SizedBox(height: 12),
              
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search for help...',
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

              // SOS Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828), // Dark red
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'EMERGENCY SOS',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.1),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Chat and Call Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const GuardianAssistantScreen()));
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Chat with Us', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1964B0), // Blue
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call_outlined),
                  label: const Text('Call Support', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D2546), // Dark Blue
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Browse Categories
              Text(
                'Browse Categories',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDarkBlue,
                    ),
              ),
              const SizedBox(height: 16),
              
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1, // Adjust based on visual proportion
                children: [
                  _buildCategoryCard(
                    title: 'Getting\nStarted',
                    icon: null, // Just a circle
                  ),
                  _buildCategoryCard(
                    title: 'Security\nTips',
                    icon: Icons.shield_outlined,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityTipsListScreen()));
                    },
                  ),
                  _buildCategoryCard(
                    title: 'Billing',
                    icon: Icons.payment_outlined,
                  ),
                  _buildCategoryCard(
                    title: 'App\nSettings',
                    icon: Icons.settings_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Frequent Questions
              Text(
                'Frequent Questions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDarkBlue,
                    ),
              ),
              const SizedBox(height: 16),
              
              _buildFAQItem('How do I block a caller?'),
              const SizedBox(height: 12),
              _buildFAQItem('Is my data safe?'),
              const SizedBox(height: 12),
              _buildFAQItem('How do I invite a family\nmember?'),
              
              const SizedBox(height: 32),

              // Bottom Promo Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLightBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryLightBlue.withValues(alpha: 0.4),
                    style: BorderStyle.solid,
                    // Note: Flutter doesn't have a built-in dashed border for containers without a package, 
                    // so we use a solid light blue border which looks similar enough, or we could draw one.
                    // For simplicity, a solid subtle border is used here.
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=2076&auto=format&fit=crop', // Support agent image
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '"We\'re here to ensure your digital life is safe and simple."',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: AppTheme.primaryDarkBlue,
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
      
      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4FA), // Very light blue/grey matching bottom nav
          border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomNavItem(icon: Icons.home_outlined, label: 'Home', isSelected: false),
            _buildBottomNavItem(icon: Icons.shield_outlined, label: 'Security', isSelected: false),
            _buildBottomNavItem(icon: Icons.help_outline, label: 'Support', isSelected: true), // Currently on Support
            _buildBottomNavItem(icon: Icons.people_outline, label: 'Family', isSelected: false),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({required String title, IconData? icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF3F5FA), // Light grey/blue background for cards
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFF82B1FF), // Light blue circle
                shape: BoxShape.circle,
              ),
              child: icon != null ? Icon(icon, color: AppTheme.primaryDarkBlue, size: 24) : null,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14),
        ),
        trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
        onTap: () {},
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
