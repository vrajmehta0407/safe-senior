// lib/services/detection/link_and_code_detector.dart
import '../../utils/constants.dart';

class LinkAndCodeDetector {
  /// Returns true if message contains a URL.
  static bool hasLink(String body) {
    return AppConstants.urlPattern.hasMatch(body);
  }

  /// Returns true if message contains a numeric code (4–8 digits, not part of a larger number).
  static bool hasCode(String body) {
    return AppConstants.otpPattern.hasMatch(body);
  }

  /// Returns the first numeric code found, or null.
  static String? extractCode(String body) {
    final match = AppConstants.otpPattern.firstMatch(body);
    return match?.group(0);
  }

  /// Returns all URLs found in the message.
  static List<String> extractUrls(String body) {
    return AppConstants.urlPattern.allMatches(body).map((m) => m.group(0)!).toList();
  }
}
