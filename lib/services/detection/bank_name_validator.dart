// lib/services/detection/bank_name_validator.dart
// Detects fake/lookalike bank sender IDs by checking for suspicious patterns
// alongside bank-related keywords.

class BankNameValidator {
  /// Known legitimate bank sender ID prefixes (partial list for India/US).
  static const List<String> _legitimateBankIds = [
    'SBIINB', 'HDFCBK', 'ICICIBK', 'AXISBK', 'KOTAKB',
    'PNBSMS', 'CANBNK', 'BOIIND', 'UNIONB', 'IDBIBK',
    'BOFSMS', 'CHSSMS', 'WELLSF', 'CHASEC',
  ];

  /// Suspicious patterns that suggest a fake bank sender.
  static const List<String> _suspiciousBankPatterns = [
    'security-alert', 'guardian-trust', 'bank-alert', 'secure-bank',
    'yourbank', 'mybank', 'bankupdate', 'bankverify',
  ];

  /// Returns true if the sender ID looks like a fake bank impersonation.
  static bool isFakeBankSender(String sender) {
    final lowerSender = sender.toLowerCase();

    // If it matches a known legitimate bank ID, it's real.
    if (_legitimateBankIds.any((id) => sender.toUpperCase() == id)) return false;

    // Check for suspicious lookalike patterns.
    if (_suspiciousBankPatterns.any((pattern) => lowerSender.contains(pattern))) {
      return true;
    }

    // Heuristic: sender has 'bank' in name + also has digits (non-standard ID)
    final hasBankKeyword = lowerSender.contains('bank') ||
        lowerSender.contains('bnk') ||
        lowerSender.contains('bk');
    final hasDigits = RegExp(r'\d').hasMatch(sender);
    final hasSpecialChars = RegExp(r'[-_.]').hasMatch(sender);

    return hasBankKeyword && (hasDigits || hasSpecialChars);
  }
}
