import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class VoiceCallHistoryScreen extends StatelessWidget {
  const VoiceCallHistoryScreen({super.key});

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Call Protection History',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'AI Spam & Deepfake Voice Filter',
                          style: GoogleFonts.atkinsonHyperlegible(
                            fontSize: 13,
                            color: AppTheme.primaryTeal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  _buildCallItem(
                    caller: '+91 140 982 3451',
                    label: 'Robocall Telemarketing',
                    time: 'Today, 2:15 PM',
                    duration: 'Auto-Blocked (0s)',
                    status: 'BLOCKED',
                    isDanger: true,
                    icon: Icons.phone_disabled,
                  ),
                  const SizedBox(height: 12),
                  _buildCallItem(
                    caller: '+91 800 555 0192',
                    label: 'Synthetic Deepfake Voice Call',
                    time: 'Yesterday, 6:40 PM',
                    duration: 'Intercepted (12s)',
                    status: 'AI THREAT',
                    isDanger: true,
                    icon: Icons.record_voice_over,
                  ),
                  const SizedBox(height: 12),
                  _buildCallItem(
                    caller: 'Amit Patel (Son)',
                    label: 'Verified Family Contact',
                    time: 'Aug 16, 9:20 AM',
                    duration: '4m 15s',
                    status: 'SAFE',
                    isDanger: false,
                    icon: Icons.phone_in_talk,
                  ),
                  const SizedBox(height: 12),
                  _buildCallItem(
                    caller: 'Dr. Sharma Clinic',
                    label: 'Trusted Whitelist Contact',
                    time: 'Aug 14, 11:30 AM',
                    duration: '2m 04s',
                    status: 'SAFE',
                    isDanger: false,
                    icon: Icons.medical_services_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallItem({
    required String caller,
    required String label,
    required String time,
    required String duration,
    required String status,
    required bool isDanger,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDanger ? AppTheme.dangerRed.withOpacity(0.1) : AppTheme.primaryTeal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isDanger ? AppTheme.dangerRed : AppTheme.primaryTeal, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  caller,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.atkinsonHyperlegible(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  '$time • $duration',
                  style: GoogleFonts.atkinsonHyperlegible(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDanger ? AppTheme.dangerRed.withOpacity(0.1) : AppTheme.primaryTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: GoogleFonts.atkinsonHyperlegible(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: isDanger ? AppTheme.dangerRed : AppTheme.primaryTeal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
