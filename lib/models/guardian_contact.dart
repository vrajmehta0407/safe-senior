// lib/models/guardian_contact.dart
import 'package:hive/hive.dart';

part 'guardian_contact.g.dart';

@HiveType(typeId: 1)
class GuardianContact extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String phone;

  @HiveField(2)
  final String? email;

  @HiveField(3)
  final DateTime addedAt;

  @HiveField(4)
  bool isActive;

  /// The `user_guardians.id` returned by the backend after adding a guardian.
  /// Null until the contact has been synced to the server.
  @HiveField(5)
  int? serverId;

  /// Whether this contact is the primary guardian (mirrors backend is_primary).
  @HiveField(6)
  bool isPrimary;

  /// Optional relationship label (e.g. 'family', 'medical', 'friend').
  @HiveField(7)
  String? relationship;

  GuardianContact({
    required this.name,
    required this.phone,
    this.email,
    required this.addedAt,
    this.isActive = true,
    this.serverId,
    this.isPrimary = false,
    this.relationship,
  });
}
