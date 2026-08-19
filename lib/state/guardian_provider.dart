import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/guardian_contact.dart';
import '../services/guardian_service.dart';

class GuardianNotifier extends StateNotifier<List<GuardianContact>> {
  GuardianNotifier() : super(GuardianService.getAllGuardians());

  /// Fetches guardians from the backend and refreshes local state.
  Future<void> fetchFromBackend() async {
    await GuardianService.fetchFromBackend();
    state = GuardianService.getAllGuardians();
  }

  Future<void> addGuardian(GuardianContact contact) async {
    await GuardianService.addGuardianContact(contact);
    state = GuardianService.getAllGuardians();
  }

  /// @deprecated — use addGuardian() instead.
  Future<void> setGuardian(GuardianContact contact) async {
    await GuardianService.setGuardianContact(contact);
    state = GuardianService.getAllGuardians();
  }

  Future<void> removeGuardianAt(int index) async {
    await GuardianService.removeGuardianAt(index);
    state = GuardianService.getAllGuardians();
  }

  /// Promotes the guardian at [index] to primary.
  Future<void> setPrimary(int index) async {
    await GuardianService.setPrimary(index);
    state = GuardianService.getAllGuardians();
  }

  Future<void> removeAll() async {
    await GuardianService.removeAll();
    state = [];
  }

  void refresh() {
    state = GuardianService.getAllGuardians();
  }
}

final guardianListProvider = StateNotifierProvider<GuardianNotifier, List<GuardianContact>>(
  (ref) => GuardianNotifier(),
);

/// Returns the contact marked isPrimary, falling back to the first in list.
final primaryGuardianProvider = Provider<GuardianContact?>((ref) {
  final list = ref.watch(guardianListProvider);
  if (list.isEmpty) return null;
  final primaryList = list.where((g) => g.isPrimary).toList();
  return primaryList.isNotEmpty ? primaryList.first : list.first;
});
