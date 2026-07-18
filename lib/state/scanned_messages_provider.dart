// lib/state/scanned_messages_provider.dart
// Riverpod provider for scanned messages — seeded with plausible local data.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scanned_message.dart';

class ScannedMessagesNotifier extends StateNotifier<List<ScannedMessage>> {
  ScannedMessagesNotifier()
      : super([
          ScannedMessage(
            sender: 'Unknown Number',
            body: '"Your bank account has been suspended. Click here to verify your identity immediately: bit.ly/bank-alert-32..."',
            maskedBody: '"Your bank account has been suspended. Click here to verify your identity immediately: bit.ly/bank-alert-32..."',
            riskLevelIndex: 2, // danger
            reasons: ['Suspicious URL', 'Urgency language', 'Impersonates bank'],
            matchedKeywords: ['suspended', 'verify', 'immediately'],
            receivedAt: DateTime.now().subtract(const Duration(hours: 2)),
            isBlocked: true,
          ),
          ScannedMessage(
            sender: 'Amazon Support?',
            body: '"A large purchase of \$1,200 was made on your account. If this wasn\'t you, call..."',
            maskedBody: '"A large purchase of \$1,200 was made on your account. If this wasn\'t you, call..."',
            riskLevelIndex: 1, // caution
            reasons: ['Impersonates brand', 'Urgency language'],
            matchedKeywords: ['purchase', 'wasn\'t you'],
            receivedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          ScannedMessage(
            sender: 'Sarah (Granddaughter)',
            body: '"Hi Grandpa! Just checking in to see if you\'re free for dinner this Sunday? Love you!"',
            maskedBody: '"Hi Grandpa! Just checking in to see if you\'re free for dinner this Sunday? Love you!"',
            riskLevelIndex: 0, // safe
            reasons: [],
            matchedKeywords: [],
            receivedAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          ScannedMessage(
            sender: 'Pharmacy Plus',
            body: '"Your prescription refill is ready for pickup."',
            maskedBody: '"Your prescription refill is ready for pickup."',
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
