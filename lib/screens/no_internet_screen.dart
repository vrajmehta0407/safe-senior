import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class NoInternetScreen extends StatelessWidget {
  final VoidCallback? onRetry;
  const NoInternetScreen({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 70,
                  color: AppTheme.textSecondary.withOpacity(0.5),
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'No Internet\nConnection',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'SafeSenior needs an internet connection\nto scan for scams and protect you.',
                textAlign: TextAlign.center,
                style: GoogleFonts.atkinsonHyperlegible(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // Offline features notice
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Still available offline:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildOfflineFeature(Icons.block, 'Blocked caller list', true),
                    const SizedBox(height: 10),
                    _buildOfflineFeature(Icons.contacts_outlined, 'Guardian contacts', true),
                    const SizedBox(height: 10),
                    _buildOfflineFeature(Icons.call, 'Emergency calls', true),
                    const SizedBox(height: 14),
                    Divider(color: AppTheme.dividerColor),
                    const SizedBox(height: 14),
                    Text(
                      'Requires connection:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildOfflineFeature(Icons.sms_outlined, 'Real-time SMS scanning', false),
                    const SizedBox(height: 10),
                    _buildOfflineFeature(Icons.cloud_sync_outlined, 'Scam pattern updates', false),
                    const SizedBox(height: 10),
                    _buildOfflineFeature(Icons.notifications_outlined, 'Guardian alerts', false),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Retry button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry ?? () => Navigator.pop(context),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(
                    'Try Again',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Continue Offline',
                  style: GoogleFonts.atkinsonHyperlegible(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineFeature(IconData icon, String label, bool available) {
    return Row(
      children: [
        Icon(
          available ? Icons.check_circle_outline : Icons.cancel_outlined,
          size: 20,
          color: available ? AppTheme.primaryTeal : AppTheme.textSecondary.withOpacity(0.4),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.atkinsonHyperlegible(
            fontSize: 15,
            color: available ? AppTheme.textPrimary : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
