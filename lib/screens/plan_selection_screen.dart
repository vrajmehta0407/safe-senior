import 'package:flutter/material.dart';
import '../theme.dart';
import 'checkout_screen.dart';

class PlanSelectionScreen extends StatefulWidget {
  const PlanSelectionScreen({super.key});

  @override
  State<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends State<PlanSelectionScreen> {
  String _selectedPlan = 'annual'; // 'monthly' or 'annual'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Very light grey bg as in design
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLightBlue.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_outlined, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              
              Text(
                'Choose Your\nProtection Plan',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryDarkBlue,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
              ),
              const SizedBox(height: 16),
              
              Text(
                'Get 24/7 digital guardianship and immediate scam protection for you and your family.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textDark.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 32),

              // Monthly Plan
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPlan = 'monthly';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedPlan == 'monthly' ? AppTheme.primaryDarkBlue : Colors.grey.withValues(alpha: 0.3),
                      width: _selectedPlan == 'monthly' ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BASIC PROTECTION',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                                letterSpacing: 1.1,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Monthly Plan',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryDarkBlue,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$9.99 / month',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textDark,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _selectedPlan == 'monthly' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        color: _selectedPlan == 'monthly' ? AppTheme.primaryDarkBlue : Colors.grey,
                        size: 32,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Annual Plan (Selected by default in design)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPlan = 'annual';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedPlan == 'annual' ? AppTheme.primaryDarkBlue : Colors.grey.withValues(alpha: 0.3),
                      width: _selectedPlan == 'annual' ? 2 : 1,
                    ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PREMIUM PROTECTION',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryDarkBlue,
                                    letterSpacing: 1.1,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Annual Plan',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryDarkBlue,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '\$89.99',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryDarkBlue,
                                          ),
                                    ),
                                    Text(
                                      ' / year',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: AppTheme.textDark,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Equivalent to \$7.50/month',
                                  style: TextStyle(
                                    color: AppTheme.primaryDarkBlue,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            _selectedPlan == 'annual' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                            color: _selectedPlan == 'annual' ? AppTheme.primaryDarkBlue : Colors.grey,
                            size: 32,
                          ),
                        ],
                      ),
                      Positioned(
                        top: -32,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDE8D0), // Light orange
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Best Value',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Features list
              _buildFeatureRow(context, Icons.verified_user_outlined, 'Cancel Anytime', 'No long-term contracts, total flexibility.'),
              const SizedBox(height: 16),
              _buildFeatureRow(context, Icons.support_agent, '24/7 Human Help', 'Reach a real person in under 60 seconds.'),
              
              const SizedBox(height: 32),

              // Checkout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1964B0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline),
                      SizedBox(width: 8),
                      Text('Continue to Checkout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Maybe later
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Maybe later, take me back',
                  style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 32),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Encrypted & Secure Transaction',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryDarkBlue, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: AppTheme.textDark.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
