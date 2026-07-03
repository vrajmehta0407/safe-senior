// lib/services/platform_capabilities.dart
// Single source of truth for what platform features are available.

import 'dart:io';
import 'package:flutter/foundation.dart';

class PlatformCapabilities {
  /// SMS and call monitoring only available on Android.
  static bool get canMonitorSms => !kIsWeb && Platform.isAndroid;

  /// Notifications available on Android and iOS.
  static bool get canSendNotifications => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Contacts access available on Android and iOS.
  static bool get canAccessContacts => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// TTS available on Android and iOS.
  static bool get hasTts => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Biometric auth — TODO(backend): requires local_auth package not in scope.
  static bool get hasBiometricAuth => false;
}
