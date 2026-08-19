// lib/services/trusted_sender_cache.dart
// In-memory cache of the user's trusted senders fetched from the backend.
// Loaded at startup and refreshed when the user adds/removes entries.

import 'package:flutter/foundation.dart';
import 'api_client.dart';

class TrustedSenderCache {
  static final Set<String> _senders = {};

  /// Fetch trusted senders from server and cache them.
  static Future<void> sync() async {
    try {
      final res = await ApiClient.get('/trusted-senders');
      if (res == null || res['success'] != true) return;
      final list = (res['trustedSenders'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      _senders.clear();
      for (final s in list) {
        final sender = s['sender'] as String?;
        if (sender != null) _senders.add(sender.toUpperCase());
      }
      if (kDebugMode) print('[TrustedSenderCache] Synced ${_senders.length} trusted senders');
    } catch (e) {
      if (kDebugMode) print('[TrustedSenderCache] Sync failed: $e');
    }
  }

  /// Returns true if the given sender is in the user's personal trusted list.
  static bool isTrusted(String sender) => _senders.contains(sender.toUpperCase());

  /// Add to in-memory cache immediately (before next server sync).
  static void addLocal(String sender) => _senders.add(sender.toUpperCase());

  /// Remove from in-memory cache immediately.
  static void removeLocal(String sender) => _senders.remove(sender.toUpperCase());
}
