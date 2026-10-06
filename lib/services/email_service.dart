// lib/services/email_service.dart
// Direct SMTP email delivery service for SafeSenior using Gmail SMTP.
// Provides guaranteed email OTP delivery even when the backend is offline.

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class _PendingOtp {
  final String code;
  final DateTime expiresAt;

  _PendingOtp({required this.code, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class EmailService {
  static const String _smtpUsername = 'vrajmehta0407@gmail.com';
  static const String _smtpPassword = 'rcjjobumdutrbdmh';
  static const String _senderName   = 'Safe Senior';

  // In-memory cache for pending OTPs sent directly via SMTP
  static final Map<String, _PendingOtp> _pendingOtps = {};

  /// Generates a secure random 6-digit OTP code.
  static String generateOtp() {
    final random = Random.secure();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Sends an OTP to the given [toEmail] directly using Gmail SMTP.
  /// Tries Port 587 (STARTTLS) first, then Port 465 (SSL).
  /// Returns `true` if successfully sent, `false` otherwise.
  static Future<bool> sendOtp({
    required String toEmail,
    required String otp,
    String purpose = 'verification',
  }) async {
    final cleanEmail = toEmail.trim().toLowerCase();
    final purposeTitle = _purposeTitle(purpose);

    // Cache the OTP for 15 minutes locally so verification succeeds
    _pendingOtps[cleanEmail] = _PendingOtp(
      code: otp,
      expiresAt: DateTime.now().add(const Duration(minutes: 15)),
    );

    final message = Message()
      ..from = const Address(_smtpUsername, _senderName)
      ..recipients.add(cleanEmail)
      ..subject = '$otp is your Safe Senior $purposeTitle code'
      ..text = 'Your Safe Senior $purposeTitle code is: $otp\n\n'
          'This code expires in 15 minutes.\n\n'
          'Never share this code with anyone.\n'
          'Safe Senior – Protecting seniors from digital scams.'
      ..html = _buildHtmlEmail(otp, purposeTitle);

    // 1. Try Port 587 (STARTTLS) - standard for Gmail and cellular networks
    try {
      final smtpServer587 = SmtpServer(
        'smtp.gmail.com',
        port: 587,
        ssl: false,
        username: _smtpUsername,
        password: _smtpPassword,
        allowInsecure: false,
      );
      final report = await send(message, smtpServer587);
      if (kDebugMode) print('[EmailService] SMTP sent on 587: $report');
      return true;
    } catch (e587) {
      if (kDebugMode) print('[EmailService] Port 587 error: $e587. Trying port 465...');
    }

    // 2. Try Port 465 (SSL)
    try {
      final smtpServer465 = gmail(_smtpUsername, _smtpPassword);
      final report = await send(message, smtpServer465);
      if (kDebugMode) print('[EmailService] SMTP sent on 465: $report');
      return true;
    } catch (e465) {
      if (kDebugMode) print('[EmailService] Port 465 error: $e465');
    }

    return false;
  }

  static String _buildHtmlEmail(String otp, String purposeTitle) {
    return '''
<div style="font-family: Arial, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 480px; margin: 0 auto; padding: 28px; background: #F8FAFC; border-radius: 16px; border: 1px solid #E2E8F0;">
  <div style="background: linear-gradient(135deg, #0D9488, #115E59); padding: 22px; border-radius: 14px; text-align: center; margin-bottom: 24px; box-shadow: 0 4px 12px rgba(13, 148, 136, 0.2);">
    <span style="font-size: 36px; display: block; margin-bottom: 8px;">🛡️</span>
    <h1 style="color: #FFFFFF; margin: 0; font-size: 22px; font-weight: 700; letter-spacing: 0.5px;">Safe Senior</h1>
    <p style="color: #CCFBF1; margin: 4px 0 0; font-size: 13px;">Scam Protection & Emergency Safety</p>
  </div>

  <div style="background: #FFFFFF; border-radius: 12px; padding: 24px; box-shadow: 0 2px 6px rgba(0,0,0,0.04); margin-bottom: 20px;">
    <h2 style="color: #0F172A; font-size: 18px; margin: 0 0 12px; font-weight: 600;">$purposeTitle</h2>
    <p style="color: #475569; font-size: 14px; line-height: 1.6; margin: 0 0 20px;">
      Use the following 6-digit verification code to complete your action. This code will expire in <strong>15 minutes</strong>.
    </p>

    <div style="background: #F0FDFA; border: 2px dashed #0D9488; border-radius: 12px; padding: 18px; text-align: center; margin-bottom: 20px;">
      <span style="font-size: 38px; font-weight: 800; letter-spacing: 10px; color: #0D9488; display: block;">$otp</span>
    </div>

    <p style="color: #64748B; font-size: 12px; line-height: 1.5; margin: 0; text-align: center;">
      🔒 Never share this code with anyone. Safe Senior employees will never ask for your code.
    </p>
  </div>

  <p style="color: #94A3B8; font-size: 11px; text-align: center; margin: 0 0 8px;">
    If you did not request this verification code, please ignore this email.
  </p>
  <div style="border-top: 1px solid #E2E8F0; margin-top: 16px; padding-top: 12px; text-align: center;">
    <p style="color: #CBD5E1; font-size: 11px; margin: 0;">
      © ${DateTime.now().year} Safe Senior. Dedicated to protecting elders and families.
    </p>
  </div>
</div>
''';
  }

  /// Verifies an OTP against locally cached OTPs sent via SMTP.
  static bool verifyLocalOtp(String email, String code) {
    final cleanEmail = email.trim().toLowerCase();
    final cleanCode = code.trim();

    final pending = _pendingOtps[cleanEmail];
    if (pending == null) return false;

    if (pending.isExpired) {
      _pendingOtps.remove(cleanEmail);
      return false;
    }

    if (pending.code == cleanCode) {
      _pendingOtps.remove(cleanEmail);
      return true;
    }

    return false;
  }

  static String _purposeTitle(String purpose) {
    switch (purpose.toLowerCase()) {
      case 'login':
        return 'Login Verification';
      case 'reset':
      case 'forgot_pin':
        return 'Password Reset';
      case '2fa':
        return 'Two-Factor Authentication';
      case 'registration':
      case 'verification':
      default:
        return 'Email Verification';
    }
  }
}
