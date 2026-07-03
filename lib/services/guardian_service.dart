// lib/services/guardian_service.dart
// Manages guardian contacts: store, retrieve, and send emergency alerts.

import 'package:hive_flutter/hive_flutter.dart';
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
    // Clear any existing guardians first (single-guardian free tier)
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

  /// Simulates sending an emergency alert to the guardian.
  /// In a real app this would call/SMS via platform channel.
  /// Returns true if guardian exists, false otherwise.
  static Future<bool> sendEmergencyAlert({String? message}) async {
    final guardian = getPrimaryGuardian();
    if (guardian == null) return false;

    // TODO(backend): On Android, launch phone dialer or send SMS via sms_service.
    // For now, log the alert attempt — the UI already has the warning screen.
    print('[GuardianService] EMERGENCY ALERT sent to ${guardian.name} (${guardian.phone}): ${message ?? "Help needed!"}');
    return true;
  }

  /// Simulates notifying the guardian about a detected scam.
  static Future<bool> notifyGuardian({required String sender, required String reason}) async {
    final guardian = getPrimaryGuardian();
    if (guardian == null) return false;

    print('[GuardianService] Notifying ${guardian.name}: Scam from $sender — $reason');
    return true;
  }
}
