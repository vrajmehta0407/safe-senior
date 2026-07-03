// lib/services/detection/scam_rule_engine.dart
// Master orchestrator for scam detection. Runs all sub-detectors in the exact
// priority order defined in the master prompt Section 5.

import '../../models/scanned_message.dart';
import '../../storage/message_store.dart';
import 'keyword_detector.dart';
import 'urgency_detector.dart';
import 'link_and_code_detector.dart';
import 'link_safety_analyzer.dart';
import 'authority_impersonation_detector.dart';
import 'bank_name_validator.dart';
import 'remote_access_detector.dart';
import 'multilingual_detector.dart';
import 'otp_masking_service.dart';
import 'risk_decision_engine.dart';

/// Result of the full scam analysis pipeline.
class AnalysisResult {
  final RiskLevel riskLevel;
  final String maskedBody;
  final String? extractedCode;
  final List<String> reasons;
  final List<String> matchedKeywords;

  const AnalysisResult({
    required this.riskLevel,
    required this.maskedBody,
    required this.extractedCode,
    required this.reasons,
    required this.matchedKeywords,
  });
}

/// Registry of trusted sender IDs. Add real bank/service IDs here.
const List<String> _trustedSenders = [
  'SBIINB', 'HDFCBK', 'ICICIBK', 'AXISBK', 'KOTAKB',
  'DM-HDFCBK', 'VM-SBIINB', 'AM-BOIIND',
];

/// Timestamp of the last suspicious call detected (used for orchestration step 2).
DateTime? _lastSuspiciousCallTime;

class ScamRuleEngine {
  /// Call this when a suspicious call is detected to arm the OTP+call check.
  static void recordSuspiciousCall() {
    _lastSuspiciousCallTime = DateTime.now();
  }

  /// Returns true if a suspicious call occurred within the last 5 minutes.
  static bool _recentSuspiciousCall() {
    if (_lastSuspiciousCallTime == null) return false;
    return DateTime.now().difference(_lastSuspiciousCallTime!).inMinutes < 5;
  }

  /// Main analysis entry point. Returns an [AnalysisResult].
  static AnalysisResult analyze(String sender, String body) {
    final reasons = <String>[];
    final keywords = <String>[];

    // 1. Trusted sender → safe immediately
    if (_trustedSenders.contains(sender.toUpperCase())) {
      return AnalysisResult(
        riskLevel: RiskLevel.safe,
        maskedBody: OtpMaskingService.maskCodes(body),
        extractedCode: LinkAndCodeDetector.extractCode(body),
        reasons: ['Trusted Sender'],
        matchedKeywords: [],
      );
    }

    // 2. Suspicious call within 5 min + OTP-like code in message → force danger
    if (_recentSuspiciousCall() && LinkAndCodeDetector.hasCode(body)) {
      return _buildResult(
        riskLevel: RiskLevel.danger,
        body: body,
        reasons: ['⚠️ SCAM ALERT: Suspicious call + OTP detected!'],
        keywords: keywords,
      );
    }

    // 3. Remote-access keywords → force danger
    if (RemoteAccessDetector.hasRemoteAccessKeywords(body)) {
      final tools = RemoteAccessDetector.matchedTools(body);
      return _buildResult(
        riskLevel: RiskLevel.danger,
        body: body,
        reasons: ['Remote access tool mentioned: ${tools.join(", ")}'],
        keywords: tools,
      );
    }

    // 4. Fake/lookalike bank sender → force danger
    if (BankNameValidator.isFakeBankSender(sender)) {
      return _buildResult(
        riskLevel: RiskLevel.danger,
        body: body,
        reasons: ['Suspicious sender ID mimicking a bank: $sender'],
        keywords: keywords,
      );
    }

    // 5. Known shortener/phishing domains → contributes to danger
    bool hasDangerousLink = LinkSafetyAnalyzer.hasDangerousLink(body);
    if (hasDangerousLink) {
      final domains = LinkSafetyAnalyzer.matchedDangerousDomains(body);
      reasons.add('Known phishing domain found: ${domains.join(", ")}');
    }

    // 6. Core detectors
    final hasKeywordsResult = KeywordDetector.hasKeywords(body);
    final hasUrgency = UrgencyDetector.hasUrgency(body);
    final hasLink = LinkAndCodeDetector.hasLink(body) || hasDangerousLink;
    final hasCode = LinkAndCodeDetector.hasCode(body);
    keywords.addAll(KeywordDetector.matchedKeywords(body));
    keywords.addAll(UrgencyDetector.matchedPhrases(body));

    // Authority impersonation adds to keywords
    if (AuthorityImpersonationDetector.hasAuthorityImpersonation(body)) {
      keywords.addAll(AuthorityImpersonationDetector.matchedAuthorities(body));
    }

    // 7. Multilingual keyword scan
    if (MultilingualDetector.hasMultilingualScamKeywords(body)) {
      keywords.addAll(MultilingualDetector.matchedKeywords(body));
      reasons.add('Multilingual scam keywords detected.');
    }

    // 8. Check learned user-confirmed scam patterns (repetition from same sender)
    final recentFromSender = MessageStore.getRecentFromSender(sender);
    
    // 9. 3+ scam attempts from same/similar sender in 24h → force danger
    final confirmedFromSender = recentFromSender
        .where((m) => m.riskLevel == RiskLevel.danger || m.isUserConfirmedScam)
        .length;
    if (confirmedFromSender >= 2) {
      // 2 previous + this one = 3+ attempts
      reasons.add('$confirmedFromSender+ previous danger messages from this sender in 24h.');
      return _buildResult(
        riskLevel: RiskLevel.danger,
        body: body,
        reasons: reasons,
        keywords: keywords,
      );
    }

    // 10. Compute via RiskDecisionEngine
    final isUnknownSender = !_trustedSenders.contains(sender.toUpperCase());
    final decision = RiskDecisionEngine.determineRisk(
      hasKeywords: hasKeywordsResult,
      hasUrgency: hasUrgency,
      hasLink: hasLink,
      hasCode: hasCode,
      isUnknownSender: isUnknownSender,
    );
    reasons.addAll(decision.reasons);

    return _buildResult(
      riskLevel: decision.level,
      body: body,
      reasons: reasons,
      keywords: keywords,
    );
  }

  static AnalysisResult _buildResult({
    required RiskLevel riskLevel,
    required String body,
    required List<String> reasons,
    required List<String> keywords,
  }) {
    // 11. Mask any numeric codes before storing/displaying
    final maskedBody = OtpMaskingService.maskCodes(body);
    final extractedCode = LinkAndCodeDetector.extractCode(body);

    return AnalysisResult(
      riskLevel: riskLevel,
      maskedBody: maskedBody,
      extractedCode: extractedCode,
      reasons: reasons.toSet().toList(), // deduplicate
      matchedKeywords: keywords.toSet().toList(),
    );
  }
}
