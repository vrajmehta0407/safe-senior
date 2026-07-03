// lib/services/detection/authority_impersonation_detector.dart
import '../../utils/constants.dart';

class AuthorityImpersonationDetector {
  /// Returns true if message appears to impersonate authority figures.
  static bool hasAuthorityImpersonation(String body) {
    final lower = body.toLowerCase();
    return AppConstants.authorityImpersonationKeywords.any((kw) => lower.contains(kw));
  }

  static List<String> matchedAuthorities(String body) {
    final lower = body.toLowerCase();
    return AppConstants.authorityImpersonationKeywords.where((kw) => lower.contains(kw)).toList();
  }
}
