// lib/services/detection/multilingual_detector.dart
import '../../utils/constants.dart';

class MultilingualDetector {
  /// Returns true if the body contains scam keywords in supported regional languages.
  static bool hasMultilingualScamKeywords(String body) {
    return AppConstants.multilingualScamKeywords.any((kw) => body.contains(kw));
  }

  static List<String> matchedKeywords(String body) {
    return AppConstants.multilingualScamKeywords.where((kw) => body.contains(kw)).toList();
  }
}
