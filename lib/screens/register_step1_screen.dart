import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'login_screen.dart';
import 'otp_verification_screen.dart';

class RegisterStep1Screen extends StatefulWidget {
  final bool isEmail;

  const RegisterStep1Screen({
    super.key,
    this.isEmail = true,
  });

  @override
  State<RegisterStep1Screen> createState() => _RegisterStep1ScreenState();
}

class _RegisterStep1ScreenState extends State<RegisterStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _referralCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _referralCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;
    final contact = _contactCtrl.text.trim();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(
          name: _nameCtrl.text.trim(),
          contactValue: contact,
          isEmail: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEmail = widget.isEmail;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header: Back button + 3-step progress indicator (Stitch exact) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  // Back button (48×48 target, rounded)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        child: const Icon(Icons.arrow_back, size: 26, color: AppTheme.textLight),
                      ),
                    ),
                  ),
                  // Step progress (1 of 3)
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _stepDot(active: true),
                        const SizedBox(width: 8),
                        _stepDot(active: false),
                        const SizedBox(width: 8),
                        _stepDot(active: false),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48), // spacer mirror
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Heading (Stitch: primary color, headline-lg Plus Jakarta Sans)
                      Text(
                        'Let\'s get started',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryTeal,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Create your account with your email address to stay protected.',
                        style: GoogleFonts.atkinsonHyperlegible(
                          fontSize: 18,
                          color: AppTheme.textLight,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Full Name Field ──
                      _fieldLabel('Full Name'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameCtrl,
                        style: GoogleFonts.atkinsonHyperlegible(fontSize: 18, color: AppTheme.textDark),
                        decoration: InputDecoration(
                          hintText: 'Enter your full name',
                          hintStyle: GoogleFonts.atkinsonHyperlegible(fontSize: 18, color: const Color(0xFF717171)),
                          prefixIcon: const Icon(Icons.person_outline),
                          filled: true,
                          fillColor: AppTheme.backgroundColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppTheme.outlineVariant),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppTheme.outlineVariant),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 2),
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                      ),
                      const SizedBox(height: 20),

                      // ── Email Address Field ──
                      _fieldLabel('Email Address'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _contactCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.atkinsonHyperlegible(fontSize: 18, color: AppTheme.textDark),
                        decoration: InputDecoration(
                          hintText: 'name@email.com',
                          hintStyle: GoogleFonts.atkinsonHyperlegible(fontSize: 18, color: const Color(0xFF717171)),
                          prefixIcon: const Icon(Icons.mail_outline),
                          filled: true,
                          fillColor: AppTheme.backgroundColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppTheme.outlineVariant),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppTheme.outlineVariant),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 2),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Please enter your email address';
                          }
                          if (!v.contains('@') || !v.contains('.')) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          'We\'ll send a 6-digit code to verify this email inbox.',
                          style: GoogleFonts.atkinsonHyperlegible(fontSize: 14, color: AppTheme.textLight),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Referral Code (Optional) ──
                      Row(
                        children: [
                          Text(
                            'Referral Code',
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(Optional)',
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 14,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _referralCtrl,
                        style: GoogleFonts.atkinsonHyperlegible(fontSize: 18, color: AppTheme.textDark),
                        decoration: InputDecoration(
                          hintText: 'e.g. FAMILY123',
                          hintStyle: GoogleFonts.atkinsonHyperlegible(fontSize: 18, color: const Color(0xFF717171)),
                          prefixIcon: const Icon(Icons.group_add_outlined),
                          filled: true,
                          fillColor: AppTheme.backgroundColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppTheme.outlineVariant),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppTheme.outlineVariant),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          'Did a family member invite you? Enter their code here.',
                          style: GoogleFonts.atkinsonHyperlegible(fontSize: 14, color: AppTheme.textLight),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // ── Next Step CTA (Stitch: full-width 64px teal, arrow_forward icon) ──
                      SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryTeal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                            shadowColor: Colors.black.withValues(alpha: 0.08),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Next Step',
                                style: GoogleFonts.atkinsonHyperlegible(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.arrow_forward, size: 22, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Already have account link
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.atkinsonHyperlegible(fontSize: 16, color: AppTheme.textLight),
                              children: [
                                const TextSpan(text: 'Already have an account? '),
                                TextSpan(
                                  text: 'Log in',
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryTeal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.atkinsonHyperlegible(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppTheme.textDark,
      ),
    );
  }

  Widget _stepDot({required bool active}) {
    return Container(
      height: 8,
      width: 48,
      decoration: BoxDecoration(
        color: active ? AppTheme.primaryTeal : const Color(0xFFE3E2E2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
