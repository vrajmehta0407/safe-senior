// lib/storage/message_store.dart
// Hive-backed store for scanned and blocked messages.

import 'package:hive_flutter/hive_flutter.dart';
import '../models/scanned_message.dart';
import '../utils/constants.dart';

class MessageStore {
  static Box<ScannedMessage>? _box;

  static Future<void> init() async {
    _box = await Hive.openBox<ScannedMessage>(AppConstants.messageBoxName);
  }

  static Box<ScannedMessage> get _instance {
    if (_box == null || !_box!.isOpen) throw StateError('MessageStore not initialized.');
    return _box!;
  }

  /// Add a newly scanned message.
  static Future<void> addMessage(ScannedMessage message) async {
    await _instance.add(message);
  }

  /// All messages, newest first.
  static List<ScannedMessage> getAllMessages() {
    return _instance.values.toList().reversed.toList();
  }

  /// Only danger/blocked messages.
  static List<ScannedMessage> getBlockedMessages() {
    return _instance.values
        .where((m) => m.riskLevel == RiskLevel.danger)
        .toList()
        .reversed
        .toList();
  }

  /// Messages from last 24h from a specific sender.
  static List<ScannedMessage> getRecentFromSender(String sender, {Duration window = const Duration(hours: 24)}) {
    final cutoff = DateTime.now().subtract(window);
    return _instance.values
        .where((m) => m.sender == sender && m.receivedAt.isAfter(cutoff))
        .toList();
  }

  /// Mark a message as user-confirmed scam.
  static Future<void> markAsUserConfirmedScam(int index) async {
    final msg = _instance.getAt(index);
    if (msg != null) {
      msg.isUserConfirmedScam = true;
      await msg.save();
    }
  }

  /// Mark a message as acknowledged.
  static Future<void> markAsAcknowledged(int index) async {
    final msg = _instance.getAt(index);
    if (msg != null) {
      msg.isAcknowledged = true;
      await msg.save();
    }
  }

  /// Clear all messages.
  static Future<void> clearAll() async {
    await _instance.clear();
  }

  static int get count => _instance.length;
}
