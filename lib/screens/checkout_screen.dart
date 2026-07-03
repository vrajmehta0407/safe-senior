import 'package:flutter/material.dart';
import '../theme.dart';
import 'checkout_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Secure\nCheckout',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                const Icon(Icons.lock_outline, color: AppTheme.primaryDarkBlue, size: 16),
                const SizedBox(width: 4),
                Text(
                  'ENCRYPTED',
                  style: TextStyle(
                    color: AppTheme.primaryDarkBlue,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bank-grade security banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLightBlue.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.shield_outlined, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Bank-Grade Security',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Your personal data is protected by 256-bit SSL encryption.',
                                  style: TextStyle(color: AppTheme.textDark.withValues(alpha: 0.8), fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Plan Summary
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLightBlue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Plan Summary',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryDarkBlue,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Premium Protection\nAnnual',
                                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
                              ),
                              Text(
                                '\$89.99/yr', // Using $89.99 from image 1 instead of 199 from image 2
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Includes 24/7 Scam\nMonitoring & Support',
                            style: TextStyle(color: AppTheme.textDark.withValues(alpha: 0.7)),
                          ),
                          const SizedBox(height: 16),
                          Divider(color: Colors.grey.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Due Today',
                                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark, fontSize: 16),
                              ),
                              Text(
                                '\$89.99',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.primaryDarkBlue,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Payment Details Form
                    Text(
                      'Payment Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildInputField('Name on Card', 'As it appears on your card', Icons.person_outline),
                    const SizedBox(height: 16),
                    _buildInputField('Card Number', '0000 0000 0000 0000', Icons.credit_card),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(child: _buildInputField('Expiry Date', 'MM / YY', null)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildInputField('CVV code', '123', Icons.help_outline)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Money Back Guarantee
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.history, color: Color(0xFFC78B3F)), // Orange/brown
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            '30-Day Money Back Guarantee: If you aren\'t feeling safer within 30 days, we\'ll refund your payment in full.',
                            style: TextStyle(color: AppTheme.textDark.withValues(alpha: 0.8), fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Activate Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutSuccessScreen()));
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
                            Icon(Icons.shield_outlined),
                            SizedBox(width: 8),
                            Text('Activate Premium Protection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'By clicking activate, you agree to our Terms of Service.',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Trust Badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTrustBadge(Icons.verified_user_outlined, 'Norton Secured'),
                        const SizedBox(width: 16),
                        _buildTrustBadge(Icons.lock_outline, 'SSL Encrypted'),
                        const SizedBox(width: 16),
                        _buildTrustBadge(Icons.payment_outlined, 'PCI Compliant'),
                      ],
                    ),
                  ],
                ),
              ),

              // Footer Support Block
              Container(
                width: double.infinity,
                color: AppTheme.primaryLightBlue.withValues(alpha: 0.15),
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=2076&auto=format&fit=crop'), // Placeholder support agent
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Need help finishing your checkout?',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryDarkBlue,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Our support team is standing by to assist you.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textDark.withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.call, color: AppTheme.primaryDarkBlue),
                      label: const Text(
                        'Call Support: 1-800-SAFE-SNR',
                        style: TextStyle(color: AppTheme.primaryDarkBlue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  '© 2024 Safe Senior Digital Guardianship. All rights reserved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, IconData? suffixIcon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: suffixIcon != Icons.help_outline && suffixIcon != null ? Icon(suffixIcon, color: Colors.grey) : null,
            suffixIcon: suffixIcon == Icons.help_outline ? Icon(suffixIcon, color: Colors.grey) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
      ],
    );
  }

  Widget _buildTrustBadge(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600], size: 24),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
