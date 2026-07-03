// lib/storage/stats_store.dart
// Persists protection counters via SharedPreferences (simple key-value).

import 'package:shared_preferences/shared_preferences.dart';
import '../models/protection_stats.dart';

class StatsStore {
  static const String _keyTotal = 'stats_total_blocked';
  static const String _keySpamCalls = 'stats_spam_calls';
  static const String _keyPhishingSms = 'stats_phishing_sms';
  static const String _keyScanned = 'stats_messages_scanned';
  static const String _keyCalls = 'stats_calls_protected';

  static Future<ProtectionStats> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ProtectionStats(
      totalBlocked: prefs.getInt(_keyTotal) ?? 0,
      spamCallsBlocked: prefs.getInt(_keySpamCalls) ?? 0,
      phishingSmsBlocked: prefs.getInt(_keyPhishingSms) ?? 0,
      messagesScanned: prefs.getInt(_keyScanned) ?? 0,
      callsProtected: prefs.getInt(_keyCalls) ?? 0,
    );
  }

  static Future<void> save(ProtectionStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTotal, stats.totalBlocked);
    await prefs.setInt(_keySpamCalls, stats.spamCallsBlocked);
    await prefs.setInt(_keyPhishingSms, stats.phishingSmsBlocked);
    await prefs.setInt(_keyScanned, stats.messagesScanned);
    await prefs.setInt(_keyCalls, stats.callsProtected);
  }

  static Future<void> incrementBlocked({bool isCall = false}) async {
    final stats = await load();
    await save(stats.incrementBlocked(isCall: isCall));
  }

  static Future<void> incrementScanned() async {
    final stats = await load();
    await save(stats.incrementScanned());
  }

  static Future<void> incrementCallsProtected() async {
    final stats = await load();
    await save(stats.incrementCallsProtected());
  }

  static Future<void> resetAll() async {
    await save(const ProtectionStats());
  }
}
