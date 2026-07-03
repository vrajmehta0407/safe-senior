import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  runApp(
    // Wrap with ProviderScope for Riverpod — no visual change to MaterialApp
    const ProviderScope(
      child: SafeSeniorApp(),
    ),
  );
}

class SafeSeniorApp extends StatelessWidget {
  const SafeSeniorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe Senior',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
