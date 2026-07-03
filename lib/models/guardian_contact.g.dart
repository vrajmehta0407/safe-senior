// lib/models/guardian_contact.g.dart
// HAND-WRITTEN Hive TypeAdapter

part of 'guardian_contact.dart';

class GuardianContactAdapter extends TypeAdapter<GuardianContact> {
  @override
  final int typeId = 1;

  @override
  GuardianContact read(BinaryReader reader) {
    final fields = reader.readMap();
    return GuardianContact(
      name: fields[0] as String,
      phone: fields[1] as String,
      email: fields[2] as String?,
      addedAt: DateTime.parse(fields[3] as String),
      isActive: fields[4] as bool? ?? true,
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
    });
  }
}
