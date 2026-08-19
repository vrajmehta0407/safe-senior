import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class ScannedEmailFeedScreen extends StatefulWidget {
  const ScannedEmailFeedScreen({super.key});

  @override
  State<ScannedEmailFeedScreen> createState() => _ScannedEmailFeedScreenState();
}

class _ScannedEmailFeedScreenState extends State<ScannedEmailFeedScreen> {
  String _filter = 'All';

  final List<_EmailItem> _emails = [
    _EmailItem(
      sender: 'security-alert@service-netflix.com',
      displaySender: 'Netflix Support (Fake)',
      subject: 'Account Suspended: Please verify billing information',
      snippet: 'Your membership is on hold until you update payment details. Click link below immediately...',
      time: '10:24 AM',
      isThreat: true,
      threatType: 'Phishing',
      riskScore: 94,
    ),
    _EmailItem(
      sender: 'statements@hdfcbank.net',
      displaySender: 'HDFC Banking Service (Fake)',
      subject: 'URGENT: Income Tax Refund Credited ₹24,850',
      snippet: 'Govt IT Department refund approved. Click to approve transfer to your savings account...',
      time: 'Yesterday',
      isThreat: true,
      threatType: 'Refund Scam',
      riskScore: 98,
    ),
    _EmailItem(
      sender: 'notifications@google.com',
      displaySender: 'Google Account',
      subject: 'Security alert for your linked Google Account',
      snippet: 'New sign-in on Windows device in New Delhi. If this was you, no action is needed...',
      time: 'Aug 14',
      isThreat: false,
      threatType: 'Safe',
      riskScore: 5,
    ),
    _EmailItem(
      sender: 'pension@epfindia-gov.in.org',
      displaySender: 'EPFO Pension Portal (Fake)',
      subject: 'Annual Life Certificate Digital Submission Pending',
      snippet: 'Submit digital life certificate before deadline to avoid pension suspension for senior citizens...',
      time: 'Aug 12',
      isThreat: true,
      threatType: 'Impersonation',
      riskScore: 91,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'Threats Only'
        ? _emails.where((e) => e.isThreat).toList()
        : _emails;

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
                          'Scanned Emails',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Email Phishing Protection Active',
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

            // Filter chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Threats Only'),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Email list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _buildEmailCard(filtered[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final active = _filter == label;
    return GestureDetector(
      onTap: () => setState(() => _filter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryTeal : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: active ? AppTheme.primaryTeal : AppTheme.dividerColor),
        ),
        child: Text(
          label,
          style: GoogleFonts.atkinsonHyperlegible(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmailCard(_EmailItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: item.isThreat
            ? const Border(left: BorderSide(color: AppTheme.dangerRed, width: 4))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.isThreat ? AppTheme.dangerRed.withOpacity(0.1) : AppTheme.primaryTeal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.isThreat ? Icons.mail_lock : Icons.mark_email_read,
                  color: item.isThreat ? AppTheme.dangerRed : AppTheme.primaryTeal,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.displaySender,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: item.isThreat ? AppTheme.dangerRed : AppTheme.textPrimary,
                  ),
                ),
              ),
              Text(
                item.time,
                style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.subject,
            style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            item.snippet,
            style: GoogleFonts.atkinsonHyperlegible(fontSize: 13.5, color: AppTheme.textSecondary, height: 1.4),
          ),
          if (item.isThreat) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.dangerRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield, color: AppTheme.dangerRed, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'BLOCKED: ${item.threatType} (${item.riskScore}% Risk)',
                    style: GoogleFonts.atkinsonHyperlegible(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.dangerRed,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmailItem {
  final String sender;
  final String displaySender;
  final String subject;
  final String snippet;
  final String time;
  final bool isThreat;
  final String threatType;
  final int riskScore;

  _EmailItem({
    required this.sender,
    required this.displaySender,
    required this.subject,
    required this.snippet,
    required this.time,
    required this.isThreat,
    required this.threatType,
    required this.riskScore,
  });
}
