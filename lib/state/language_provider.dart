// lib/state/language_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/local_preferences.dart';

class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super(LocalPreferences.getLanguage());

  Future<void> setLanguage(String code) async {
    await LocalPreferences.setLanguage(code);
    state = code;
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, String>(
  (ref) => LanguageNotifier(),
);
