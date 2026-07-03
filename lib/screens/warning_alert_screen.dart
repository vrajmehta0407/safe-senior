import 'package:flutter/material.dart';

class WarningAlertScreen extends StatelessWidget {
  const WarningAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color redTheme = const Color(0xFFC62828); // Deep Red
    
    return Scaffold(
      backgroundColor: redTheme,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.warning_amber_rounded, size: 80, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                'WARNING',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Possible scam or security threat\ndetected. Safe Senior is standing\nby.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                    ),
              ),
              const SizedBox(height: 40),
              
              // Call Guardian Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone_in_talk, color: redTheme, size: 40),
                        const SizedBox(width: 16),
                        Text(
                          'Call Guardian',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: redTheme,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Immediate 24/7 Support',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: redTheme.withValues(alpha: 0.7),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Protective Measures
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.security, color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'Protective\nMeasures',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildCheckItem(context, 'Your location has been logged.'),
                    const SizedBox(height: 16),
                    _buildCheckItem(context, 'Unrecognized audio blocked.'),
                    const SizedBox(height: 16),
                    _buildCheckItem(context, 'Family has been notified of\nalert.'),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // I Understand Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'I Understand',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckItem(BuildContext context, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline, color: Colors.white, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                ),
          ),
        ),
      ],
    );
  }
}
