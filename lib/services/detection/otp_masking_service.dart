// lib/services/detection/otp_masking_service.dart
import '../../utils/constants.dart';

class OtpMaskingService {
  /// Replaces any numeric codes (4–8 digits) in the body with '****'.
  static String maskCodes(String body) {
    return body.replaceAllMapped(AppConstants.otpPattern, (match) {
      final code = match.group(0)!;
      return '*' * code.length;
    });
  }

  /// Returns true if the body contains a maskable code.
  static bool hasMaskableCode(String body) => AppConstants.otpPattern.hasMatch(body);
}
