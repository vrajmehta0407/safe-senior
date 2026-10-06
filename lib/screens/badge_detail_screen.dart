import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../theme.dart';
import '../models/guardian_contact.dart';
import '../services/guardian_service.dart';
import 'guardian_contacts_screen.dart';

class BadgeItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final IconData icon;
  final Color primaryColor;
  final Color bgTint;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int currentProgress;
  final int targetProgress;

  const BadgeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.primaryColor,
    required this.bgTint,
    required this.isUnlocked,
    this.unlockedAt,
    required this.currentProgress,
    required this.targetProgress,
  });
}

class BadgeDetailScreen extends StatelessWidget {
  final BadgeItem badge;

  const BadgeDetailScreen({super.key, required this.badge});

  String _formatShareText() {
    return '''🏆 SafeSenior Milestone: ${badge.title}

${badge.description}

🎯 Category: ${badge.category}
🔒 Status: ${badge.isUnlocked ? "Unlocked & Active ✅" : "In Progress (${badge.currentProgress}/${badge.targetProgress})"}

Protected by SafeSenior — AI Threat Shield for Families.''';
  }

  Future<void> _shareViaNativeSheet(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;
    await SharePlus.instance.share(
      ShareParams(
        text: _formatShareText(),
        subject: 'SafeSenior Milestone: ${badge.title}',
        sharePositionOrigin: origin,
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    final guardians = GuardianService.getAllGuardians();
    final shareText = _formatShareText();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: badge.bgTint,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(badge.icon, color: badge.primaryColor, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Share "${badge.title}"',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          'Let family know your device is secure',
                          style: GoogleFonts.atkinsonHyperlegible(
                            fontSize: 13,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFFEFEDED)),
              const SizedBox(height: 12),

              // ── Primary Action: Share to All Apps ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _shareViaNativeSheet(context);
                  },
                  icon: const Icon(Icons.share, size: 20, color: Colors.white),
                  label: Text(
                    'Share via WhatsApp / Messages / Apps',
                    style: GoogleFonts.atkinsonHyperlegible(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ── Direct Guardian Sharing ──
              Text(
                'Directly Notify Family Guardians',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 10),

              if (guardians.isNotEmpty) ...[
                ...guardians.map((g) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F7F4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE8E5E0)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppTheme.primaryTeal.withValues(alpha: 0.15),
                          child: Text(
                            g.name.isNotEmpty ? g.name[0].toUpperCase() : 'G',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                g.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              Text(
                                '${g.relationship ?? "Guardian"} • ${g.phone}',
                                style: GoogleFonts.atkinsonHyperlegible(
                                  fontSize: 12,
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // WhatsApp button
                        IconButton(
                          icon: const Icon(Icons.chat_bubble, color: Color(0xFF25D366), size: 22),
                          tooltip: 'Share on WhatsApp',
                          onPressed: () async {
                            Navigator.pop(ctx);
                            final sent = await GuardianService.messageWhatsApp(
                              phone: g.phone,
                              message: shareText,
                            );
                            if (context.mounted && !sent) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Could not open WhatsApp for ${g.name}. Using SMS...'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              await GuardianService.messageGuardian(shareText, g.phone);
                            }
                          },
                        ),
                        // SMS button
                        IconButton(
                          icon: const Icon(Icons.sms, color: AppTheme.primaryTeal, size: 22),
                          tooltip: 'Send SMS',
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await GuardianService.messageGuardian(shareText, g.phone);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('SMS opened to share badge with ${g.name}!'),
                                  backgroundColor: AppTheme.primaryTeal,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F7F4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE8E5E0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.primaryTeal, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'No family guardians linked yet. Add a guardian contact so they can celebrate your milestones and receive security alerts.',
                          style: GoogleFonts.atkinsonHyperlegible(fontSize: 12.5, color: AppTheme.textDark),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const GuardianContactsScreen()),
                          );
                        },
                        child: Text('Add Now', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progressFraction = (badge.currentProgress / badge.targetProgress).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Trophy Detail',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.share, color: AppTheme.primaryTeal),
                    tooltip: 'Share Badge',
                    onPressed: () => _showShareOptions(context),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // Badge Icon Ring
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: badge.bgTint,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: badge.primaryColor.withValues(alpha: 0.25),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(color: badge.primaryColor, width: 3),
                      ),
                      child: Center(
                        child: Icon(badge.icon, size: 60, color: badge.primaryColor),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Badge Title
                    Text(
                      badge.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Unlocked Status Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: badge.isUnlocked ? const Color(0xFFE0F2F2) : const Color(0xFFEFEDED),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            badge.isUnlocked ? Icons.check_circle : Icons.lock_outline,
                            size: 16,
                            color: badge.isUnlocked ? AppTheme.primaryTeal : AppTheme.textLight,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            badge.isUnlocked ? 'Unlocked & Active' : 'In Progress',
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: badge.isUnlocked ? AppTheme.primaryTeal : AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Description Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE3E2E2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How you earned this badge:',
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            badge.description,
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 16,
                              color: AppTheme.textDark,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Divider(color: Color(0xFFEFEDED)),
                          const SizedBox(height: 12),

                          // Progress tracker
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Requirement Progress',
                                style: GoogleFonts.atkinsonHyperlegible(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              Text(
                                '${badge.currentProgress} / ${badge.targetProgress}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: badge.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progressFraction,
                              backgroundColor: const Color(0xFFE3E2E2),
                              valueColor: AlwaysStoppedAnimation<Color>(badge.primaryColor),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Share button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => _showShareOptions(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.share, size: 20, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Share Milestone with Family',
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
