import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../state/scanned_messages_provider.dart';
import '../state/guardian_provider.dart';
import '../services/guardian_service.dart';

class ScannedWhatsAppFeedScreen extends ConsumerStatefulWidget {
  const ScannedWhatsAppFeedScreen({super.key});

  @override
  ConsumerState<ScannedWhatsAppFeedScreen> createState() => _ScannedWhatsAppFeedScreenState();
}

class _ScannedWhatsAppFeedScreenState extends ConsumerState<ScannedWhatsAppFeedScreen> {
  String _filter = 'ALL'; // ALL, THREATS, SAFE

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(scannedMessagesProvider);
    final guardians = ref.watch(guardianListProvider);

    final filteredList = messages.where((msg) {
      if (_filter == 'THREATS') return msg.isScam;
      if (_filter == 'SAFE') return !msg.isScam;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header Bar ────────────────────────────────────────────────
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
                          'Scanned WhatsApp & Protection',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'WhatsApp Scam & APK Protection',
                          style: GoogleFonts.atkinsonHyperlegible(
                            fontSize: 13,
                            color: const Color(0xFF25D366),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Filter Chips ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  _buildFilterChip('ALL', 'All Scans (${messages.length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip('THREATS', 'Scams (${messages.where((m) => m.isScam).length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip('SAFE', 'Verified'),
                ],
              ),
            ),

            // ── Dynamic Feed List ──────────────────────────────────────────
            Expanded(
              child: filteredList.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.verified_user_outlined, size: 64, color: Color(0xFF25D366)),
                            const SizedBox(height: 16),
                            Text(
                              'No Threat Activity Detected',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'WhatsApp messages and APK links are monitored automatically by SafeSenior.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 13.5,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      itemCount: filteredList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, index) {
                        final msg = filteredList[index];
                        return _buildMessageCard(
                          sender: msg.sender,
                          message: msg.maskedBody,
                          time: '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                          isThreat: msg.isScam,
                          threatTitle: msg.scamCategory ?? (msg.isScam ? 'Suspicious Phishing Link' : 'Safe Contact'),
                          actionLabel: msg.isScam ? 'Blocked & Intercepted' : 'Verified Safe',
                          guardians: guardians,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final selected = _filter == key;
    return GestureDetector(
      onTap: () => setState(() => _filter = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF25D366) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageCard({
    required String sender,
    required String message,
    required String time,
    required bool isThreat,
    required String threatTitle,
    required String actionLabel,
    required List<dynamic> guardians,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isThreat
            ? const Border(left: BorderSide(color: AppTheme.dangerRed, width: 4))
            : const Border(left: BorderSide(color: Color(0xFF25D366), width: 4)),
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isThreat ? AppTheme.dangerRed.withOpacity(0.1) : const Color(0xFF25D366).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isThreat ? Icons.warning_amber_rounded : Icons.check_circle,
                  color: isThreat ? AppTheme.dangerRed : const Color(0xFF25D366),
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  sender,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Text(
                time,
                style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: GoogleFonts.atkinsonHyperlegible(fontSize: 14.5, color: AppTheme.textPrimary, height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isThreat ? AppTheme.dangerRed.withOpacity(0.08) : const Color(0xFF25D366).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$threatTitle • $actionLabel',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.atkinsonHyperlegible(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isThreat ? AppTheme.dangerRed : const Color(0xFF25D366),
                    ),
                  ),
                ),
              ),
              if (isThreat) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () async {
                    if (guardians.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please add at least one guardian contact first.')),
                      );
                      return;
                    }
                    final alertText = '⚠️ SafeSenior Alert: Suspicious message received from "$sender": "$message"';
                    final primary = guardians.firstWhere((g) => g.isPrimary, orElse: () => guardians.first);
                    await GuardianService.messageWhatsApp(phone: primary.phone, message: alertText);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.share, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'WhatsApp Alert',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
