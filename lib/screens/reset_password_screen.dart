import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import '../state/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _success = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(authProvider.notifier).resetPassword(
          _phoneCtrl.text.trim(),
          _otpCtrl.text.trim(),
          _passCtrl.text.trim(),
        );

    if (ok && mounted) {
      setState(() => _success = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.primaryTeal),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SafeSenior',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: _success
                    ? Column(
                        children: [
                          const SizedBox(height: 40),
                          const Icon(Icons.check_circle_outline, color: AppTheme.primaryTeal, size: 72),
                          const SizedBox(height: 18),
                          Text('Password Reset Success', style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                          const SizedBox(height: 12),
                          Text('Your password has been updated safely. Please sign in with your new password.', textAlign: TextAlign.center, style: GoogleFonts.atkinsonHyperlegible(color: const Color(0xFF5E706D))),
                          const SizedBox(height: 28),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryTeal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: const Text('Back to Login'),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            'Reset Password',
                            style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Enter your registered phone and OTP verification code.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.atkinsonHyperlegible(fontSize: 14.5, color: const Color(0xFF5E706D)),
                          ),
                          const SizedBox(height: 24),

                          Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _phoneCtrl,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      labelText: 'Phone Number',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                  ),
                                  const SizedBox(height: 14),

                                  TextFormField(
                                    controller: _otpCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'OTP Verification Code',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                  ),
                                  const SizedBox(height: 14),

                                  TextFormField(
                                    controller: _passCtrl,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: 'New Password',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
                                  ),
                                  const SizedBox(height: 24),

                                  if (authState.errorMessage != null) ...[
                                    Text(authState.errorMessage!, style: GoogleFonts.atkinsonHyperlegible(color: AppTheme.terracottaRed)),
                                    const SizedBox(height: 14),
                                  ],

                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: authState.isLoading ? null : _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryTeal,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                      ),
                                      child: authState.isLoading
                                          ? const CircularProgressIndicator(color: Colors.white)
                                          : Text('Reset Password', style: GoogleFonts.atkinsonHyperlegible(fontWeight: FontWeight.bold, fontSize: 16)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          TextButton.icon(
                            onPressed: () async {
                              final uri = Uri(scheme: 'mailto', path: 'support@safesenior.app');
                              if (await canLaunchUrl(uri)) await launchUrl(uri);
                            },
                            icon: const Icon(Icons.help_outline, color: AppTheme.primaryTeal),
                            label: Text('Contact Support', style: GoogleFonts.atkinsonHyperlegible(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
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
