import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../services/detection/blocklist_service.dart';
import '../services/guardian_service.dart';
import 'guardian_contacts_screen.dart';

class WarningAlertScreen extends StatelessWidget {
  final String? sender;
  final String? messageBody;
  final bool isCall;
  final String? threatType;
  final VoidCallback? onDismiss;

  const WarningAlertScreen({
    super.key,
    this.sender,
    this.messageBody,
    this.isCall = false,
    this.threatType,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSender = sender ?? (isCall ? '+91 11 2309 4712 (CBI Spoofed Call)' : '+91 11 2309 4712 (CBI Cyber Branch Spoof)');
    final effectiveBody = messageBody ??
        (isCall
            ? 'Incoming voice/video call flagged as an unauthorized impersonation or digital arrest extortion attempt. The caller was silenced and disconnected by SafeSenior.'
            : '"Beta/Babuji, I am under Digital Arrest at Delhi Airport Customs regarding a parcel containing contraband. Demand ₹50,000 immediately to avoid arrest. Transfer via UPI QR code attached..."');

    final effectiveBadge = isCall ? '🚨 SCAM CALL INTERCEPTED & BLOCKED' : 'SUSPICIOUS COERCION DETECTED';
    final effectiveTitle = isCall ? 'Fake Call Blocked' : 'Scam Alert';
    final effectiveSubtitle = isCall
        ? 'High risk spoofed or extortion call blocked by SafeSenior.'
        : 'High risk message flagged by SafeSenior AI.';
    final effectiveVector = threatType ?? (isCall ? 'Vector: Video Call Extortion / Police Impersonation' : 'Vector: Digital Arrest / Extortion Impersonation');

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) onDismiss?.call();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF8F7),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),

                // Urgency Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBE6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFE7356), width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isCall ? Icons.phone_disabled_rounded : Icons.gavel_rounded, size: 14, color: const Color(0xFFAA361F)),
                      const SizedBox(width: 8),
                      Text(
                        effectiveBadge,
                        style: GoogleFonts.atkinsonHyperlegible(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFAA361F),
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Terracotta Warning Shield Icon
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFECE8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFAA361F).withValues(alpha: 0.18),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      isCall ? Icons.phone_locked_rounded : Icons.warning_amber_rounded,
                      color: const Color(0xFFAA361F),
                      size: 42,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  effectiveTitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B1C1C),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  effectiveSubtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.atkinsonHyperlegible(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF5E706D),
                  ),
                ),
                const SizedBox(height: 22),

                // Threat Card Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFFFDAD3), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(isCall ? Icons.phone_callback_rounded : Icons.perm_phone_msg_outlined, color: const Color(0xFFAA361F), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              effectiveSender,
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1B1C1C),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFDAD3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isCall ? 'BLOCKED' : 'FLAGGED',
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFAA361F),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F3F3),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          effectiveBody,
                          style: GoogleFonts.atkinsonHyperlegible(
                            fontSize: 14,
                            color: const Color(0xFF2E3D3A),
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: 14, color: Color(0xFFAA361F)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              effectiveVector,
                              style: GoogleFonts.atkinsonHyperlegible(fontSize: 11.5, color: const Color(0xFFAA361F), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action 1: Block & Report to 1930
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      BlocklistService.blockSender(effectiveSender);
                      onDismiss?.call();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$effectiveSender permanently blocked & reported to Cybercrime Helpline 1930.'),
                          backgroundColor: const Color(0xFFAA361F),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.shield_outlined, size: 20),
                    label: Text(
                      isCall ? 'Block Number & Report 1930' : 'Block & Report (1930 Helpline)',
                      style: GoogleFonts.atkinsonHyperlegible(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFAA361F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      elevation: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Action 2: Call / Alert Guardian for Help
                Builder(
                  builder: (ctx) {
                    final primary = GuardianService.getPrimaryGuardian();
                    final gLabel = primary != null ? 'Call Guardian (${primary.name})' : 'Alert Family / Add Guardian';

                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (primary != null) {
                            await GuardianService.callGuardian(primary.phone);
                            await GuardianService.notifyAllGuardiansAboutScam(
                              sender: effectiveSender,
                              reason: effectiveTitle,
                            );
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text('Calling and sending alert to ${primary.name}...'),
                                  backgroundColor: const Color(0xFF006565),
                                ),
                              );
                            }
                          } else {
                            Navigator.push(
                              ctx,
                              MaterialPageRoute(builder: (_) => const GuardianContactsScreen()),
                            );
                          }
                          onDismiss?.call();
                        },
                        icon: const Icon(Icons.phone_in_talk, size: 20),
                        label: Text(
                          gLabel,
                          style: GoogleFonts.atkinsonHyperlegible(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006565),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Action 2.5: Share Threat Warning with Family (WhatsApp / SMS / Any App)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final box = context.findRenderObject() as RenderBox?;
                      final origin = box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;
                      final shareMsg = '''🚨 SafeSenior Threat Warning Alert!

A high-risk ${isCall ? 'scam call' : 'fraud message'} was detected and blocked on my phone.

⚠️ Threat: $effectiveTitle
📞 Sender: $effectiveSender
📝 Details: $effectiveBody

SafeSenior AI Shield is protecting my device. Please be aware of this scam!''';

                      await SharePlus.instance.share(
                        ShareParams(
                          text: shareMsg,
                          subject: '⚠️ SafeSenior Threat Warning: $effectiveTitle',
                          sharePositionOrigin: origin,
                        ),
                      );
                    },
                    icon: const Icon(Icons.share, size: 18, color: Color(0xFF006565)),
                    label: Text(
                      'Share Threat with Family (WhatsApp/Apps)',
                      style: GoogleFonts.atkinsonHyperlegible(fontSize: 14.5, fontWeight: FontWeight.bold, color: const Color(0xFF006565)),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF006565),
                      side: const BorderSide(color: Color(0xFF006565), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Action 3: I Trust This Person
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      onDismiss?.call();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF5E706D),
                      side: const BorderSide(color: Color(0xFFBDC9C8), width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: Text(
                      isCall ? 'I Trust This Caller - Dismiss' : 'I Trust This Person - Dismiss',
                      style: GoogleFonts.atkinsonHyperlegible(fontSize: 14.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Bottom Protection Subtext
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline, size: 14, color: Color(0xFF6E7979)),
                    const SizedBox(width: 6),
                    Text(
                      'Secured by SafeSenior Defense Suite',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6E7979),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
