import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../theme.dart';
import '../models/scanned_message.dart';
import '../state/scanned_messages_provider.dart';
import '../state/auth_provider.dart';
import '../services/pdf_report_service.dart';

class WeeklyReportScreen extends ConsumerStatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  ConsumerState<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends ConsumerState<WeeklyReportScreen> {
  bool _exporting = false;
  String _selectedFilter = 'All'; // 'All', 'High Risk', 'Caution'

  Future<void> _exportPdf() async {
    final messages = ref.read(scannedMessagesProvider);
    final user = ref.read(authProvider).user;
    final userName = user?.name ?? 'SafeSenior User';

    setState(() => _exporting = true);
    try {
      await PdfReportService.exportAndShare(
        context: context,
        messages: messages,
        userName: userName,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF export failed: $e', style: GoogleFonts.atkinsonHyperlegible(color: Colors.white)),
            backgroundColor: AppTheme.dangerRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  void _generateNewComplaint() {
    ref.read(scannedMessagesProvider.notifier).generateDynamicComplaint();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'New intercepted threat complaint added to Weekly Report!',
          style: GoogleFonts.atkinsonHyperlegible(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryTeal,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showIncidentDetail(ScannedMessage msg) {
    final isDanger = msg.riskLevelIndex == 2;
    final riskColor = isDanger ? const Color(0xFFAA361F) : const Color(0xFFE65100);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: riskColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isDanger ? 'BLOCKED • HIGH RISK' : 'FLAGGED • CAUTION',
                    style: GoogleFonts.atkinsonHyperlegible(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: riskColor,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(msg.receivedAt),
                  style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Sender: ${msg.sender}',
              style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F6F6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Text(
                msg.body,
                style: GoogleFonts.atkinsonHyperlegible(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Threat Indicators Neutralized:',
              style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 6),
            ...msg.reasons.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, size: 16, color: Color(0xFFAA361F)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        r,
                        style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, color: AppTheme.textDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allMessages = ref.watch(scannedMessagesProvider);
    final blockedThreats = allMessages.where((m) => m.isScam).toList();
    final highRiskCount = allMessages.where((m) => m.riskLevelIndex == 2).length;
    final cautionCount = allMessages.where((m) => m.riskLevelIndex == 1).length;
    final safeCount = allMessages.where((m) => m.riskLevelIndex == 0).length;

    // Dynamic date range calculation
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final dateRangeText = '${DateFormat('MMM d').format(weekAgo)} - ${DateFormat('MMM d, yyyy').format(now)}';

    // Apply active filter to complaints list
    final filteredIncidents = blockedThreats.where((m) {
      if (_selectedFilter == 'High Risk') return m.riskLevelIndex == 2;
      if (_selectedFilter == 'Caution') return m.riskLevelIndex == 1;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFBF7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Weekly Protection Report',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_alert_outlined, color: AppTheme.primaryTeal),
                    tooltip: 'Simulate Intercepted Threat',
                    onPressed: _generateNewComplaint,
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Summary Header Card ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF006565), Color(0xFF008080)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryTeal.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dateRangeText,
                                style: GoogleFonts.atkinsonHyperlegible(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFE3FFFE),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '100% Protected',
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Your Safety Digest',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'SafeSenior intercepted and neutralized ${blockedThreats.length} dangerous threats before they could reach your accounts.',
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 15,
                              color: const Color(0xFFE3FFFE),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Key Metrics Grid ──
                    Row(
                      children: [
                        Expanded(
                          child: _statMetricCard(
                            title: 'Messages Scanned',
                            value: '${allMessages.length}',
                            subtitle: 'SMS, WhatsApp, Feeds',
                            icon: Icons.mark_email_read_outlined,
                            accentColor: AppTheme.primaryTeal,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _statMetricCard(
                            title: 'Threats Blocked',
                            value: '${blockedThreats.length}',
                            subtitle: 'Phishing & Fake OTPs',
                            icon: Icons.shield_outlined,
                            accentColor: const Color(0xFFAA361F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _statMetricCard(
                            title: 'High Severity',
                            value: '$highRiskCount',
                            subtitle: 'Immediate danger alerts',
                            icon: Icons.warning_amber_rounded,
                            accentColor: const Color(0xFFAA361F),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _statMetricCard(
                            title: 'Safe Messages',
                            value: '$safeCount',
                            subtitle: 'Verified family & bills',
                            icon: Icons.verified_user_outlined,
                            accentColor: const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // ── Dynamic Incidents Prevented Header & Action ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Incidents Prevented (${blockedThreats.length})',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _generateNewComplaint,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Threat'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primaryTeal,
                            textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),

                    // Filter Pills
                    Row(
                      children: [
                        _filterChip('All', blockedThreats.length),
                        const SizedBox(width: 8),
                        _filterChip('High Risk', highRiskCount),
                        const SizedBox(width: 8),
                        _filterChip('Caution', cautionCount),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Dynamic Incident Complaints List ──
                    if (filteredIncidents.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Center(
                          child: Text(
                            'No incidents in this filter category.',
                            style: GoogleFonts.atkinsonHyperlegible(color: AppTheme.textSecondary),
                          ),
                        ),
                      )
                    else
                      ...filteredIncidents.map(
                        (msg) => GestureDetector(
                          onTap: () => _showIncidentDetail(msg),
                          child: _incidentTile(
                            date: DateFormat('MMM d • hh:mm a').format(msg.receivedAt),
                            title: msg.reasons.isNotEmpty ? msg.reasons.first : 'Suspicious Message Neutralized',
                            sender: msg.sender,
                            threatType: msg.riskLevelIndex == 2 ? 'High Risk Threat' : 'Caution Alert',
                            severity: msg.riskLevelIndex == 2 ? 'High' : 'Medium',
                            severityColor: msg.riskLevelIndex == 2 ? const Color(0xFFAA361F) : const Color(0xFFFE7356),
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Download / Share PDF report CTA
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _exporting ? null : _exportPdf,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _exporting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.picture_as_pdf, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Export PDF Report to Family (${allMessages.length} entries)',
                                    style: GoogleFonts.atkinsonHyperlegible(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, int count) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppTheme.primaryTeal : Colors.grey.shade300,
          ),
        ),
        child: Text(
          '$label ($count)',
          style: GoogleFonts.atkinsonHyperlegible(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _statMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3E2E2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.atkinsonHyperlegible(
              fontSize: 12.5,
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _incidentTile({
    required String date,
    required String title,
    required String sender,
    required String threatType,
    required String severity,
    required Color severityColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E2E2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.block, size: 18, color: severityColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textLight,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: severityColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          threatType,
                          style: GoogleFonts.atkinsonHyperlegible(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: severityColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Sender: $sender',
                  style: GoogleFonts.atkinsonHyperlegible(
                    fontSize: 13,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        ],
      ),
    );
  }
}
