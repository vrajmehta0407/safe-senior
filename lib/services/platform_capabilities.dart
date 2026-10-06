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
      final types     = await _auth.getAvailableBiometrics();
      _biometricAvailable = canCheck || supported || types.isNotEmpty;

      if (kDebugMode) {
        print('[PlatformCapabilities] Biometric: canCheck=$canCheck, supported=$supported, types=$types');
      }
    } catch (e) {
      _biometricAvailable = true;
      if (kDebugMode) print('[PlatformCapabilities] Biometric check error (assuming supported): $e');
    }
  }

  /// Prompts the user for biometric authentication.
  /// Returns true if the user authenticated successfully.
  static Future<bool> authenticateWithBiometrics({
    String localizedReason = 'Confirm your identity to log in',
  }) async {
    if (kIsWeb) return false;
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      if (!canCheck && !isSupported && !_biometricAvailable) {
        return false;
      }
      try {
        return await _auth.authenticate(
          localizedReason: localizedReason,
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: false,
            useErrorDialogs: true,
          ),
        );
      } catch (innerError) {
        if (kDebugMode) print('[PlatformCapabilities] Retrying with biometricOnly: true -> $innerError');
        return await _auth.authenticate(
          localizedReason: localizedReason,
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
            useErrorDialogs: true,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) print('[PlatformCapabilities] Biometric auth error: $e');
      return false;
    }
  }
}
