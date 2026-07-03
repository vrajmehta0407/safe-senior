import 'package:flutter/material.dart';
import '../theme.dart';
import 'plan_selection_screen.dart';

class PremiumSalesScreen extends StatelessWidget {
  const PremiumSalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppTheme.textDark),
          onPressed: () {},
        ),
        title: Text(
          'Safe Senior',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: AppTheme.textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Hero Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C3A63), // Dark blue background
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC78B3F), // Orange/gold color
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.workspace_premium, color: Colors.white, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'SAFE SENIOR PREMIUM',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Enhanced Protection For Your Peace of Mind',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  height: 1.2,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Join thousands of families who trust our elite guardianship services to keep their loved ones safe every hour of the day.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  height: 1.5,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Feature 1
                    _buildFeatureCard(
                      context,
                      icon: Icons.support_agent,
                      iconBgColor: AppTheme.primaryLightBlue.withValues(alpha: 0.8),
                      iconColor: AppTheme.primaryDarkBlue,
                      title: '24/7 Human Guardian Support',
                      description: 'Real people, not just machines, ready to assist with any safety concern or emergency at the touch of a button.',
                    ),
                    const SizedBox(height: 16),

                    // Feature 2
                    _buildFeatureCard(
                      context,
                      icon: Icons.verified_user_outlined,
                      iconBgColor: const Color(0xFFFDE8D0), // Light orange
                      iconColor: const Color(0xFF8B4513), // Brown
                      title: 'Advanced AI Scam Detection',
                      description: 'Sophisticated monitoring that identifies and blocks predatory calls, emails, and texts before they can do harm.',
                    ),
                    const SizedBox(height: 16),

                    // Feature 3
                    _buildFeatureCard(
                      context,
                      icon: Icons.family_restroom,
                      iconBgColor: AppTheme.primaryLightBlue.withValues(alpha: 0.3),
                      iconColor: AppTheme.primaryDarkBlue,
                      title: 'Real-time Family Notifications',
                      description: 'Keep your entire support circle informed with instant alerts about location, wellness checks, and safety events.',
                    ),
                    const SizedBox(height: 24),

                    // Testimonial
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1573676047167-9d7a224a1b02?q=80&w=2069&auto=format&fit=crop'), // Placeholder for smiling senior woman
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
                        ),
                      ),
                      alignment: Alignment.bottomLeft,
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '"I feel so much more confident knowing someone is always looking out for me." — Martha R.',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom CTA Area
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryLightBlue.withValues(alpha: 0.15),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PlanSelectionScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1964B0), // Brand blue
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.explore_outlined),
                          SizedBox(width: 8),
                          Text('Explore Plans', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Plans start at just \$14.99/mo',
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, {required IconData icon, required Color iconBgColor, required Color iconColor, required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDarkBlue,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textDark.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
