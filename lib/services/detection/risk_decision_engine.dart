// lib/services/detection/risk_decision_engine.dart
// Exact rule table from the master prompt — DO NOT deviate from the rule order.

import '../../models/scanned_message.dart';

class RiskDecisionResult {
  final RiskLevel level;
  final List<String> reasons;

  const RiskDecisionResult({required this.level, required this.reasons});
}

class RiskDecisionEngine {
  /// Determines risk level from boolean feature flags.
  /// Rule order must be preserved exactly as documented.
  static RiskDecisionResult determineRisk({
    required bool hasKeywords,
    required bool hasUrgency,
    required bool hasLink,
    required bool hasCode,
    required bool isUnknownSender,
  }) {
    // Rule 1: hasCode AND hasLink → danger
    if (hasCode && hasLink) {
      return const RiskDecisionResult(
        level: RiskLevel.danger,
        reasons: ['Message contains both a code and a link — classic OTP phishing pattern.'],
      );
    }

    // Rule 2: hasUrgency AND (hasLink OR hasCode) → danger
    if (hasUrgency && (hasLink || hasCode)) {
      return const RiskDecisionResult(
        level: RiskLevel.danger,
        reasons: ['Urgent language combined with a link or code — high-risk phishing indicator.'],
      );
    }

    // Rule 3: isUnknownSender AND (hasCode OR hasLink OR hasUrgency) → danger
    if (isUnknownSender && (hasCode || hasLink || hasUrgency)) {
      return const RiskDecisionResult(
        level: RiskLevel.danger,
        reasons: ['Unknown sender with suspicious content (code, link, or urgency).'],
      );
    }

    // Rule 4: hasKeywords → caution
    if (hasKeywords) {
      return const RiskDecisionResult(
        level: RiskLevel.caution,
        reasons: ['Message contains suspicious keywords.'],
      );
    }

    // Rule 5: isUnknownSender AND hasLink → caution
    if (isUnknownSender && hasLink) {
      return const RiskDecisionResult(
        level: RiskLevel.caution,
        reasons: ['Unknown sender sharing a link.'],
      );
    }

    // Rule 6: otherwise → safe
    return const RiskDecisionResult(
      level: RiskLevel.safe,
      reasons: ['No suspicious patterns detected.'],
    );
  }
}
