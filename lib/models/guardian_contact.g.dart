// lib/models/guardian_contact.g.dart
// HAND-WRITTEN Hive TypeAdapter — update manually when adding HiveFields.
// Fields 5, 6, 7 added for serverId, isPrimary, relationship (multi-guardian sync).

part of 'guardian_contact.dart';

class GuardianContactAdapter extends TypeAdapter<GuardianContact> {
  @override
  final int typeId = 1;

  @override
  GuardianContact read(BinaryReader reader) {
    final fields = reader.readMap();
    return GuardianContact(
      name:         fields[0] as String,
      phone:        fields[1] as String,
      email:        fields[2] as String?,
      addedAt:      DateTime.parse(fields[3] as String),
      isActive:     fields[4] as bool? ?? true,
      serverId:     fields[5] as int?,
      isPrimary:    fields[6] as bool? ?? false,
      relationship: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, GuardianContact obj) {
    writer.writeMap({
      0: obj.name,
      1: obj.phone,
      2: obj.email,
      3: obj.addedAt.toIso8601String(),
      4: obj.isActive,
      5: obj.serverId,
      6: obj.isPrimary,
      7: obj.relationship,
    });
  }
}
