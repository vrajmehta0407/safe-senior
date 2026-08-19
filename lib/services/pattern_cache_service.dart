// lib/services/pattern_cache_service.dart
// Fetches scam patterns from /scam-patterns/active and caches them in Hive.
// The ScamRuleEngine can then call getPatterns() which works fully offline.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class PatternCacheService {
  static const _boxName   = 'scam_patterns_cache';
  static const _keyData    = 'patterns_data';
  static const _keyVersion = 'patterns_version';
  static const _maxAgeHours = 24; // re-fetch after 24h

  static Box? _box;

  /// Call once during app startup (after Hive.initFlutter()).
  static Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  /// Fetch fresh patterns from API and cache them. Safe to call on every startup.
  /// Returns true if patterns were updated, false if using cache or error.
  static Future<bool> syncPatterns() async {
    try {
      final result = await ApiClient.get('/scam-patterns/active');
      if (result == null || result['success'] != true) return false;

      final patterns = result['patterns'] as List<dynamic>?;
      final version  = result['version']  as String? ?? 'unknown';
      if (patterns == null || patterns.isEmpty) return false;

      await _box?.put(_keyData,    jsonEncode(patterns));
      await _box?.put(_keyVersion, '${DateTime.now().toIso8601String()}::$version');

      if (kDebugMode) print('[PatternCache] Synced ${patterns.length} patterns (v$version)');
      return true;
    } catch (e) {
      if (kDebugMode) print('[PatternCache] Sync failed (offline?): $e');
      return false;
    }
  }

  /// Returns cached patterns. Falls back to empty list if cache is empty.
  static List<Map<String, dynamic>> getPatterns() {
    final raw = _box?.get(_keyData) as String?;
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Returns the cached version string (for debug/display).
  static String get cachedVersion =>
      (_box?.get(_keyVersion) as String? ?? 'none').split('::').last;

  /// True if cache is stale (older than maxAgeHours) or empty.
  static bool get isStale {
    final ver = _box?.get(_keyVersion) as String?;
    if (ver == null) return true;
    final ts = DateTime.tryParse(ver.split('::').first);
    if (ts == null) return true;
    return DateTime.now().difference(ts).inHours >= _maxAgeHours;
  }

  /// Refreshes patterns from backend and stores them in SharedPreferences
  static Future<void> refreshFromBackend() async {
    try {
      final result = await ApiClient.get('/scam-patterns/active');
      if (result != null && result['success'] == true && result['patterns'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_scam_patterns', jsonEncode(result['patterns']));
      }
    } catch (_) {
      // Fail silently (offline-safe)
    }
  }
}
