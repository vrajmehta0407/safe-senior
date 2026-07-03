// lib/services/sms_service.dart
// Android SMS listener — iOS/web/desktop graceful no-op.
// Uses a periodic polling simulation since telephony plugin requires native setup.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'platform_capabilities.dart';
import '../services/detection/scam_rule_engine.dart';
import '../models/scanned_message.dart';
import '../storage/message_store.dart';
import '../storage/stats_store.dart';
import 'notification_service.dart';
import 'voice_service.dart';
import 'guardian_service.dart';

/// Callback invoked when a dangerous message is detected.
typedef OnDangerMessage = void Function(ScannedMessage message);

class SmsService {
  static OnDangerMessage? _onDangerCallback;
  static bool _monitoring = false;

  /// Registers a callback for danger-level SMS detections.
  static void setDangerCallback(OnDangerMessage callback) {
    _onDangerCallback = callback;
  }

  /// Starts listening for SMS messages.
  /// On Android this would use the telephony plugin.
  /// On other platforms this is a no-op.
  static Future<void> startMonitoring() async {
    if (!PlatformCapabilities.canMonitorSms) {
      if (kDebugMode) print('[SmsService] SMS monitoring not available on this platform.');
      return;
    }
    if (_monitoring) return;
    _monitoring = true;

    // TODO(backend): Replace with telephony plugin listener when available on device.
    // telephony.listenIncomingSms(onNewMessage: _processMessage, listenInBackground: false);
    if (kDebugMode) print('[SmsService] SMS monitoring started (Android).');
  }

  /// Stops monitoring.
  static void stopMonitoring() {
    _monitoring = false;
  }

  /// Manually processes a message (used for testing or manual inject).
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

    if (result.riskLevel == RiskLevel.danger) {
      await StatsStore.incrementBlocked(isCall: false);

      // Notify guardian and show system notification
      await GuardianService.notifyGuardian(
        sender: sender,
        reason: result.reasons.isNotEmpty ? result.reasons.first : 'Scam detected',
      );
      await NotificationService.showScamAlert(
        sender: sender,
        reason: result.reasons.isNotEmpty ? result.reasons.first : 'Suspicious message detected.',
      );
      await VoiceService.speakScamAlert(sender);

      // Trigger UI callback (navigates to warning screen)
      _onDangerCallback?.call(message);
    }

    return message;
  }
}
