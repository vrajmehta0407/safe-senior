// lib/state/dashboard_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';
import '../models/safety_tip.dart';

/// Provides the tip of the day (rotates daily using day-of-year index).
final tipOfTheDayProvider = Provider<SafetyTip>((ref) {
  final dayIndex = DateTime.now().dayOfYear % AppConstants.safetyTips.length;
  return SafetyTip.fromMap(AppConstants.safetyTips[dayIndex]);
});

/// Provides the full list of safety tips.
final safetyTipsProvider = Provider<List<SafetyTip>>((ref) {
  return AppConstants.safetyTips.map((m) => SafetyTip.fromMap(m)).toList();
});

extension on DateTime {
  int get dayOfYear {
    final startOfYear = DateTime(year, 1, 1);
    return difference(startOfYear).inDays;
  }
}
