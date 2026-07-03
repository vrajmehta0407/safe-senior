// lib/models/user_profile.g.dart
// HAND-WRITTEN Hive TypeAdapter (replaces build_runner output)

part of 'user_profile.dart';

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 0;

  @override
  UserProfile read(BinaryReader reader) {
    final fields = reader.readMap();
    return UserProfile(
      name: fields[0] as String,
      email: fields[1] as String,
      phone: fields[2] as String,
      passwordHash: fields[3] as String,
      createdAt: DateTime.parse(fields[4] as String),
      isPremium: fields[5] as bool? ?? false,
      trialStartDate: fields[6] != null ? DateTime.parse(fields[6] as String) : null,
      selectedPlanId: fields[7] as String?,
      premiumActivatedAt: fields[8] != null ? DateTime.parse(fields[8] as String) : null,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer.writeMap({
      0: obj.name,
      1: obj.email,
      2: obj.phone,
      3: obj.passwordHash,
      4: obj.createdAt.toIso8601String(),
      5: obj.isPremium,
      6: obj.trialStartDate?.toIso8601String(),
      7: obj.selectedPlanId,
      8: obj.premiumActivatedAt?.toIso8601String(),
    });
  }
}
