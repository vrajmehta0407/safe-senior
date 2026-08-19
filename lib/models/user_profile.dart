// lib/models/user_profile.dart
import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String phone;

  @HiveField(3)
  String passwordHash;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  bool isPremium;

  @HiveField(6)
  DateTime? trialStartDate;

  @HiveField(7)
  String? selectedPlanId;

  @HiveField(8)
  DateTime? premiumActivatedAt;

  @HiveField(9)
  String? avatarPath; // local file path to profile photo

  UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.passwordHash,
    required this.createdAt,
    this.isPremium = true,
    this.trialStartDate,
    this.selectedPlanId,
    this.premiumActivatedAt,
    this.avatarPath,
  });

  bool get isInTrial => false;

  bool get hasAnyPremiumAccess => true;
}
