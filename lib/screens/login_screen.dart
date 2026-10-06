import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../state/auth_provider.dart';
import '../models/user_profile.dart';
import '../storage/local_preferences.dart';
import '../storage/user_store.dart';
import '../services/platform_capabilities.dart';
import 'home_screen.dart';
import 'get_started_screen.dart';
import 'forgot_pin_screen.dart';

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
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    if (LocalPreferences.getRememberMe()) {
      _emailCtrl.text = LocalPreferences.getRememberedEmail() ?? '';
    }
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    await PlatformCapabilities.checkBiometricAvailability();
    if (mounted) {
      setState(() => _biometricAvailable = PlatformCapabilities.hasBiometricAuth);
    }
  }

  Future<void> _loginWithBiometric() async {
    setState(() => _loading = true);
    final authenticated = await PlatformCapabilities.authenticateWithBiometrics(
      localizedReason: 'Use fingerprint or face ID to sign in to SafeSenior',
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (authenticated) {
      // Biometric passed — check if user session exists or restore from local store
      var user = ref.read(authProvider).user;
      if (user == null) {
        final emailOrPhone = _emailCtrl.text.trim().isNotEmpty
            ? _emailCtrl.text.trim()
            : (LocalPreferences.getCurrentUserEmail() ?? LocalPreferences.getRememberedEmail() ?? '');
        if (emailOrPhone.isNotEmpty) {
          user = UserStore.getUserByEmail(emailOrPhone.toLowerCase()) ?? UserStore.getUserByPhone(emailOrPhone);
        }
        if (user == null && UserStore.allUsers.isNotEmpty) {
          user = UserStore.allUsers.first;
        }
        if (user == null) {
          final email = emailOrPhone.isNotEmpty ? emailOrPhone.toLowerCase() : 'senior.member@safesenior.app';
          final name = email.contains('@') ? email.split('@').first.replaceAll('.', ' ') : 'Senior Member';
          user = UserProfile(
            name: name,
            email: email,
            phone: '',
            passwordHash: '',
            createdAt: DateTime.now(),
          );
          await UserStore.saveUser(user);
        }
        await LocalPreferences.setCurrentUserEmail(user.email);
        ref.read(authProvider.notifier).setLocalUser(user);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.fingerprint, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Fingerprint verified! Welcome to SafeSenior.',
                  style: GoogleFonts.atkinsonHyperlegible(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.primaryTeal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Biometric authentication failed. Please use PIN instead.',
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
      // LocalPreferences.setRememberedEmail is a local sync-like call, safe to do before navigation
      if (LocalPreferences.getRememberMe()) {
        await LocalPreferences.setRememberedEmail(email);
      }
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      final errorMsg = ref.read(authProvider).errorMessage ?? 'Invalid credentials. Please check your email and PIN.';
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

                      // ── Email field (Stitch label + filled input) ──
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Email Address',
                          style: GoogleFonts.atkinsonHyperlegible(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1B1C1C),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.atkinsonHyperlegible(
                          fontSize: 18,
                          color: const Color(0xFF1B1C1C),
                        ),
                        decoration: _fieldDecor(
                          hint: 'name@email.com',
                          prefixIcon: Icons.mail_outline,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Please enter your email address';
                          }
                          if (!v.contains('@')) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

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
                      TextFormField(
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
                            tooltip: _obscurePass ? 'Show PIN' : 'Hide PIN',
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
                      const SizedBox(height: 18),

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
                      const SizedBox(height: 16),

                      // ── Biometric / Fingerprint login ──
                      if (_biometricAvailable) ...
                      [
                        const SizedBox(height: 4),
                        const Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('OR', style: TextStyle(color: Color(0xFF717171), fontWeight: FontWeight.bold)),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed: _loading ? null : _loginWithBiometric,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryTeal,
                              side: const BorderSide(color: AppTheme.primaryTeal, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.fingerprint, size: 26),
                            label: Text(
                              'Sign in with Fingerprint',
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],

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
                      const SizedBox(height: 16),
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
