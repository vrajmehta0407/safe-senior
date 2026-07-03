// lib/models/scanned_message.g.dart
// HAND-WRITTEN Hive TypeAdapter

part of 'scanned_message.dart';

class ScannedMessageAdapter extends TypeAdapter<ScannedMessage> {
  @override
  final int typeId = 2;

  @override
  ScannedMessage read(BinaryReader reader) {
    final fields = reader.readMap();
    return ScannedMessage(
      sender: fields[0] as String,
      body: fields[1] as String,
      maskedBody: fields[2] as String,
      riskLevelIndex: fields[3] as int,
      reasons: List<String>.from(fields[4] as List),
      matchedKeywords: List<String>.from(fields[5] as List),
      extractedCode: fields[6] as String?,
      receivedAt: DateTime.parse(fields[7] as String),
      isUserConfirmedScam: fields[8] as bool? ?? false,
      isAcknowledged: fields[9] as bool? ?? false,
      isBlocked: fields[10] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, ScannedMessage obj) {
    writer.writeMap({
      0: obj.sender,
      1: obj.body,
      2: obj.maskedBody,
      3: obj.riskLevelIndex,
      4: obj.reasons,
      5: obj.matchedKeywords,
      6: obj.extractedCode,
      7: obj.receivedAt.toIso8601String(),
      8: obj.isUserConfirmedScam,
      9: obj.isAcknowledged,
      10: obj.isBlocked,
    });
  }
}
