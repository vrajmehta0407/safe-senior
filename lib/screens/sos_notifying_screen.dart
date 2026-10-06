import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../state/guardian_provider.dart';
import '../services/guardian_service.dart';

class SosNotifyingScreen extends ConsumerStatefulWidget {
  const SosNotifyingScreen({super.key});

  @override
  ConsumerState<SosNotifyingScreen> createState() => _SosNotifyingScreenState();
}

class _SosNotifyingScreenState extends ConsumerState<SosNotifyingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _notifiedCount = 0;
  bool _cancelled = false;
  Timer? _autoTimer;
  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _dispatchRealAlerts();

    _autoTimer = Timer(const Duration(seconds: 15), () {
      if (mounted && !_cancelled) Navigator.of(context).pop();
    });
  }

  Future<void> _dispatchRealAlerts() async {
    final guardians = ref.read(guardianListProvider);
    final count = guardians.length;

    // Send real emergency alerts to all registered guardians
    GuardianService.sendEmergencyAlertToAllGuardians(
      message: '🚨 CRITICAL SOS ALERT: Your family member has pressed the Emergency Panic Button on SafeSenior! Please contact or check on them immediately.',
    ).ignore();

    if (count > 0) {
      for (int i = 1; i <= count; i++) {
        _timers.add(Timer(Duration(milliseconds: 600 * i), () {
          if (mounted) setState(() => _notifiedCount = i);
        }));
      }
    } else {
      // If no guardians configured yet, simulate step sequence
      for (int i = 1; i <= 3; i++) {
        _timers.add(Timer(Duration(milliseconds: 600 * i), () {
          if (mounted) setState(() => _notifiedCount = i);
        }));
      }
    }
  }

  Future<void> _shareSosViaApps(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;
    const sosMsg = '🚨 EMERGENCY SOS ALERT from SafeSenior!\n\nI need urgent help right now! Please call me or check on me immediately.\n\nSent via SafeSenior Emergency Shield.';
    await SharePlus.instance.share(
      ShareParams(
        text: sosMsg,
        subject: 'EMERGENCY SOS ALERT',
        sharePositionOrigin: origin,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _autoTimer?.cancel();
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final guardians = ref.watch(guardianListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFB71C1C),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
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
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'SOS ALERT',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pulsing SOS icon
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.3),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.sos, color: Colors.white, size: 80),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    Text(
                      'Notifying Your\nFamily Circle',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Emergency alerts are being sent to all\nyour trusted guardians right now.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Guardian notification status
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            guardians.isEmpty ? 'Notifying guardians...' : 'Notifying ${guardians.length} guardian${guardians.length > 1 ? "s" : ""}...',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.7),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (guardians.isNotEmpty)
                            ...guardians.asMap().entries.map((entry) {
                              final g = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildGuardianRow(g.name, '(${g.relationship ?? "Guardian"})', entry.key),
                              );
                            })
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'No guardians linked yet.\nUse the share button below to broadcast emergency alerts to your contacts.',
                                style: GoogleFonts.atkinsonHyperlegible(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  height: 1.4,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Location sharing note & interactive share button
                    GestureDetector(
                      onTap: () => _shareSosViaApps(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.share, color: Colors.white, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Share SOS with WhatsApp / Contacts',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Tap to forward emergency SOS alert immediately',
                                    style: GoogleFonts.atkinsonHyperlegible(
                                      fontSize: 12.5,
                                      color: Colors.white.withValues(alpha: 0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _shareSosViaApps(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.white70),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.share, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Share SOS via Apps / WhatsApp',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() => _cancelled = true);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        'Cancel SOS Alert',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFB71C1C),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuardianRow(String name, String relation, int index) {
    final notified = _notifiedCount > index;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              name[0],
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                relation,
                style: GoogleFonts.atkinsonHyperlegible(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        if (notified)
          const Icon(Icons.check_circle, color: Color(0xFF81C784), size: 22)
        else
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withValues(alpha: 0.6)),
            ),
          ),
      ],
    );
  }
}
