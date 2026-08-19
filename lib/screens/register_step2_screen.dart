import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/guardian_contact.dart';
import '../services/guardian_service.dart';
import '../services/auth_service.dart';
import '../state/auth_provider.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class RegisterStep2Screen extends ConsumerStatefulWidget {
  final String name;
  final String phone;
  final String email;
  final bool isEmail;

  const RegisterStep2Screen({
    super.key,
    required this.name,
    required this.phone,
    this.email = '',
    this.isEmail = false,
  });

  @override
  ConsumerState<RegisterStep2Screen> createState() => _RegisterStep2ScreenState();
}

class _RegisterStep2ScreenState extends ConsumerState<RegisterStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  final _pinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();
  final _guardianNameCtrl = TextEditingController();
  final _guardianPhoneCtrl = TextEditingController();
  bool _obscurePin = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _pinCtrl.dispose();
    _confirmPinCtrl.dispose();
    _guardianNameCtrl.dispose();
    _guardianPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final pin = _pinCtrl.text.trim();
      final confirmPin = _confirmPinCtrl.text.trim();

      // Determine effective email and phone
      String effectivePhone = widget.phone.trim();
      String effectiveEmail = widget.email.trim().toLowerCase();

      if (effectiveEmail.isEmpty) {
        final digits = effectivePhone.replaceAll(RegExp(r'\D'), '');
        effectiveEmail = '$digits@safesenior.app';
      }
      if (effectivePhone.isEmpty && !widget.isEmail) {
        effectivePhone = '+919999999999';
      }

      // 1. Register User in Riverpod AuthProvider & Hive UserStore
      final success = await ref.read(authProvider.notifier).signup(
        name: widget.name.trim(),
        email: effectiveEmail,
        phone: effectivePhone,
        password: pin,
        confirmPassword: confirmPin,
      );

      // 2. Add Guardian if specified
      final guardianName = _guardianNameCtrl.text.trim();
      final guardianPhone = _guardianPhoneCtrl.text.trim();
      if (guardianName.isNotEmpty && guardianPhone.isNotEmpty) {
        try {
          await GuardianService.addGuardianContact(
            GuardianContact(
              name: guardianName,
              phone: guardianPhone,
              addedAt: DateTime.now(),
              isActive: true,
              isPrimary: true,
              relationship: 'Family Guardian',
            ),
          );
        } catch (_) {}
      }

      // 3. Sync to backend
      try {
        await AuthService.syncSignupToBackend(
          name: widget.name.trim(),
          email: effectiveEmail,
          phone: effectivePhone,
          password: pin,
        );
      } catch (_) {}

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(authProvider).errorMessage ?? 'Registration failed. Please try again.',
              style: GoogleFonts.atkinsonHyperlegible(color: Colors.white),
            ),
            backgroundColor: AppTheme.terracottaRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${e.toString()}',
            style: GoogleFonts.atkinsonHyperlegible(color: Colors.white),
          ),
          backgroundColor: AppTheme.terracottaRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header with back + progress (step 2 of 3) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
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
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _stepDot(active: true),
                        const SizedBox(width: 8),
                        _stepDot(active: true),
                        const SizedBox(width: 8),
                        _stepDot(active: false),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48),
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

                      Text(
                        'Set up your security',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryTeal,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Hi ${widget.name.split(' ').first}! Create a PIN and add your primary guardian.',
                        style: GoogleFonts.atkinsonHyperlegible(
                          fontSize: 18,
                          color: AppTheme.textLight,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // PIN Field
                      _fieldLabel('Create Security PIN'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _pinCtrl,
                        obscureText: _obscurePin,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        style: GoogleFonts.atkinsonHyperlegible(fontSize: 18, color: AppTheme.textDark),
                        decoration: _inputDecoration(
                          hint: 'Enter 4 or 6-digit PIN',
                          prefixIcon: Icons.dialpad,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePin ? Icons.visibility_off : Icons.visibility, color: AppTheme.textLight),
                            onPressed: () => setState(() => _obscurePin = !_obscurePin),
                          ),
                          counterText: '',
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please create a PIN';
                          if (v.length < 4) return 'PIN must be at least 4 digits';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Confirm PIN Field
                      _fieldLabel('Confirm Security PIN'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPinCtrl,
                        obscureText: _obscureConfirm,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        style: GoogleFonts.atkinsonHyperlegible(fontSize: 18, color: AppTheme.textDark),
                        decoration: _inputDecoration(
                          hint: 'Re-enter your PIN',
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: AppTheme.textLight),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                          counterText: '',
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please confirm your PIN';
                          if (v != _pinCtrl.text) return 'PINs do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Guardian separator
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2F2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.shield_outlined, color: AppTheme.primaryTeal, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Add a trusted guardian who will be alerted if you\'re in danger.',
                                style: GoogleFonts.atkinsonHyperlegible(
                                  fontSize: 15,
                                  color: AppTheme.primaryTeal,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Guardian Name
                      _fieldLabel('Guardian\'s Name'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _guardianNameCtrl,
                        style: GoogleFonts.atkinsonHyperlegible(fontSize: 18, color: AppTheme.textDark),
                        decoration: _inputDecoration(
                          hint: 'e.g. Amit Patel',
                          prefixIcon: Icons.person_outline,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter guardian\'s name' : null,
                      ),
                      const SizedBox(height: 20),

                      // Guardian Phone
                      _fieldLabel('Guardian\'s Phone Number'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _guardianPhoneCtrl,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.atkinsonHyperlegible(fontSize: 18, color: AppTheme.textDark),
                        decoration: _inputDecoration(
                          hint: '+91 98250 14820',
                          prefixIcon: Icons.phone_outlined,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Please enter guardian\'s number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 36),

                      // Create Account CTA
                      SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryTeal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Create My Account',
                                      style: GoogleFonts.atkinsonHyperlegible(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(Icons.check_circle_outline, size: 22, color: Colors.white),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

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

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
    String? counterText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.atkinsonHyperlegible(fontSize: 18, color: const Color(0xFF717171)),
      prefixIcon: Icon(prefixIcon),
      suffixIcon: suffixIcon,
      counterText: counterText,
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.secondary, width: 1.5),
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
