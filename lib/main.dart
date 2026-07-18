// lib/main.dart
// App entry point — wires Riverpod, Hive, LocalPreferences, dark mode, and localization.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'models/user_profile.dart';
import 'models/guardian_contact.dart';
import 'models/scanned_message.dart';
import 'storage/local_preferences.dart';
import 'storage/user_store.dart';
import 'storage/message_store.dart';
import 'services/guardian_service.dart';
import 'services/voice_service.dart';
import 'services/notification_service.dart';
import 'services/detection/blocklist_service.dart';
import 'state/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Hive init ──────────────────────────────────────────────────────────────
  await Hive.initFlutter();
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(GuardianContactAdapter());
  Hive.registerAdapter(ScannedMessageAdapter());

  // ── Open Hive boxes ────────────────────────────────────────────────────────
  await UserStore.init();
  await MessageStore.init();
  await GuardianService.init();

  // ── SharedPreferences ──────────────────────────────────────────────────────
  await LocalPreferences.init();

  // ── Services ───────────────────────────────────────────────────────────────
  await VoiceService.init();
  await NotificationService.init();

  // ── Bundled blocklist ──────────────────────────────────────────────────────
  await BlocklistService.init();

  runApp(
    // Wrap with ProviderScope for Riverpod — no visual change to MaterialApp
    const ProviderScope(
      child: SafeSeniorApp(),
    ),
  );
}

class SafeSeniorApp extends ConsumerWidget {
  const SafeSeniorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final languageCode = LocalPreferences.getLanguage();

    return MaterialApp(
      title: 'Safe Senior',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: Locale(languageCode),
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('es'),
        Locale('gu'),
        Locale('ta'),
        Locale('te'),
        Locale('bn'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const LoginScreen(),
    );
  }
}
