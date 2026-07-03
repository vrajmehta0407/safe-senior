// lib/models/scanned_message.dart
import 'package:hive/hive.dart';

part 'scanned_message.g.dart';

enum RiskLevel { safe, caution, danger }

@HiveType(typeId: 2)
class ScannedMessage extends HiveObject {
  @HiveField(0)
  final String sender;

  @HiveField(1)
  final String body;

  @HiveField(2)
  final String maskedBody; // body with codes replaced by ****

  @HiveField(3)
  final int riskLevelIndex; // 0=safe, 1=caution, 2=danger

  @HiveField(4)
  final List<String> reasons;

  @HiveField(5)
  final List<String> matchedKeywords;

  @HiveField(6)
  final String? extractedCode; // raw numeric code found (before masking)

  @HiveField(7)
  final DateTime receivedAt;

  @HiveField(8)
  bool isUserConfirmedScam;

  @HiveField(9)
  bool isAcknowledged;

  @HiveField(10)
  bool isBlocked;

  ScannedMessage({
    required this.sender,
    required this.body,
    required this.maskedBody,
    required this.riskLevelIndex,
    required this.reasons,
    required this.matchedKeywords,
    this.extractedCode,
    required this.receivedAt,
    this.isUserConfirmedScam = false,
    this.isAcknowledged = false,
    this.isBlocked = false,
  });

  RiskLevel get riskLevel => RiskLevel.values[riskLevelIndex];

  String get riskLevelLabel {
    switch (riskLevel) {
      case RiskLevel.safe:
        return 'Safe';
      case RiskLevel.caution:
        return 'Caution';
      case RiskLevel.danger:
        return 'Danger';
    }
  }
}
