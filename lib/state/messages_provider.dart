// lib/state/messages_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scanned_message.dart';
import '../storage/message_store.dart';
import '../services/sms_service.dart';

class MessagesNotifier extends StateNotifier<List<ScannedMessage>> {
  MessagesNotifier() : super([]) {
    _load();
  }

  void _load() {
    state = MessageStore.getAllMessages();
  }

  Future<ScannedMessage> processMessage({
    required String sender,
    required String body,
  }) async {
    final message = await SmsService.processMessage(sender: sender, body: body);
    _load(); // Refresh state from store
    return message;
  }

  Future<void> markAsUserConfirmedScam(int index) async {
    await MessageStore.markAsUserConfirmedScam(index);
    _load();
  }

  Future<void> markAsAcknowledged(int index) async {
    await MessageStore.markAsAcknowledged(index);
    _load();
  }

  void refresh() => _load();

  List<ScannedMessage> get blockedMessages =>
      state.where((m) => m.riskLevel == RiskLevel.danger).toList();

  List<ScannedMessage> get safeMessages =>
      state.where((m) => m.riskLevel == RiskLevel.safe).toList();
}

final messagesProvider =
    StateNotifierProvider<MessagesNotifier, List<ScannedMessage>>(
  (ref) => MessagesNotifier(),
);

final blockedMessagesProvider = Provider<List<ScannedMessage>>((ref) {
  return ref.watch(messagesProvider).where((m) => m.riskLevel == RiskLevel.danger).toList();
});
