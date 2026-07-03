// lib/state/protection_stats_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/protection_stats.dart';
import '../storage/stats_store.dart';

class ProtectionStatsNotifier extends StateNotifier<ProtectionStats> {
  ProtectionStatsNotifier() : super(const ProtectionStats()) {
    _load();
  }

  Future<void> _load() async {
    state = await StatsStore.load();
  }

  Future<void> incrementBlocked({bool isCall = false}) async {
    await StatsStore.incrementBlocked(isCall: isCall);
    state = state.incrementBlocked(isCall: isCall);
  }

  Future<void> incrementScanned() async {
    await StatsStore.incrementScanned();
    state = state.incrementScanned();
  }

  Future<void> incrementCallsProtected() async {
    await StatsStore.incrementCallsProtected();
    state = state.incrementCallsProtected();
  }

  Future<void> refresh() async {
    state = await StatsStore.load();
  }
}

final protectionStatsProvider =
    StateNotifierProvider<ProtectionStatsNotifier, ProtectionStats>(
  (ref) => ProtectionStatsNotifier(),
);
