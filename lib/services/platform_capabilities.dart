// lib/services/platform_capabilities.dart
// Single source of truth for what platform features are available.
// BUG 7 FIX: hasBiometricAuth now uses real local_auth detection (was hardcoded false).

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class PlatformCapabilities {
  static final LocalAuthentication _auth = LocalAuthentication();
  static bool _biometricAvailable = false;

  /// SMS and call monitoring only available on Android.
  static bool get canMonitorSms => !kIsWeb && Platform.isAndroid;

  /// Notifications available on Android and iOS.
  static bool get canSendNotifications =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Contacts access available on Android and iOS.
  static bool get canAccessContacts =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// TTS available on Android and iOS.
  static bool get hasTts => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// BUG 7 FIX: Real biometric capability — call checkBiometricAvailability()
  /// at startup (main.dart) before reading this getter.
  static bool get hasBiometricAuth => _biometricAvailable;

  /// Probes the device for biometric capability.
  /// Must be called once during app startup (await in main()).
  static Future<void> checkBiometricAvailability() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      _biometricAvailable = false;
      return;
    }
    try {
      final canCheck  = await _auth.canCheckBiometrics;
      final supported = await _auth.isDeviceSupported();
      // Some Android devices report canCheckBiometrics=false even when enrolled.
      // We consider biometric available if the device supports it at all.
      _biometricAvailable = supported;

      if (kDebugMode) {
        final types = await _auth.getAvailableBiometrics();
        print('[PlatformCapabilities] Biometric: canCheck=$canCheck, supported=$supported, types=$types');
      }
    } catch (e) {
      // Even on error, mark as potentially available so user can attempt login
      _biometricAvailable = true;
      if (kDebugMode) print('[PlatformCapabilities] Biometric check error (assuming supported): $e');
    }
  }

  /// Prompts the user for biometric authentication.
  /// Returns true if the user authenticated successfully.
  static Future<bool> authenticateWithBiometrics({
    String localizedReason = 'Confirm your identity to log in',
  }) async {
    if (!_biometricAvailable) return false;
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // allow PIN fallback if biometric fails
        ),
      );
    } catch (e) {
      if (kDebugMode) print('[PlatformCapabilities] Biometric auth error: $e');
      return false;
    }
  }
}
