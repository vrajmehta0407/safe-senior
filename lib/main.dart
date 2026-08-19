// lib/main.dart
// App entry point — wires Riverpod, Hive, LocalPreferences, dark mode, and localization.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
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
import 'services/sms_service.dart';
import 'services/call_service.dart';             // BUG 10
import 'services/platform_capabilities.dart';   // BUG 7
import 'services/pattern_cache_service.dart';    // Offline-first pattern cache
import 'services/trusted_sender_cache.dart';      // User's personal allowlist
import 'services/permission_service.dart';
import 'state/theme_provider.dart';
import 'state/language_provider.dart';
import 'state/protection_stats_provider.dart';
import 'screens/otp_alert_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Global ProviderContainer so SmsService callbacks can refresh Riverpod state
/// even when called from outside the widget tree.
ProviderContainer? _container;

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
  PatternCacheService.refreshFromBackend().ignore();

  // ── Services ───────────────────────────────────────────────────────────────
  await VoiceService.init();
  await NotificationService.init();

  // BUG 7 FIX: probe real biometric capability at startup
  await PlatformCapabilities.checkBiometricAvailability();

  await BlocklistService.init();

  // ── Offline-first scam pattern cache ───────────────────────────────────────
  await PatternCacheService.init();
  // Sync in background — don't block startup if offline
  PatternCacheService.syncPatterns();
  // Sync trusted senders in background (user's personal allowlist)
  TrustedSenderCache.sync();

  // BUG 10 FIX: register native MethodChannel handler so Kotlin CallBlockerPlugin
  // can call back into Dart for blocklist checks (must happen before runApp).
  CallService.registerMethodCallHandler();

  // ── Auto-Start SMS Monitoring & Permissions ──────────────────────────────
  PermissionService.requestPostLoginPermissions().then((_) {
    SmsService.startMonitoring();
  }).catchError((_) {});

  // ── Auto-Popup for Fake OTPs / Scam Messages ────────────────────────────────
  SmsService.setDangerCallback((msg) {
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    // Always push a new alert screen even if one is already showing.
    // Using push (not pushAndRemoveUntil) so the user can see each alert.
    nav.push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => OtpAlertScreen(
          message: msg.maskedBody,
          code: msg.extractedCode,
          sender: msg.sender,
        ),
        // Fast fade-in so alert feels urgent
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  });

  // ── Wire stats refresh to Riverpod ──────────────────────────────────────────
  SmsService.setStatsChangedCallback(() {
    _container?.read(protectionStatsProvider.notifier).refresh();
  });

  _container = ProviderContainer();

  runApp(
    UncontrolledProviderScope(
      container: _container!,
      child: const SafeSeniorApp(),
    ),
  );
}

class SafeSeniorApp extends ConsumerWidget {
  const SafeSeniorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode    = ref.watch(themeModeProvider);
    final languageCode = ref.watch(languageProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
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
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
