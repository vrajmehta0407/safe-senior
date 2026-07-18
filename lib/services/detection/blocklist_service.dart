// lib/services/detection/blocklist_service.dart
// Loads the bundled scam_patterns.json asset and optionally refreshes from backend.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../api_client.dart';

class BlocklistService {
  static List<String> _senderPrefixBlocklist = [];
  static List<RegExp> _patternBlocklist = [];
  static List<String> _domainBlocklist = [];
  static bool _initialized = false;

  /// Call once in main() before runApp.
  static Future<void> init() async {
    try {
      final json = await rootBundle.loadString('assets/scam_patterns.json');
      _parsePatterns(json);
      _initialized = true;
      if (kDebugMode) {
        print('[BlocklistService] Loaded ${_senderPrefixBlocklist.length} sender prefixes, '
            '${_patternBlocklist.length} patterns, ${_domainBlocklist.length} domains.');
      }
    } catch (e) {
      if (kDebugMode) print('[BlocklistService] Failed to load bundled list: $e');
    }
  }

  /// Try to refresh from the backend; silently no-ops on failure.
  static Future<void> refreshFromBackend() async {
    try {
      final data = await ApiClient.getScamPatterns();
      if (data != null && data['patterns'] != null) {
        _parsePatterns(jsonEncode(data));
        if (kDebugMode) print('[BlocklistService] Refreshed from backend.');
      }
    } catch (_) {}
  }

  static void _parsePatterns(String json) {
    try {
      final Map<String, dynamic> data = jsonDecode(json) as Map<String, dynamic>;

      final senders = data['sender_prefixes'];
      if (senders is List) {
        _senderPrefixBlocklist = senders.map((e) => e.toString().toUpperCase()).toList();
      }

      final patterns = data['patterns'];
      if (patterns is List) {
        _patternBlocklist = patterns
            .map((e) => e.toString())
            .map((p) {
              try {
                return RegExp(p, caseSensitive: false);
              } catch (_) {
                return RegExp(RegExp.escape(p), caseSensitive: false);
              }
            })
            .toList();
      }

      final domains = data['domains'];
      if (domains is List) {
        _domainBlocklist = domains.map((e) => e.toString().toLowerCase()).toList();
      }
    } catch (e) {
      if (kDebugMode) print('[BlocklistService] Parse error: $e');
    }
  }

  // ─── Query API ────────────────────────────────────────────────────────────

  static bool isSenderBlocked(String sender) {
    if (!_initialized) return false;
    final upper = sender.toUpperCase();
    return _senderPrefixBlocklist.any((prefix) => upper.startsWith(prefix));
  }

  static bool hasBlockedPattern(String body) {
    if (!_initialized) return false;
    return _patternBlocklist.any((r) => r.hasMatch(body));
  }

  static bool hasDangerousDomain(String body) {
    if (!_initialized) return false;
    final lower = body.toLowerCase();
    return _domainBlocklist.any((domain) => lower.contains(domain));
  }

  static List<String> matchedDomains(String body) {
    if (!_initialized) return [];
    final lower = body.toLowerCase();
    return _domainBlocklist.where((d) => lower.contains(d)).toList();
  }
}
