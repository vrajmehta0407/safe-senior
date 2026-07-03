// lib/services/call_service.dart
// Android call-state listener — iOS/web/desktop graceful no-op.

import 'package:flutter/foundation.dart';
import 'platform_capabilities.dart';
import '../services/detection/scam_rule_engine.dart';
import '../storage/stats_store.dart';

class CallService {
  static bool _monitoring = false;

  static Future<void> startMonitoring() async {
    if (!PlatformCapabilities.canMonitorSms) {
      if (kDebugMode) print('[CallService] Call monitoring not available on this platform.');
      return;
    }
    if (_monitoring) return;
    _monitoring = true;
    // TODO(backend): Wire to telephony plugin call state listener on Android.
    // telephony.listenIncomingSms(...) or PhoneState plugin for call detection.
    if (kDebugMode) print('[CallService] Call monitoring started (Android).');
  }

  static void stopMonitoring() {
    _monitoring = false;
  }

  /// Called when an incoming call is detected from an unknown/suspicious number.
  static Future<void> onSuspiciousCallDetected(String phoneNumber) async {
    if (kDebugMode) print('[CallService] Suspicious call from $phoneNumber');
    // Arm the OTP+call scam detection for next 5 minutes
    ScamRuleEngine.recordSuspiciousCall();
    await StatsStore.incrementCallsProtected();
    await StatsStore.incrementBlocked(isCall: true);
  }
}
