// test/smtp_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_senior/services/email_service.dart';

void main() {
  test('EmailService generates 6-digit OTP and verifies locally', () {
    final otp = EmailService.generateOtp();
    expect(otp.length, equals(6));
    expect(int.tryParse(otp), isNotNull);

    const testEmail = 'senior.user@safesenior.app';
    // Initially not verified
    expect(EmailService.verifyLocalOtp(testEmail, otp), isFalse);
  });
}
