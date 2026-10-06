// lib/services/call_service.dart
// Android call-state listener + call screening role management.
// Intercepts scam/fake calls and triggers full-screen red warning alerts.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'api_client.dart';
import 'platform_capabilities.dart';
import 'notification_service.dart';
import 'voice_service.dart';
import 'pattern_cache_service.dart';
import '../services/detection/scam_rule_engine.dart';
import '../services/detection/blocklist_service.dart';
import '../storage/stats_store.dart';

/// Callback invoked when a dangerous / suspicious call is detected.
typedef OnDangerCall = void Function(String phoneNumber, String reason);

/// Callback invoked to refresh stats in Riverpod after a call block.
typedef OnStatsChanged = void Function();

/// MethodChannel matching CallBlockerPlugin.kt on the Android side.
const MethodChannel _callBlockerChannel =
    MethodChannel('com.safesenior/call_blocker');

class CallService {
  static OnDangerCall? _onDangerCallCallback;
  static OnStatsChanged? _onStatsChangedCallback;
  static bool _monitoring = false;

  /// Registers a callback for danger-level Call detections.
  /// Used by main.dart / AlertManager to pop up the red WarningAlertScreen.
  static void setDangerCallback(OnDangerCall callback) {
    _onDangerCallCallback = callback;
  }

  /// Registers a callback invoked after call stats change.
  static void setStatsChangedCallback(OnStatsChanged callback) {
    _onStatsChangedCallback = callback;
  }

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
    if (phoneNumber.trim().isEmpty) return false;

    // 1. Check sender blocklist
    if (BlocklistService.isSenderBlocked(phoneNumber)) return true;

    // 2. Pattern check against known scam number patterns
    if (BlocklistService.hasBlockedPattern(phoneNumber)) return true;

    // 3. Known high-risk international telecom fraud prefixes
    final clean = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    const suspiciousPrefixes = ['+92', '+234', '+229', '+232', '+252', '+880'];
    for (final prefix in suspiciousPrefixes) {
      if (clean.startsWith(prefix)) return true;
    }

    // 4. Dynamic patterns from Admin Panel
    final dynamicPatterns = PatternCacheService.getPatterns();
    for (final p in dynamicPatterns) {
      final pat = p['pattern']?.toString().toLowerCase() ?? '';
      if (pat.isNotEmpty && clean.toLowerCase().contains(pat)) {
        return true;
      }
    }

    // 5. Numeric sender claiming to be known brand (heuristic)
    final numericOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (numericOnly.length > 10) {
      if (BlocklistService.hasBlockedPattern(phoneNumber)) return true;
    }

    return false;
  }

  /// Called when an incoming call is detected from an unknown/suspicious number.
  /// Immediately triggers the red full-screen alert and updates stats.
  static Future<void> onSuspiciousCallDetected(
    String phoneNumber, {
    String? reason,
  }) async {
    final effectiveReason = reason ?? 'Suspected Extortion / Spoofed Number';
    if (kDebugMode) print('[CallService] Suspicious call from $phoneNumber ($effectiveReason)');

    ScamRuleEngine.recordSuspiciousCall();

    // 1. Trigger the red alert screen callback IMMEDIATELY without awaiting
    _onDangerCallCallback?.call(phoneNumber, effectiveReason);

    // 2. Notify stats changed for live Riverpod UI
    _onStatsChangedCallback?.call();

    // 3. Increment counters
    await StatsStore.incrementCallsProtected();
    await StatsStore.incrementBlocked(isCall: true);

    // 4. Trigger system notification tray alert
    NotificationService.showScamAlert(
      sender: phoneNumber,
      reason: effectiveReason,
    ).ignore();

    // 5. Speak voice warning
    VoiceService.speakScamAlert(phoneNumber).ignore();

    // 6. Report to backend (fire-and-forget)
    try {
      await ApiClient.reportScam(
        type: 'call',
        sender: phoneNumber,
        classification: 'suspicious',
      );
    } catch (e) {
      if (kDebugMode) print('[CallService] reportScam failed (offline ok): $e');
    }
  }

  /// Helper to simulate an incoming fake/scam call for instant verification.
  /// Can be called multiple times without any limitation.
  static Future<void> simulateIncomingFakeCall({
    String? phoneNumber,
    String? reason,
  }) async {
    final phone = phoneNumber ?? '+91 11 2309 4712 (CBI Spoofed Call)';
    final r = reason ?? 'Video Call Extortion / Police Impersonation';
    await onSuspiciousCallDetected(phone, reason: r);
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
      } else if (call.method == 'onCallScreened') {
        final data = Map<String, dynamic>.from(call.arguments as Map? ?? {});
        final phone = data['phone'] as String? ?? '';
        final blocked = data['blocked'] as bool? ?? false;
        if (blocked && phone.isNotEmpty) {
          await onSuspiciousCallDetected(phone, reason: 'Call screened & rejected by SafeSenior');
        }
      }
      return false;
    });
  }
}
