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

  GuardianContact({
    required this.name,
    required this.phone,
    this.email,
    required this.addedAt,
    this.isActive = true,
  });
}
