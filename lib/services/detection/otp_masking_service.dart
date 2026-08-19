// lib/services/detection/otp_masking_service.dart

class OtpMaskingService {
  static final RegExp _otpRegex = RegExp(r'(?<!\d)(\d{3}[-\s]\d{3}|\d{4,8})(?!\d)');

  /// Replaces any numeric codes (4–8 digits or 3-3 hyphen/space separated) with asterisks.
  static String maskCodes(String body) {
    return body.replaceAllMapped(_otpRegex, (match) {
      final code = match.group(0)!;
      return code.replaceAll(RegExp(r'\d'), '*');
    });
  }

  /// Returns true if the body contains a maskable code.
  static bool hasMaskableCode(String body) => _otpRegex.hasMatch(body);
}

