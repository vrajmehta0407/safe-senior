// lib/state/scanned_messages_provider.dart
// Riverpod provider for scanned messages — seeded with plausible local Indian data.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scanned_message.dart';

class ScannedMessagesNotifier extends StateNotifier<List<ScannedMessage>> {
  ScannedMessagesNotifier()
      : super([
          ScannedMessage(
            sender: 'VM-SBIINB (Spoofed)',
            body: '"Your SBI YONO account has been suspended due to pending PAN KYC. Click here immediately to verify: http://sbi-kyc-verify-882.in"',
            maskedBody: '"Your SBI YONO account has been suspended due to pending PAN KYC. Click here immediately to verify: http://sbi-kyc-verify-882.in"',
            riskLevelIndex: 2, // danger
            reasons: ['Suspicious Phishing URL', 'Urgency Coercion', 'Impersonates SBI Bank'],
            matchedKeywords: ['suspended', 'kyc', 'immediately', 'verify'],
            receivedAt: DateTime.now().subtract(const Duration(hours: 2)),
            isBlocked: true,
          ),
          ScannedMessage(
            sender: 'Amazon India Support?',
            body: '"A large debit order of ₹45,999 on iPhone 16 was placed from your account. If this was not you, call +91 98765 43210 immediately."',
            maskedBody: '"A large debit order of ₹45,999 on iPhone 16 was placed from your account. If this was not you, call +91 98765 43210 immediately."',
            riskLevelIndex: 1, // caution
            reasons: ['Impersonates Brand', 'Urgency Call-back Bait'],
            matchedKeywords: ['order', 'was not you', 'immediately'],
            receivedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          ScannedMessage(
            sender: 'Priya (Granddaughter)',
            body: '"Namaste Dadaji! Just checking in to see if you took your evening medicines? Amit Bhaiyya is visiting tomorrow. Love you!"',
            maskedBody: '"Namaste Dadaji! Just checking in to see if you took your evening medicines? Amit Bhaiyya is visiting tomorrow. Love you!"',
            riskLevelIndex: 0, // safe
            reasons: [],
            matchedKeywords: [],
            receivedAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          ScannedMessage(
            sender: 'Apollo Pharmacy Bengaluru',
            body: '"Your monthly prescription refill is ready for free home delivery. Order #AP-99201."',
            maskedBody: '"Your monthly prescription refill is ready for free home delivery. Order #AP-99201."',
            riskLevelIndex: 0, // safe
            reasons: [],
            matchedKeywords: [],
            receivedAt: DateTime.now().subtract(const Duration(days: 6)),
          ),
        ]);

  void markReported(ScannedMessage msg) {
    state = [
      for (final m in state)
        if (m.sender == msg.sender && m.receivedAt == msg.receivedAt)
          ScannedMessage(
            sender: m.sender,
            body: m.body,
            maskedBody: m.maskedBody,
            riskLevelIndex: 2,
            reasons: m.reasons,
            matchedKeywords: m.matchedKeywords,
            receivedAt: m.receivedAt,
            isBlocked: true,
            isUserConfirmedScam: true,
          )
        else
          m,
    ];
  }
}

final scannedMessagesProvider =
    StateNotifierProvider<ScannedMessagesNotifier, List<ScannedMessage>>(
  (ref) => ScannedMessagesNotifier(),
);

final suspiciousMessagesProvider = Provider<List<ScannedMessage>>((ref) {
  return ref
      .watch(scannedMessagesProvider)
      .where((m) => m.riskLevelIndex > 0)
      .toList();
});
