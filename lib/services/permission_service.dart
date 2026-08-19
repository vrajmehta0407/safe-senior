// lib/services/permission_service.dart
// Requests runtime permissions post-login. No new UI screens added.

import 'package:permission_handler/permission_handler.dart';
import 'platform_capabilities.dart';

class PermissionService {
  /// Called right after successful login/signup.
  /// Requests SMS, Phone, and Notification permissions on Android.
  static Future<void> requestPostLoginPermissions() async {
    if (!PlatformCapabilities.canMonitorSms) return;

    // Request all three SMS permissions explicitly — Permission.sms only covers
    // READ_SMS on some Android versions. We also need RECEIVE_SMS separately.
    final smsPermissions = [
      Permission.sms,           // READ_SMS + SEND_SMS
      Permission.phone,         // READ_PHONE_STATE + CALL_PHONE
      Permission.notification,  // POST_NOTIFICATIONS (Android 13+)
    ];

    for (final permission in smsPermissions) {
      final status = await permission.status;
      if (status.isDenied) {
        await permission.request();
      } else if (status.isPermanentlyDenied) {
        // User has tapped "Never ask again" — must open app settings
        await openAppSettings();
        return; // Stop requesting further; user is in Settings now
      }
    }
  }

  /// Requests contacts permission (Android + iOS).
  static Future<bool> requestContactsPermission() async {
    if (!PlatformCapabilities.canAccessContacts) return false;
    final status = await Permission.contacts.request();
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return status.isGranted;
  }

  /// Checks if SMS reading permission is granted (Android only).
  static Future<bool> hasSmsPermission() async {
    if (!PlatformCapabilities.canMonitorSms) return false;
    return await Permission.sms.isGranted;
  }

  /// Checks if notification permission is granted.
  static Future<bool> hasNotificationPermission() async {
    return await Permission.notification.isGranted;
  }

  /// Returns true if the user has permanently denied SMS permission,
  /// meaning we must send them to app settings to re-enable it.
  static Future<bool> isSmsPermissionPermanentlyDenied() async {
    if (!PlatformCapabilities.canMonitorSms) return false;
    return await Permission.sms.isPermanentlyDenied;
  }
}
