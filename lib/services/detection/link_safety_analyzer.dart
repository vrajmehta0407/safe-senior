// lib/services/detection/link_safety_analyzer.dart
import '../../utils/constants.dart';

class LinkSafetyAnalyzer {
  /// Returns true if any URL in the message uses a known shortener/phishing domain.
  static bool hasDangerousLink(String body) {
    final urls = AppConstants.urlPattern.allMatches(body).map((m) => m.group(0)!).toList();
    for (final url in urls) {
      final lowerUrl = url.toLowerCase();
      if (AppConstants.knownPhishingDomains.any((domain) => lowerUrl.contains(domain))) {
        return true;
      }
    }
    return false;
  }

  /// Returns the matched phishing domains found in the message.
  static List<String> matchedDangerousDomains(String body) {
    final urls = AppConstants.urlPattern.allMatches(body).map((m) => m.group(0)!).toList();
    final matched = <String>[];
    for (final url in urls) {
      final lowerUrl = url.toLowerCase();
      for (final domain in AppConstants.knownPhishingDomains) {
        if (lowerUrl.contains(domain) && !matched.contains(domain)) {
          matched.add(domain);
        }
      }
    }
    return matched;
  }
}
