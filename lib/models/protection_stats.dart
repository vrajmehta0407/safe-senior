// lib/models/protection_stats.dart

class ProtectionStats {
  final int totalBlocked;
  final int spamCallsBlocked;
  final int phishingSmsBlocked;
  final int messagesScanned;
  final int callsProtected;

  const ProtectionStats({
    this.totalBlocked = 0,
    this.spamCallsBlocked = 0,
    this.phishingSmsBlocked = 0,
    this.messagesScanned = 0,
    this.callsProtected = 0,
  });

  ProtectionStats copyWith({
    int? totalBlocked,
    int? spamCallsBlocked,
    int? phishingSmsBlocked,
    int? messagesScanned,
    int? callsProtected,
  }) {
    return ProtectionStats(
      totalBlocked: totalBlocked ?? this.totalBlocked,
      spamCallsBlocked: spamCallsBlocked ?? this.spamCallsBlocked,
      phishingSmsBlocked: phishingSmsBlocked ?? this.phishingSmsBlocked,
      messagesScanned: messagesScanned ?? this.messagesScanned,
      callsProtected: callsProtected ?? this.callsProtected,
    );
  }

  ProtectionStats incrementBlocked({bool isCall = false}) {
    return copyWith(
      totalBlocked: totalBlocked + 1,
      spamCallsBlocked: isCall ? spamCallsBlocked + 1 : spamCallsBlocked,
      phishingSmsBlocked: !isCall ? phishingSmsBlocked + 1 : phishingSmsBlocked,
    );
  }

  ProtectionStats incrementScanned() {
    return copyWith(messagesScanned: messagesScanned + 1);
  }

  ProtectionStats incrementCallsProtected() {
    return copyWith(callsProtected: callsProtected + 1);
  }
}
