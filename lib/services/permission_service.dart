// lib/services/permission_service.dart
// Requests runtime permissions post-login. No new UI screens added.

import 'package:permission_handler/permission_handler.dart';
import 'platform_capabilities.dart';

class PermissionService {
  /// Called right after successful login/signup.
  /// Requests all needed permissions silently — no custom UI.
  static Future<void> requestPostLoginPermissions() async {
    if (!PlatformCapabilities.canMonitorSms) return;

    // Android-only: SMS + Phone state + Notifications
    final permissions = [
      Permission.sms,
      Permission.phone,
      Permission.notification,
    ];

    for (final permission in permissions) {
      final status = await permission.status;
      if (status.isDenied) {
        await permission.request();
      }
    }
  }

  /// Requests contacts permission (Android + iOS).
  static Future<bool> requestContactsPermission() async {
    if (!PlatformCapabilities.canAccessContacts) return false;
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  /// Checks if SMS permission is granted (Android only).
  static Future<bool> hasSmsPermission() async {
    if (!PlatformCapabilities.canMonitorSms) return false;
    return await Permission.sms.isGranted;
  }

  /// Checks if notification permission is granted.
  static Future<bool> hasNotificationPermission() async {
    return await Permission.notification.isGranted;
  }
}
