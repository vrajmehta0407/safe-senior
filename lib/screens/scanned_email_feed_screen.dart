import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../state/scanned_messages_provider.dart';
import '../state/guardian_provider.dart';
import '../services/guardian_service.dart';

class ScannedEmailFeedScreen extends ConsumerStatefulWidget {
  const ScannedEmailFeedScreen({super.key});

  @override
  ConsumerState<ScannedEmailFeedScreen> createState() => _ScannedEmailFeedScreenState();
}

class _ScannedEmailFeedScreenState extends ConsumerState<ScannedEmailFeedScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(scannedMessagesProvider);
    final guardians = ref.watch(guardianListProvider);

    final filtered = _filter == 'Threats Only'
        ? messages.where((e) => e.isScam).toList()
        : messages;

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
                          'Scanned Emails & Feeds',
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
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Filter Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  _buildTab('All', 'All Emails (${messages.length})'),
                  const SizedBox(width: 10),
                  _buildTab('Threats Only', 'Phishing Alerts (${messages.where((m) => m.isScam).length})'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Dynamic Feed List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.mark_email_read_outlined, size: 64, color: AppTheme.primaryTeal),
                            const SizedBox(height: 16),
                            Text(
                              'No Email Phishing Threats Detected',
                              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'All scanned emails and security notifications are clean.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.atkinsonHyperlegible(fontSize: 13.5, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final email = filtered[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border(
                              left: BorderSide(
                                color: email.isScam ? AppTheme.dangerRed : const Color(0xFF2E7D32),
                                width: 4,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    email.isScam ? Icons.gpp_maybe : Icons.gpp_good,
                                    color: email.isScam ? AppTheme.dangerRed : const Color(0xFF2E7D32),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      email.sender,
                                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                    ),
                                  ),
                                  Text(
                                    '${email.timestamp.hour.toString().padLeft(2, '0')}:${email.timestamp.minute.toString().padLeft(2, '0')}',
                                    style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                email.maskedBody,
                                style: GoogleFonts.atkinsonHyperlegible(fontSize: 14, color: AppTheme.textPrimary, height: 1.35),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: email.isScam ? AppTheme.dangerRed.withOpacity(0.1) : const Color(0xFF2E7D32).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      email.isScam ? 'Scam • ${email.scamCategory ?? "Phishing Link"}' : 'Verified Safe',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: email.isScam ? AppTheme.dangerRed : const Color(0xFF2E7D32),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (email.isScam)
                                    TextButton.icon(
                                      icon: const Icon(Icons.share, size: 14, color: AppTheme.primaryTeal),
                                      label: Text('Alert Guardian', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                                      onPressed: () async {
                                        if (guardians.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Please add at least one guardian contact first.')),
                                          );
                                          return;
                                        }
                                        final msg = '⚠️ SafeSenior Alert: Suspicious email phishing detected from "${email.sender}": "${email.maskedBody}"';
                                        await GuardianService.messageGuardian(msg, guardians.first.phone);
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String key, String label) {
    final selected = _filter == key;
    return GestureDetector(
      onTap: () => setState(() => _filter = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryTeal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppTheme.primaryTeal : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
