// lib/services/detection/keyword_detector.dart
import '../../utils/constants.dart';

class KeywordDetector {
  /// Returns true if the message body contains any suspicious keyword.
  static bool hasKeywords(String body) {
    final lower = body.toLowerCase();
    return AppConstants.suspiciousKeywords.any((kw) => lower.contains(kw));
  }

  /// Returns list of matched keywords.
  static List<String> matchedKeywords(String body) {
    final lower = body.toLowerCase();
    return AppConstants.suspiciousKeywords.where((kw) => lower.contains(kw)).toList();
  }
}
