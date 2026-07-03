// lib/state/guardian_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/guardian_contact.dart';
import '../services/guardian_service.dart';

class GuardianNotifier extends StateNotifier<GuardianContact?> {
  GuardianNotifier() : super(GuardianService.getPrimaryGuardian());

  Future<void> setGuardian(GuardianContact contact) async {
    await GuardianService.setGuardianContact(contact);
    state = contact;
  }

  Future<void> removeGuardian() async {
    await GuardianService.removeGuardian();
    state = null;
  }

  void refresh() {
    state = GuardianService.getPrimaryGuardian();
  }
}

final guardianProvider =
    StateNotifierProvider<GuardianNotifier, GuardianContact?>(
  (ref) => GuardianNotifier(),
);
