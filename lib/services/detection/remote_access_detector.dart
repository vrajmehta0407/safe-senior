// lib/services/detection/remote_access_detector.dart
import '../../utils/constants.dart';

class RemoteAccessDetector {
  /// Returns true if message mentions remote access tools.
  static bool hasRemoteAccessKeywords(String body) {
    final lower = body.toLowerCase();
    return AppConstants.remoteAccessKeywords.any((kw) => lower.contains(kw));
  }

  static List<String> matchedTools(String body) {
    final lower = body.toLowerCase();
    return AppConstants.remoteAccessKeywords.where((kw) => lower.contains(kw)).toList();
  }
}
