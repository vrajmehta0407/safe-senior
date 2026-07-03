// lib/models/safety_tip.dart

class SafetyTip {
  final String title;
  final String body;
  final String iconKey;

  const SafetyTip({
    required this.title,
    required this.body,
    required this.iconKey,
  });

  factory SafetyTip.fromMap(Map<String, String> map) {
    return SafetyTip(
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      iconKey: map['icon'] ?? 'shield',
    );
  }
}
