// lib/utils/password_hasher.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordHasher {
  /// Hashes a plaintext password with SHA-256 + a per-user salt.
  static String hash(String password, {String salt = 'safe_senior_salt'}) {
    final saltedInput = '$salt:$password';
    final bytes = utf8.encode(saltedInput);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifies a plaintext password against a stored hash.
  static bool verify(String password, String storedHash, {String salt = 'safe_senior_salt'}) {
    return hash(password, salt: salt) == storedHash;
  }
}
