import 'package:flutter/material.dart';
import '../theme.dart';

class PhishingGuideScreen extends StatefulWidget {
  const PhishingGuideScreen({super.key});

  @override
  State<PhishingGuideScreen> createState() => _PhishingGuideScreenState();
}

class _PhishingGuideScreenState extends State<PhishingGuideScreen> {
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
              Text(
                'How to Spot a\nPhishing Email',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryDarkBlue,
                      height: 1.1,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Phishing is when scammers send fake emails to steal your information. Learn the 4 major "Red Flags" to stay protected.',
                style: TextStyle(color: Colors.black87, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),

              // Flag 1
              _buildFlagCard(
                icon: Icons.block,
                title: '1. Mismatched\nSender',
                subtitle: 'Always check the email address, not just the name.',
                content: Column(
                  children: [
                    _buildExampleBox(
                      isFake: true,
                      label: 'FAKE:',
                      title: 'Guardian Trust Bank',
                      email: 'support@guardian-trust-security-alert.net',
                    ),
                    const SizedBox(height: 12),
                    _buildExampleBox(
                      isFake: false,
                      label: 'REAL:',
                      title: 'Guardian Trust Bank',
                      email: 'support@guardiantrust.com',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Flag 2
              _buildFlagCard(
                icon: Icons.timer_outlined,
                title: '2. Urgent Language',
                subtitle: 'Scammers want you to panic so you don\'t think clearly.',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildUrgentBadge('Act Now!'),
                        _buildUrgentBadge('Account Suspended'),
                        _buildUrgentBadge('Immediate Payment'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Real banks will never threaten to delete your account in an email.',
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black87, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Flag 3
              _buildFlagCard(
                icon: Icons.link,
                title: '3. Suspicious Links',
                subtitle: 'Check where a link goes without clicking it.',
                content: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text('Click here to verify your identity:', style: TextStyle(fontSize: 13)),
                          const SizedBox(height: 8),
                          Text(
                            'www.guardiantrust.com/verify',
                            style: TextStyle(
                              color: Colors.blue[700],
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Hover Preview
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.topCenter,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(top: 16, bottom: 12, left: 12, right: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE3EBF8), // Light blue bg
                                  border: Border.all(color: const Color(0xFFC62828), style: BorderStyle.solid), // Should be dashed, solid for simplicity
                                ),
                                child: Text(
                                  'http://scam-site-123.xyz/steal-password',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Color(0xFFC62828), fontSize: 12), // Red text
                                ),
                              ),
                              Positioned(
                                top: -10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  color: const Color(0xFFC62828),
                                  child: const Text(
                                    'HOVER PREVIEW',
                                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.5),
                        children: [
                          const TextSpan(text: 'On a computer, hover your mouse over the link. On a phone, '),
                          const TextSpan(text: 'long-press', style: TextStyle(fontWeight: FontWeight.bold)),
                          const TextSpan(text: ' to see the real address.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Flag 4
              _buildFlagCard(
                icon: Icons.person_outline,
                title: '4. Generic Greetings',
                subtitle: 'Legitimate companies usually know your name.',
                content: Column(
                  children: [
                    _buildGreetingBox(
                      isFake: true,
                      greeting: '"Dear Customer,"',
                      description: 'Generic & Suspicious',
                    ),
                    const SizedBox(height: 12),
                    _buildGreetingBox(
                      isFake: false,
                      greeting: '"Dear Mr. Thompson,"',
                      description: 'Personalized & Trusted',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Still Not Sure Block
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C3A63), // Dark blue
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.help_outline, color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Still Not Sure?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'If you\'re worried about an email you received, don\'t click anything. Call our dedicated security line immediately.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.call),
                        label: const Text('Call for Help', style: TextStyle(fontWeight: FontWeight.bold)),
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
            _buildBottomNavItem(icon: Icons.people_outline, label: 'Family', isSelected: false),
            _buildBottomNavItem(icon: Icons.help_outline, label: 'Support', isSelected: true),
          ],
        ),
      ),
    );
  }

  Widget _buildFlagCard({required IconData icon, required String title, required String subtitle, required Widget content}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDF7F7), // Very faint red bg behind the card
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFDF7F7),
          borderRadius: BorderRadius.circular(8),
          border: const Border(
            left: BorderSide(color: Color(0xFFC62828), width: 4), // Red left border
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8E6E6), // Pinkish circle
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: const Color(0xFFC62828), size: 20), // Red icon
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
                        style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildExampleBox({required bool isFake, required String label, required String title, required String email}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFake ? const Color(0xFFF8E6E6) : const Color(0xFFE3EBF8), // Light red or light blue
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isFake ? const Color(0xFFC62828).withValues(alpha: 0.3) : AppTheme.primaryDarkBlue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isFake ? const Color(0xFFC62828) : AppTheme.primaryDarkBlue,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 2),
          Text(
            email,
            style: TextStyle(
              color: isFake ? const Color(0xFFC62828) : AppTheme.primaryDarkBlue,
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8E6E6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC62828)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildGreetingBox({required bool isFake, required String greeting, required String description}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFake ? const Color(0xFFFDF7F7) : Colors.white, // Very faint red or white
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isFake ? const Color(0xFFC62828).withValues(alpha: 0.2) : AppTheme.primaryDarkBlue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            isFake ? Icons.cancel_outlined : Icons.check_circle_outline,
            color: isFake ? const Color(0xFFC62828) : AppTheme.primaryDarkBlue,
            size: 20,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 2),
              Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
            ],
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
              color: const Color(0xFF82B1FF).withValues(alpha: 0.8),
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
