// lib/services/premium_service.dart
// Trial/subscription state and feature gating — all local, simulated payments.

import '../storage/local_preferences.dart';
import '../storage/user_store.dart';

enum PremiumStatus { free, trial, premium }

class PremiumService {
  /// Returns the current premium status for the logged-in user.
  static PremiumStatus getStatus() {
    final email = LocalPreferences.getCurrentUserEmail();
    if (email == null) return PremiumStatus.free;

    if (LocalPreferences.getPremiumStatus()) return PremiumStatus.premium;

    final trialStart = LocalPreferences.getTrialStartDate();
    if (trialStart != null) {
      final trialEnd = trialStart.add(const Duration(days: 7));
      if (DateTime.now().isBefore(trialEnd)) return PremiumStatus.trial;
    }

    return PremiumStatus.free;
  }

  static bool get isPremium => getStatus() == PremiumStatus.premium;
  static bool get isInTrial => getStatus() == PremiumStatus.trial;
  static bool get hasAnyPremiumAccess =>
      getStatus() == PremiumStatus.premium || getStatus() == PremiumStatus.trial;

  /// Simulates activating premium (local only — no real payment).
  static Future<void> activatePremium(String planId) async {
    await LocalPreferences.setPremiumStatus(true);
    await LocalPreferences.setSelectedPlanId(planId);

    // Also update the stored user profile
    final email = LocalPreferences.getCurrentUserEmail();
    if (email != null) {
      final user = UserStore.getUserByEmail(email);
      if (user != null) {
        user.isPremium = true;
        user.selectedPlanId = planId;
        user.premiumActivatedAt = DateTime.now();
        await user.save();
      }
    }
  }

  /// Returns days remaining in trial, or 0 if not in trial.
  static int trialDaysRemaining() {
    final trialStart = LocalPreferences.getTrialStartDate();
    if (trialStart == null) return 0;
    final trialEnd = trialStart.add(const Duration(days: 7));
    final remaining = trialEnd.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  static String get selectedPlanId => LocalPreferences.getSelectedPlanId() ?? 'monthly';
}
