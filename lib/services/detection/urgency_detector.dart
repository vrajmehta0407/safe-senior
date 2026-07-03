// lib/services/detection/urgency_detector.dart
import '../../utils/constants.dart';

class UrgencyDetector {
  /// Returns true if the message contains urgency phrases.
  static bool hasUrgency(String body) {
    final lower = body.toLowerCase();
    return AppConstants.urgencyPhrases.any((phrase) => lower.contains(phrase));
  }

  /// Returns list of matched urgency phrases.
  static List<String> matchedPhrases(String body) {
    final lower = body.toLowerCase();
    return AppConstants.urgencyPhrases.where((p) => lower.contains(p)).toList();
  }
}
