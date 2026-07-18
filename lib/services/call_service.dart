// lib/services/call_service.dart
// Android call-state listener + call screening role management.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'platform_capabilities.dart';
import '../services/detection/scam_rule_engine.dart';
import '../services/detection/blocklist_service.dart';
import '../storage/stats_store.dart';

/// MethodChannel matching CallBlockerPlugin.kt on the Android side.
const MethodChannel _callBlockerChannel =
    MethodChannel('com.safesenior/call_blocker');

class CallService {
  static bool _monitoring = false;

  static Future<void> startMonitoring() async {
    if (!PlatformCapabilities.canMonitorSms) {
      if (kDebugMode) print('[CallService] Call monitoring not available on this platform.');
      return;
    }
    if (_monitoring) return;
    _monitoring = true;
    if (kDebugMode) print('[CallService] Call monitoring started (Android).');
  }

  static void stopMonitoring() {
    _monitoring = false;
  }

  // ─── Call Screening Role ───────────────────────────────────────────────────

  /// Asks the OS to grant the app the CallScreeningService role.
  /// The user sees a system dialog; result is returned asynchronously.
  static Future<bool> requestCallScreeningRole() async {
    if (!PlatformCapabilities.canMonitorSms) return false;
    try {
      final bool granted = await _callBlockerChannel.invokeMethod('requestCallScreeningRole');
      if (kDebugMode) print('[CallService] CallScreeningRole granted: $granted');
      return granted;
    } on PlatformException catch (e) {
      if (kDebugMode) print('[CallService] requestCallScreeningRole error: $e');
      return false;
    }
  }

  /// Returns true if the app currently holds the call screening role.
  static Future<bool> isCallScreeningRoleHeld() async {
    if (!PlatformCapabilities.canMonitorSms) return false;
    try {
      return await _callBlockerChannel.invokeMethod('isCallScreeningRoleHeld') ?? false;
    } on PlatformException {
      return false;
    }
  }

  // ─── Scoring Pipeline ─────────────────────────────────────────────────────

  /// Checks if a phone number should be blocked using the scoring pipeline.
  /// Returns true if the call should be silenced/rejected.
  static bool shouldBlockCall(String phoneNumber) {
    // 1. Check sender blocklist
    if (BlocklistService.isSenderBlocked(phoneNumber)) return true;

    // 2. Numeric sender claiming to be known brand (heuristic)
    final numericOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (numericOnly.length > 10) {
      // International numbers — run pattern check against known scam number patterns
      if (BlocklistService.hasBlockedPattern(phoneNumber)) return true;
    }

    return false;
  }

  /// Called when an incoming call is detected from an unknown/suspicious number.
  static Future<void> onSuspiciousCallDetected(String phoneNumber) async {
    if (kDebugMode) print('[CallService] Suspicious call from $phoneNumber');
    ScamRuleEngine.recordSuspiciousCall();
    await StatsStore.incrementCallsProtected();
    await StatsStore.incrementBlocked(isCall: true);
  }

  /// Called from native CallScreeningService to check the blocklist.
  /// Registered as a MethodCall handler.
  static void registerMethodCallHandler() {
    _callBlockerChannel.setMethodCallHandler((call) async {
      if (call.method == 'checkBlocklist') {
        final phoneNumber = call.arguments as String? ?? '';
        final block = shouldBlockCall(phoneNumber);
        if (block) await onSuspiciousCallDetected(phoneNumber);
        return block;
      }
      return false;
    });
  }
}
