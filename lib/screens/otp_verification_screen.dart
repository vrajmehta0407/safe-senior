import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/api_client.dart';
import 'register_step2_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String name;
  final String contactValue;
  final bool isEmail;
  /// For phone-based signup, optionally pass the user's email too so the
  /// backend can send an email fallback if SMS delivery fails.
  final String? emailFallback;

  const OtpVerificationScreen({
    super.key,
    required this.name,
    required this.contactValue,
    this.isEmail = false,
    this.emailFallback,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _resendTimer = 30;
  Timer? _timer;
  bool _verifying = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _requestRealOtp();
    _startTimer();
  }

  Future<void> _requestRealOtp() async {
    setState(() => _isSending = true);
    try {
      if (widget.isEmail) {
        final res = await ApiClient.requestEmailOtp(email: widget.contactValue);
        if (mounted && res != null && res['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Verification code sent to ${widget.contactValue}',
                style: GoogleFonts.atkinsonHyperlegible(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppTheme.primaryTeal,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } else {
        // Pass email as fallback so backend delivers via email if SMS fails
        final res = await ApiClient.requestPhoneOtp(
          phoneNumber: widget.contactValue,
          email: widget.emailFallback,
        );
        if (mounted && res != null && res['success'] == true) {
          final smsSent = res['smsSent'] == true;
          final msg = smsSent
              ? 'SMS verification code sent to ${widget.contactValue}'
              : widget.emailFallback != null
                  ? 'SMS unavailable — code sent to ${widget.emailFallback}'
                  : 'Verification code dispatched';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                msg,
                style: GoogleFonts.atkinsonHyperlegible(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppTheme.primaryTeal,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        } else if (mounted && res != null && res['success'] != true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                res['message']?.toString() ?? 'Failed to send OTP. Please try again.',
                style: GoogleFonts.atkinsonHyperlegible(color: Colors.white),
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (_) {
      // Best-effort delivery
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendTimer = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _verify() async {
    final enteredCode = _controllers.map((c) => c.text).join();
    if (enteredCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter all 6 digits of the verification code',
            style: GoogleFonts.atkinsonHyperlegible(color: Colors.white),
          ),
          backgroundColor: AppTheme.terracottaRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _verifying = true);

    bool isVerified = false;
    String? errorMsg;

    try {
      if (widget.isEmail) {
        final res = await ApiClient.verifyEmailOtp(
          email: widget.contactValue,
          code: enteredCode,
        );
        if (res != null && res['success'] == true) {
          isVerified = true;
        } else {
          errorMsg = res?['message'] as String? ?? 'Invalid verification code. Please check your email inbox.';
        }
      } else {
        final res = await ApiClient.verifyPhoneOtp(
          phoneNumber: widget.contactValue,
          code: enteredCode,
        );
        if (res != null && res['success'] == true) {
          isVerified = true;
        } else {
          errorMsg = res?['message'] as String? ?? 'Invalid verification code. Please check your SMS.';
        }
      }
    } catch (e) {
      // Do NOT silently bypass — show a network error instead
      errorMsg = 'Could not reach server. Check your internet and try again.';
    }

    if (!mounted) return;
    setState(() => _verifying = false);

    if (isVerified) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RegisterStep2Screen(
            name: widget.name,
            phone: widget.isEmail ? '' : widget.contactValue,
            email: widget.isEmail ? widget.contactValue : (widget.emailFallback ?? ''),
            isEmail: widget.isEmail,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMsg ?? 'Incorrect OTP. Please check the code sent to your ${widget.isEmail ? "email" : "phone"}.',
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
    final isEmail = widget.isEmail;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Lock Icon Circle (Stitch Primary Container)
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          isEmail ? Icons.mark_email_read_outlined : Icons.lock_open,
                          color: const Color(0xFFE3FFFE),
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title (Stitch Headline-Lg Plus Jakarta Sans)
                    Text(
                      'Verify Your Identity',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Phone/Email text (Stitch subtitle)
                    Text(
                      isEmail
                          ? 'We\'ve sent a 6-digit secure code to\nyour email'
                          : 'We\'ve sent a 6-digit secure code to\nyour phone',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 16,
                        color: AppTheme.textLight,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.contactValue.isNotEmpty
                          ? widget.contactValue
                          : (isEmail ? 'vrajmehta934@gmail.com' : '+91 8866565480'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isEmail ? 17 : 19,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                        letterSpacing: isEmail ? 0 : 0.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 6-Pin Input Boxes (Stitch exact layout)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 44,
                          height: 52,
                          child: TextFormField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: const Color(0xFFF5F3F3),
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE3E2E2), width: 1.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE3E2E2), width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 2.5),
                              ),
                            ),
                            onChanged: (val) {
                              if (val.isNotEmpty) {
                                if (index < 5) {
                                  _focusNodes[index + 1].requestFocus();
                                } else {
                                  _focusNodes[index].unfocus();
                                  _verify();
                                }
                              } else if (val.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }
                            },
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    // Verify Code CTA (Stitch 56px full width primary button)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _verifying ? null : _verify,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: _verifying
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Verify Code',
                                    style: GoogleFonts.atkinsonHyperlegible(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, size: 20),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    const Divider(color: Color(0xFFEFEDED), height: 1),
                    const SizedBox(height: 20),

                    // Resend & Help Footer (Stitch exact)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Resend Code in ',
                          style: GoogleFonts.atkinsonHyperlegible(fontSize: 15, color: AppTheme.textLight),
                        ),
                        Text(
                          '00:${_resendTimer.toString().padLeft(2, '0')}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                    if (_resendTimer == 0) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _isSending
                            ? null
                            : () {
                                _requestRealOtp();
                                _startTimer();
                              },
                        child: Text(
                          'Resend Code',
                          style: GoogleFonts.atkinsonHyperlegible(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEmail
                                  ? 'Check your spam/junk folder or verify your email address.'
                                  : 'If SMS is delayed, check cellular reception or request a call from support.',
                              style: GoogleFonts.atkinsonHyperlegible(color: Colors.white),
                            ),
                            backgroundColor: AppTheme.primaryTeal,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      child: Text(
                        'Didn\'t receive it? Get help.',
                        style: GoogleFonts.atkinsonHyperlegible(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryTeal,
                          decoration: TextDecoration.underline,
                          decorationThickness: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
