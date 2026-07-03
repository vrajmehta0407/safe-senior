// lib/state/premium_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/premium_service.dart';

class PremiumNotifier extends StateNotifier<PremiumStatus> {
  PremiumNotifier() : super(PremiumService.getStatus());

  Future<void> activatePremium(String planId) async {
    await PremiumService.activatePremium(planId);
    state = PremiumStatus.premium;
  }

  void refresh() {
    state = PremiumService.getStatus();
  }

  int get trialDaysRemaining => PremiumService.trialDaysRemaining();
}

final premiumProvider = StateNotifierProvider<PremiumNotifier, PremiumStatus>(
  (ref) => PremiumNotifier(),
);
