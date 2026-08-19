import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../state/auth_provider.dart';
import '../storage/local_preferences.dart';
import 'home_screen.dart';
import 'get_started_screen.dart';
import 'forgot_pin_screen.dart';
import 'admin/admin_login_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (LocalPreferences.getRememberMe()) {
      _emailCtrl.text = LocalPreferences.getRememberedEmail() ?? '';
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    final success = await ref.read(authProvider.notifier).login(email, pass);

    if (!mounted) return;
    setState(() => _loading = false);

    if (success) {
      if (LocalPreferences.getRememberMe()) {
        await LocalPreferences.setRememberedEmail(email);
      }
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      final errorMsg = ref.read(authProvider).errorMessage ?? 'Invalid credentials. Please check your phone number and PIN.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMsg,
            style: GoogleFonts.atkinsonHyperlegible(color: Colors.white, fontSize: 16),
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
      // Stitch login background: warm off-white #FDFBF7
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              // Stitch: white card with rounded-xl + card-shadow
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Brand Header: shield icon + SafeSenior (Stitch exact) ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.security, color: AppTheme.primaryTeal, size: 36),
                          const SizedBox(width: 10),
                          Text(
                            'SafeSenior',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryTeal,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Welcome text ──
                      Text(
                        'Welcome Back',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1B1C1C),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Please sign in to access your dashboard.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.atkinsonHyperlegible(
                          fontSize: 16,
                          color: const Color(0xFF3E4949),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Phone/Email field (Stitch label + filled input h-[56px]) ──
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Phone Number or Email',
                          style: GoogleFonts.atkinsonHyperlegible(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1B1C1C),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 56,
                        child: TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.atkinsonHyperlegible(
                            fontSize: 18,
                            color: const Color(0xFF1B1C1C),
                          ),
                          decoration: _fieldDecor(
                            hint: 'e.g. +91 98250 14820 or name@email.com',
                            prefixIcon: Icons.person_outline,
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Please enter phone or email' : null,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── PIN Code field with "Forgot PIN?" aligned right ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'PIN Code',
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1B1C1C),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ForgotPinScreen()),
                              );
                            },
                            child: Text(
                              'Forgot PIN?',
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryTeal,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 56,
                        child: TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscurePass,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.atkinsonHyperlegible(
                            fontSize: 18,
                            color: const Color(0xFF1B1C1C),
                          ),
                          decoration: _fieldDecor(
                            hint: 'Enter 4-digit PIN',
                            prefixIcon: Icons.dialpad,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePass ? Icons.visibility_off : Icons.visibility,
                                color: const Color(0xFF3E4949),
                                size: 22,
                              ),
                              onPressed: () => setState(() => _obscurePass = !_obscurePass),
                            ),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Please enter your PIN' : null,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ── Forgot PIN Link (Stitch: Forgot PIN / Help) ──
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ForgotPinScreen()),
                            );
                          },
                          child: Text(
                            'Forgot PIN / Need Help?',
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Sign In CTA (Stitch: full width, 56px, primary teal, rounded-lg) ──
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryTeal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            side: const BorderSide(color: AppTheme.primaryContainer, width: 1),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  'Sign In',
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Sign Up link (Stitch exact copy) ──
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const GetStartedScreen()),
                          );
                        },
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 16, color: const Color(0xFF3E4949)),
                            children: [
                              const TextSpan(text: 'New to SafeSenior? '),
                              TextSpan(
                                text: 'Create Account',
                                style: GoogleFonts.atkinsonHyperlegible(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryTeal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Divider(color: Color(0xFFEFEDED), height: 1),
                      const SizedBox(height: 16),

                      // ── Admin Portal link ──
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.admin_panel_settings_outlined,
                                size: 18, color: AppTheme.primaryTeal),
                            const SizedBox(width: 6),
                            Text(
                              'Admin Management Portal',
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecor({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.atkinsonHyperlegible(
          fontSize: 16, color: const Color(0xFF717171)),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF3E4949)),
      suffixIcon: suffixIcon,
      filled: true,
      // Stitch: bg-surface-container-highest = #E3E2E2
      fillColor: const Color(0xFFE3E2E2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.terracottaRed, width: 1.5),
      ),
      isDense: true,
    );
  }
}
