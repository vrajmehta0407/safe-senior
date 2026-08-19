// lib/screens/forgot_password_screen.dart
// Corrected: 3-step email OTP reset flow matching backend endpoints:
//   Step 1 → POST /auth/otp/request  { identifier: email, purpose: 'reset' }
//   Step 2 → Enter 6-digit OTP received in email
//   Step 3 → POST /auth/reset-password { identifier: email, otp_code, new_password }

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController    = TextEditingController();
  final _otpController      = TextEditingController();
  final _newPassController  = TextEditingController();
  final _confirmController  = TextEditingController();

  int  _step       = 1; // 1=email, 2=OTP+newPass, 3=success
  bool _isLoading  = false;
  int  _resendCooldown = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPassController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ── Step 1: Request OTP ───────────────────────────────────────────────────
  Future<void> _handleSendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showError('Please enter a valid email address.');
      return;
    }
    setState(() => _isLoading = true);

    final result = await AuthService.requestOtp(identifier: email, purpose: 'reset');
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.otpRequired || result.success || result.message?.contains('sent') == true) {
      setState(() {
        _step = 2;
        _resendCooldown = 60;
      });
      _startCooldown();
      _showSuccess('Reset code sent to your email. Check your inbox.');
    } else {
      _showError(result.message ?? 'Could not send reset code. Please try again.');
    }
  }

  // ── Step 2: Verify OTP + Set New Password ─────────────────────────────────
  Future<void> _handleReset() async {
    final email    = _emailController.text.trim();
    final otp      = _otpController.text.trim();
    final newPass  = _newPassController.text;
    final confirm  = _confirmController.text;

    if (otp.length < 6) {
      _showError('Please enter the 6-digit code from your email.');
      return;
    }
    if (newPass.length < 8) {
      _showError('New password must be at least 8 characters.');
      return;
    }
    if (newPass != confirm) {
      _showError('Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Backend: POST /auth/reset-password
      // Accepts: identifier (email or phone), otp_code, new_password
      final res = await ApiClient.post('/auth/reset-password', {
        'identifier': email,
        'otp_code': otp,
        'new_password': newPass,
      });

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (res != null && res['success'] == true) {
        setState(() => _step = 3);
      } else {
        _showError(res?['message']?.toString() ?? 'Reset failed. Check your OTP and try again.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Could not reach server. Please try again.');
    }
  }

  // ── Resend OTP ────────────────────────────────────────────────────────────
  Future<void> _handleResend() async {
    if (_resendCooldown > 0) return;
    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    await AuthService.requestOtp(identifier: email, purpose: 'reset');
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _resendCooldown = 60;
    });
    _startCooldown();
    _showSuccess('New code sent! Check your email.');
  }

  void _startCooldown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendCooldown--);
      return _resendCooldown > 0;
    });
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFFD32F2F)),
    );
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFF2E7D32)),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────────

  Widget _buildField(String label, String hint, IconData icon, TextEditingController ctrl, {
    TextInputType kbType = TextInputType.text,
    bool obscure = false,
    int maxLength = 64,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F2A4C), letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: kbType,
          obscureText: obscure,
          maxLength: maxLength,
          style: const TextStyle(fontSize: 15, color: Color(0xFF0F2A4C)),
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFD3DCFA), width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF4A89DC), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // ── Scaffold ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
              ),
              child: const Icon(Icons.verified_user, color: Color(0xFF0F2A4C), size: 22),
            ),
            const SizedBox(width: 10),
            const Text('Safe Senior',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F2A4C))),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF2F5F9), Color(0xFFE4EBF5)],
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 36.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF0F2644).withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: _step == 1
                        ? _buildStep1()
                        : _step == 2
                            ? _buildStep2()
                            : _buildSuccess(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 1: Enter Email ───────────────────────────────────────────────────
  Widget _buildStep1() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(color: Color(0xFFDCE8FC), shape: BoxShape.circle),
          child: const Icon(Icons.restart_alt_rounded, size: 34, color: Color(0xFF0F2A4C)),
        ),
        const SizedBox(height: 20),
        const Text('Forgot Password?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F2A4C), height: 1.15, letterSpacing: -0.5)),
        const SizedBox(height: 12),
        const Text("Enter your account email and we'll send you a reset code.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.5, color: Color(0xFF5A6E85), height: 1.4)),
        const SizedBox(height: 32),
        _buildField('Email Address', 'name@example.com', Icons.email_outlined, _emailController, kbType: TextInputType.emailAddress),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSendOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF285BA3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              elevation: 4,
              shadowColor: const Color(0xFF285BA3).withOpacity(0.3),
            ),
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Send Reset Code', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.arrow_back, size: 16, color: Color(0xFF0F2A4C)),
            SizedBox(width: 6),
            Text('Back to Login', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F2A4C))),
          ]),
        ),
      ],
    );
  }

  // ── Step 2: Enter OTP + New Password ─────────────────────────────────────
  Widget _buildStep2() {
    final email = _emailController.text.trim();
    final masked = email.contains('@') ? '${email[0]}***@${email.split('@').last}' : email;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(color: Color(0xFFDCE8FC), shape: BoxShape.circle),
          child: const Icon(Icons.mark_email_read_outlined, size: 34, color: Color(0xFF0F2A4C)),
        ),
        const SizedBox(height: 20),
        const Text('Check Your Email',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0F2A4C), letterSpacing: -0.5)),
        const SizedBox(height: 10),
        Text('A 6-digit code was sent to\n$masked',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14.5, color: Color(0xFF5A6E85), height: 1.4)),
        const SizedBox(height: 28),

        _buildField('Reset Code', '6-digit code from email', Icons.lock_clock_outlined, _otpController,
            kbType: TextInputType.number, maxLength: 6),
        const SizedBox(height: 16),
        _buildField('New Password', 'At least 8 characters', Icons.lock_outline, _newPassController, obscure: true),
        const SizedBox(height: 16),
        _buildField('Confirm Password', 'Re-enter your new password', Icons.lock_outline, _confirmController, obscure: true),
        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF285BA3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              elevation: 4,
            ),
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Reset Password', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                      SizedBox(width: 8),
                      Icon(Icons.check_rounded, size: 20),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: (_resendCooldown > 0 || _isLoading) ? null : _handleResend,
          child: Text(
            _resendCooldown > 0
                ? 'Resend Code (0:${_resendCooldown.toString().padLeft(2, '0')})'
                : 'Resend Code',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _resendCooldown > 0 ? Colors.grey[400] : const Color(0xFF4A89DC),
            ),
          ),
        ),
      ],
    );
  }

  // ── Step 3: Success ───────────────────────────────────────────────────────
  Widget _buildSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle_outline_rounded, size: 48, color: Color(0xFF2E7D32)),
        ),
        const SizedBox(height: 24),
        const Text('Password Reset!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F2A4C))),
        const SizedBox(height: 12),
        const Text('Your password has been updated successfully.\nYou can now log in with your new password.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.5, color: Color(0xFF5A6E85), height: 1.4)),
        const SizedBox(height: 36),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF285BA3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              elevation: 4,
            ),
            child: const Text('Back to Login', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}
