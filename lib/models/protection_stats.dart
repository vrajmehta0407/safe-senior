// lib/models/protection_stats.dart

class ProtectionStats {
  final int totalBlocked;
  final int spamCallsBlocked;
  final int phishingSmsBlocked;
  final int messagesScanned;
  final int callsProtected;
  final int scannedThisWeek;
  final int blockedThisWeek;
  final String? weekStartDate; // ISO date string of week start

  const ProtectionStats({
    this.totalBlocked = 0,
    this.spamCallsBlocked = 0,
    this.phishingSmsBlocked = 0,
    this.messagesScanned = 0,
    this.callsProtected = 0,
    this.scannedThisWeek = 0,
    this.blockedThisWeek = 0,
    this.weekStartDate,
  });

  ProtectionStats copyWith({
    int? totalBlocked,
    int? spamCallsBlocked,
    int? phishingSmsBlocked,
    int? messagesScanned,
    int? callsProtected,
    int? scannedThisWeek,
    int? blockedThisWeek,
    String? weekStartDate,
  }) {
    return ProtectionStats(
      totalBlocked:      totalBlocked      ?? this.totalBlocked,
      spamCallsBlocked:  spamCallsBlocked  ?? this.spamCallsBlocked,
      phishingSmsBlocked: phishingSmsBlocked ?? this.phishingSmsBlocked,
      messagesScanned:   messagesScanned   ?? this.messagesScanned,
      callsProtected:    callsProtected    ?? this.callsProtected,
      scannedThisWeek:   scannedThisWeek   ?? this.scannedThisWeek,
      blockedThisWeek:   blockedThisWeek   ?? this.blockedThisWeek,
      weekStartDate:     weekStartDate     ?? this.weekStartDate,
    );
  }

  ProtectionStats incrementBlocked({bool isCall = false}) {
    // Auto-reset weekly stats when the week changes
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekKey = '${startOfWeek.year}-${startOfWeek.month}-${startOfWeek.day}';
    final isNewWeek = weekStartDate != weekKey;
    return copyWith(
      totalBlocked:      totalBlocked + 1,
      spamCallsBlocked:  isCall ? spamCallsBlocked + 1 : spamCallsBlocked,
      phishingSmsBlocked: !isCall ? phishingSmsBlocked + 1 : phishingSmsBlocked,
      blockedThisWeek:   (isNewWeek ? 0 : blockedThisWeek) + 1,
      scannedThisWeek:   isNewWeek ? scannedThisWeek : scannedThisWeek,
      weekStartDate:     weekKey,
    );
  }

  ProtectionStats incrementScanned() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekKey = '${startOfWeek.year}-${startOfWeek.month}-${startOfWeek.day}';
    final isNewWeek = weekStartDate != weekKey;
    return copyWith(
      messagesScanned: messagesScanned + 1,
      scannedThisWeek: (isNewWeek ? 0 : scannedThisWeek) + 1,
      weekStartDate:   weekKey,
    );
  }

  ProtectionStats incrementCallsProtected() {
    return copyWith(callsProtected: callsProtected + 1);
  }
}
