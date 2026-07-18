// lib/services/guardian_service.dart
// Manages guardian contacts: store, retrieve, and send emergency alerts.
// Real calls/SMS are fired via url_launcher (no new UI).

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/guardian_contact.dart';

class GuardianService {
  static const String _boxName = 'guardian';
  static Box<GuardianContact>? _box;

  static Future<void> init() async {
    _box = await Hive.openBox<GuardianContact>(_boxName);
  }

  static Box<GuardianContact> get _instance {
    if (_box == null || !_box!.isOpen) throw StateError('GuardianService not initialized.');
    return _box!;
  }

  /// Sets the primary guardian contact (single guardian on free tier).
  static Future<void> setGuardianContact(GuardianContact contact) async {
    await _instance.clear();
    await _instance.add(contact);
  }

  /// Gets the primary guardian contact, or null if not set.
  static GuardianContact? getPrimaryGuardian() {
    if (_instance.isEmpty) return null;
    return _instance.values.first;
  }

  /// Removes the guardian contact.
  static Future<void> removeGuardian() async {
    await _instance.clear();
  }

  // ─── Real Communication ───────────────────────────────────────────────────

  /// Opens the phone dialer for the guardian's number.
  static Future<bool> callGuardian() async {
    final guardian = getPrimaryGuardian();
    if (guardian == null) return false;
    final uri = Uri(scheme: 'tel', path: guardian.phone);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('[GuardianService] callGuardian error: $e');
    }
    return false;
  }

  /// Opens the SMS composer pre-filled with the emergency message.
  static Future<bool> messageGuardian(String message) async {
    final guardian = getPrimaryGuardian();
    if (guardian == null) return false;
    final uri = Uri(
      scheme: 'sms',
      path: guardian.phone,
      queryParameters: {'body': message},
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('[GuardianService] messageGuardian error: $e');
    }
    return false;
  }

  /// Sends the emergency alert: opens dialer AND queues SMS.
  /// Returns true if guardian exists, false otherwise.
  static Future<bool> sendEmergencyAlert({String? message}) async {
    final guardian = getPrimaryGuardian();
    if (guardian == null) return false;

    final alertMsg = message ??
        '🚨 EMERGENCY: ${guardian.name} needs help right now. Please call immediately.';

    // Primary: call the guardian
    final called = await callGuardian();

    // If call launcher fails, fall back to SMS
    if (!called) {
      await messageGuardian(alertMsg);
    }
    return true;
  }

  /// Notifies the guardian about a detected scam via SMS.
  static Future<bool> notifyGuardian({required String sender, required String reason}) async {
    final guardian = getPrimaryGuardian();
    if (guardian == null) return false;

    final msg =
        '⚠️ Safe Senior Alert: A suspicious message was detected from "$sender". Reason: $reason. '
        'Please check on your family member.';
    return await messageGuardian(msg);
  }
}
