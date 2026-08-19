// lib/storage/user_store.dart
// Hive-backed store for registered users.

import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';
import '../utils/constants.dart';

class UserStore {
  static Box<UserProfile>? _box;

  static Future<void> init() async {
    _box = await Hive.openBox<UserProfile>(AppConstants.userBoxName);
  }

  static Box<UserProfile> get _instance {
    if (_box == null || !_box!.isOpen) throw StateError('UserStore not initialized.');
    return _box!;
  }

  /// Save or update user by email key.
  static Future<void> saveUser(UserProfile user) async {
    await _instance.put(user.email, user);
  }

  /// Retrieve user by email, or null if not found.
  static UserProfile? getUserByEmail(String email) {
    return _instance.get(email);
  }

  /// Check if email is already registered.
  static bool emailExists(String email) {
    return _instance.containsKey(email);
  }

  /// Retrieve user by phone number (flexible matching with/without country code).
  static UserProfile? getUserByPhone(String phone) {
    final cleanInput = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanInput.isEmpty) return null;
    final last10 = cleanInput.length >= 10 ? cleanInput.substring(cleanInput.length - 10) : cleanInput;

    for (final user in _instance.values) {
      final cleanUser = user.phone.replaceAll(RegExp(r'\D'), '');
      if (cleanUser == cleanInput) return user;
      if (cleanUser.length >= 10 && cleanUser.endsWith(last10)) return user;
    }
    return null;
  }

  /// Get all users (for admin/debug purposes).
  static List<UserProfile> getAllUsers() => _instance.values.toList();

  /// Delete user account.
  static Future<void> deleteUser(String email) async {
    await _instance.delete(email);
  }

  /// Update only the avatar path for a user.
  static Future<void> updateAvatarPath(String email, String path) async {
    final user = _instance.get(email);
    if (user != null) {
      user.avatarPath = path;
      await _instance.put(email, user);
    }
  }
}
