import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:telephony/telephony.dart';
import 'platform_capabilities.dart';
import '../services/detection/scam_rule_engine.dart';
import '../models/scanned_message.dart';
import '../storage/message_store.dart';
import '../storage/stats_store.dart';
import 'api_client.dart';
import 'notification_service.dart';
import 'voice_service.dart';
import 'guardian_service.dart';

/// Callback invoked when a dangerous message is detected.
typedef OnDangerMessage = void Function(ScannedMessage message);
/// Callback to refresh stats in Riverpod after a block.
typedef OnStatsChanged = void Function();

// Top-level handler required by telephony for background processing
@pragma('vm:entry-point')
void onBackgroundMessage(SmsMessage message) {
  // Background processing — no UI callbacks available here
  if (kDebugMode) print('[SmsService] Background SMS from ${message.address}');
}

class SmsService {
  static OnDangerMessage? _onDangerCallback;
  static OnStatsChanged?  _onStatsChangedCallback;
  static bool _monitoring = false;
  static final Telephony _telephony = Telephony.instance;

  /// Registers a callback for danger-level SMS detections.
  static void setDangerCallback(OnDangerMessage callback) {
    _onDangerCallback = callback;
  }

  /// Registers a callback invoked after stats change (blocked/scanned).
  /// Use this to trigger Riverpod provider refresh.
  static void setStatsChangedCallback(OnStatsChanged callback) {
    _onStatsChangedCallback = callback;
  }

  /// Starts listening for incoming SMS messages (foreground + background).
  static Future<void> startMonitoring() async {
    if (!PlatformCapabilities.canMonitorSms) {
      if (kDebugMode) print('[SmsService] SMS monitoring not available on this platform.');
      return;
    }
    if (_monitoring) return;
    _monitoring = true;

    _telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) async {
        final sender = message.address ?? 'Unknown';
        final body = message.body ?? '';
        if (kDebugMode) print('[SmsService] Incoming SMS from $sender: $body');
        await processMessage(sender: sender, body: body);
      },
      onBackgroundMessage: onBackgroundMessage,
      listenInBackground: true,
    );

    if (kDebugMode) print('[SmsService] SMS monitoring started (real telephony).');
  }

  /// Stops monitoring.
  static void stopMonitoring() {
    _monitoring = false;
  }

  /// Processes a message through the scam engine. Used both by listener and manual testing.
  static Future<ScannedMessage> processMessage({
    required String sender,
    required String body,
  }) async {
    final result = ScamRuleEngine.analyze(sender, body);

    final message = ScannedMessage(
      sender: sender,
      body: body,
      maskedBody: result.maskedBody,
      riskLevelIndex: result.riskLevel.index,
      reasons: result.reasons,
      matchedKeywords: result.matchedKeywords,
      extractedCode: result.extractedCode,
      receivedAt: DateTime.now(),
      isBlocked: result.riskLevel == RiskLevel.danger,
    );

    await MessageStore.addMessage(message);
    await StatsStore.incrementScanned();

    // RiskLevel enum = {safe, caution, danger} — 'caution' is the mid-tier (no 'suspicious')
    if (result.riskLevel == RiskLevel.danger || result.riskLevel == RiskLevel.caution) {
      // BUG 5 FIX: report to backend so community patterns grow (fire-and-forget)
      final classification = result.riskLevel == RiskLevel.danger ? 'high-risk' : 'suspicious';
      _reportToBackend(sender: sender, body: body, classification: classification);
    }

    if (result.riskLevel == RiskLevel.danger) {
      await StatsStore.incrementBlocked(isCall: false);

      await GuardianService.notifyGuardian(
        sender: sender,
        reason: result.reasons.isNotEmpty ? result.reasons.first : 'Scam detected',
      );

      // Show scam alert notification
      await NotificationService.showScamAlert(
        sender: sender,
        reason: result.reasons.isNotEmpty ? result.reasons.first : 'Suspicious message detected.',
      );

      // Show separate "message blocked" notification so user knows action was taken
      await NotificationService.showMessageBlocked(
        sender: sender,
        messagePreview: result.maskedBody.length > 80 ? result.maskedBody.substring(0, 80) : result.maskedBody,
      );

      await VoiceService.speakScamAlert(sender);

      // Notify Riverpod stats provider to refresh live UI
      _onStatsChangedCallback?.call();

      // Fire UI callback — pushes red OtpAlertScreen via navigatorKey
      // This fires every time a danger message arrives (no deduplication guard)
      _onDangerCallback?.call(message);
    }

    return message;
  }

  static void _reportToBackend({
    required String sender,
    required String body,
    required String classification,
  }) async {
    try {
      await ApiClient.reportScam(
        type: 'sms',
        sender: sender,
        classification: classification,
        bodyPreview: body.length > 200 ? body.substring(0, 200) : body,
      );
    } catch (e) {
      if (kDebugMode) print('[SmsService] reportScam failed (offline ok): $e');
    }
  }
}
