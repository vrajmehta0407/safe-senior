// lib/services/guardian_service.dart
// Multi-guardian service — syncs with /guardians CRUD endpoints.
// Local Hive store is the source of truth offline; backend is reconciled on
// fetchFromBackend() which is called whenever the guardian screen opens.

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/guardian_contact.dart';
import '../services/api_client.dart';

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

  // ─── Read ─────────────────────────────────────────────────────────────────

  /// Returns all locally stored guardian contacts.
  static List<GuardianContact> getAllGuardians() {
    return _instance.values.toList();
  }

  /// Returns the primary guardian (isPrimary == true), falling back to first.
  static GuardianContact? getPrimaryGuardian() {
    final list = getAllGuardians();
    if (list.isEmpty) return null;
    final primaryList = list.where((g) => g.isPrimary).toList();
    return primaryList.isNotEmpty ? primaryList.first : list.first;
  }

  // ─── Backend Sync ─────────────────────────────────────────────────────────

  /// Fetches guardians from the backend and reconciles with local Hive store.
  /// Call this on screen open / app resume when the user is authenticated.
  static Future<void> fetchFromBackend() async {
    try {
      final result = await ApiClient.listGuardians();
      if (result == null || result['success'] != true) return;

      final List<dynamic> remoteList = result['guardians'] ?? [];

      // Build a map of phone → local contact for reconciliation
      final localByPhone = <String, GuardianContact>{};
      for (final g in _instance.values) {
        localByPhone[g.phone] = g;
      }

      // Rebuild local store from backend truth
      await _instance.clear();
      for (final remote in remoteList) {
        final phone    = remote['phone_number'] as String;
        final existing = localByPhone[phone];
        final contact  = GuardianContact(
          name:         remote['name'] as String,
          phone:        phone,
          email:        existing?.email,
          addedAt:      existing?.addedAt ?? DateTime.now(),
          isActive:     true,
          serverId:     remote['id'] as int?,
          isPrimary:    remote['is_primary'] as bool? ?? false,
          relationship: remote['relationship'] as String?,
        );
        await _instance.add(contact);
      }
    } catch (e) {
      if (kDebugMode) print('[GuardianService] fetchFromBackend failed (offline ok): $e');
    }
  }

  // ─── Write ────────────────────────────────────────────────────────────────

  /// Adds a guardian contact locally and syncs to the backend.
  static Future<void> addGuardianContact(GuardianContact contact) async {
    await _instance.add(contact);
    await _syncAddToBackend(contact);
  }

  static Future<void> _syncAddToBackend(GuardianContact contact) async {
    try {
      final result = await ApiClient.addGuardianRemote(
        name:         contact.name,
        phoneNumber:  contact.phone,
        relationship: contact.relationship ?? 'family',
        isPrimary:    contact.isPrimary,
      );
      if (result != null && result['success'] == true) {
        final linkId    = result['link']?['id'] as int?;
        final isPrimary = result['link']?['is_primary'] as bool? ?? false;
        if (linkId != null) {
          // Update local record with the server-assigned id
          for (final key in _instance.keys) {
            final g = _instance.get(key);
            if (g != null && g.phone == contact.phone) {
              g.serverId  = linkId;
              g.isPrimary = isPrimary;
              await g.save();
              break;
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print('[GuardianService] _syncAddToBackend failed (offline ok): $e');
    }
  }

  /// Removes the guardian contact at [index] from local store and backend.
  static Future<void> removeGuardianAt(int index) async {
    final list = getAllGuardians();
    if (index < 0 || index >= list.length) return;
    final contact = list[index];

    if (contact.serverId != null) {
      try {
        await ApiClient.deleteGuardianRemote(contact.serverId!);
      } catch (e) {
        if (kDebugMode) print('[GuardianService] deleteGuardianRemote failed (offline ok): $e');
      }
    }

    await _instance.deleteAt(index);
  }

  /// Promotes the contact at [index] to primary, unsets all others.
  static Future<void> setPrimary(int index) async {
    final list = getAllGuardians();
    if (index < 0 || index >= list.length) return;
    final contact = list[index];

    if (contact.serverId != null) {
      try {
        await ApiClient.setPrimaryGuardianRemote(contact.serverId!);
      } catch (e) {
        if (kDebugMode) print('[GuardianService] setPrimaryGuardianRemote failed: $e');
      }
    }

    // Update local Hive — unset all, set the chosen one
    for (int i = 0; i < list.length; i++) {
      final g     = list[i];
      final wasP  = g.isPrimary;
      g.isPrimary = (i == index);
      if (g.isPrimary != wasP) await g.save();
    }
  }

  /// Clears all local guardian contacts (used on logout).
  static Future<void> removeAll() async {
    await _instance.clear();
  }

  // ─── Legacy single-guardian methods (kept for backward compat) ────────────

  /// @deprecated — use addGuardianContact() instead.
  static Future<void> setGuardianContact(GuardianContact contact) async {
    await _instance.clear();
    await _instance.add(contact);
    await _syncAddToBackend(contact);
  }

  /// @deprecated — use removeGuardianAt() instead.
  static Future<void> removeGuardian() async {
    await _instance.clear();
  }

  // ─── Communication ────────────────────────────────────────────────────────

  /// Opens the phone dialer for the primary guardian's number.
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

  /// Opens the SMS composer pre-filled with [message] to the primary guardian.
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

  /// Sends an emergency alert: opens the dialer, falls back to SMS.
  static Future<bool> sendEmergencyAlert({String? message}) async {
    final guardian = getPrimaryGuardian();
    if (guardian == null) return false;
    final alertMsg = message ??
        '🚨 EMERGENCY: ${guardian.name} needs help right now. Please call immediately.';
    final called = await callGuardian();
    if (!called) await messageGuardian(alertMsg);
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
