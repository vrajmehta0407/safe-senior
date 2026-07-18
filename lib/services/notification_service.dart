// lib/services/notification_service.dart
// flutter_local_notifications wrapper for scam/safety alerts.

import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'platform_capabilities.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (!PlatformCapabilities.canSendNotifications) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  static Future<void> showScamAlert({
    required String sender,
    required String reason,
  }) async {
    if (!PlatformCapabilities.canSendNotifications) return;
    if (!_initialized) await init();

    const androidDetails = AndroidNotificationDetails(
      'scam_alerts',
      'Scam Alerts',
      channelDescription: 'Alerts for detected scam messages and calls',
      importance: Importance.max,
      priority: Priority.high,
      color: Color.fromARGB(255, 201, 39, 39),
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      1,
      '⚠️ Scam Detected from $sender',
      reason,
      details,
    );
  }

  static Future<void> showSafetyTip(String tip) async {
    if (!PlatformCapabilities.canSendNotifications) return;
    if (!_initialized) await init();

    const androidDetails = AndroidNotificationDetails(
      'safety_tips',
      'Safety Tips',
      channelDescription: 'Daily security tips',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(2, '💡 Safety Tip', tip, details);
  }
}
