// lib/services/alert_manager.dart
// Central manager for full-screen emergency red alerts (Fake OTP, Fake Calls, Scam SMS).
// Ensures alerts appear every single time without throttling, stacking jams, or dismissal limits.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart' show navigatorKey;
import '../screens/otp_alert_screen.dart';
import '../screens/warning_alert_screen.dart';

class AlertManager {
  static bool _isAlertShowing = false;
  static int _alertCount = 0;

  /// Returns true if an emergency alert is currently on top of the screen.
  static bool get isAlertShowing => _isAlertShowing;

  /// Total number of emergency alerts triggered in this session.
  static int get alertCount => _alertCount;

  /// Displays the full-screen Red OTP Alert Screen.
  /// Works reliably for any number of times (no 2-3 limit).
  static void showOtpAlert({
    required String sender,
    required String message,
    String? code,
  }) {
    _triggerAlert((nav) {
      return PageRouteBuilder(
        settings: const RouteSettings(name: '/otp_alert'),
        pageBuilder: (context, _, _) => OtpAlertScreen(
          message: message,
          code: code,
          sender: sender,
          onDismiss: _onAlertDismissed,
        ),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 180),
      );
    });
  }

  /// Displays the full-screen Red Fake Call Alert Screen.
  /// Works reliably for any number of incoming scam/spoofed calls.
  static void showCallAlert({
    required String phoneNumber,
    String? reason,
  }) {
    _triggerAlert((nav) {
      return PageRouteBuilder(
        settings: const RouteSettings(name: '/call_alert'),
        pageBuilder: (context, _, _) => WarningAlertScreen(
          sender: phoneNumber,
          messageBody: reason ??
              'Incoming call flagged as high-risk impersonation / extortion attempt. SafeSenior intercepted and disconnected this call.',
          isCall: true,
          threatType: 'Spoofed / Extortion Call Threat',
          onDismiss: _onAlertDismissed,
        ),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 180),
      );
    });
  }

  /// Displays the full-screen Red Warning Alert Screen for scam messages.
  static void showScamMessageAlert({
    required String sender,
    required String message,
    List<String>? reasons,
  }) {
    _triggerAlert((nav) {
      final reasonText = (reasons != null && reasons.isNotEmpty)
          ? reasons.first
          : 'High risk message flagged by SafeSenior AI.';
      return PageRouteBuilder(
        settings: const RouteSettings(name: '/scam_message_alert'),
        pageBuilder: (context, _, _) => WarningAlertScreen(
          sender: sender,
          messageBody: message,
          isCall: false,
          threatType: reasonText,
          onDismiss: _onAlertDismissed,
        ),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 180),
      );
    });
  }

  /// Shared helper to push the alert route cleanly.
  static void _triggerAlert(Route Function(NavigatorState nav) routeBuilder) {
    _alertCount++;

    // Emergency haptic pulse
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}

    // Run on microtask / next frame to ensure navigator state is stable
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = navigatorKey.currentState;
      if (nav == null) return;

      // If an alert is already visible, pop the older one first so we don't
      // build an infinite stack of routes that traps the user.
      if (_isAlertShowing) {
        try {
          nav.pop();
        } catch (_) {}
      }

      _isAlertShowing = true;
      final route = routeBuilder(nav);

      nav.push(route).then((_) {
        _isAlertShowing = false;
      }).catchError((_) {
        _isAlertShowing = false;
      });
    });
  }

  static void _onAlertDismissed() {
    _isAlertShowing = false;
  }
}
