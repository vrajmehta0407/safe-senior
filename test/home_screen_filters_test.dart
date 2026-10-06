// test/home_screen_filters_test.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safe_senior/models/guardian_contact.dart';
import 'package:safe_senior/models/user_profile.dart';
import 'package:safe_senior/screens/home_screen.dart';
import 'package:safe_senior/services/guardian_service.dart';
import 'package:safe_senior/storage/local_preferences.dart';
import 'package:safe_senior/storage/user_store.dart';
import 'package:safe_senior/l10n/app_localizations.dart';

late Directory _testTempDir;

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('gu'),
      ],
      home: child,
    ),
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await LocalPreferences.init();

    _testTempDir = await Directory.systemTemp.createTemp('safesenior_home_test_');
    Hive.init(_testTempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserProfileAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(GuardianContactAdapter());
    }
    await UserStore.init();
    await GuardianService.init();
  });

  tearDownAll(() async {
    await Hive.close();
    if (_testTempDir.existsSync()) {
      await _testTempDir.delete(recursive: true);
    }
  });

  testWidgets('HomeScreen renders Badges, Reports, Family, and Quizzes views', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(_wrap(const HomeScreen()));
    await tester.pumpAndSettle();

    // 1. Badges view
    final badgesChip = find.byKey(const ValueKey('filter_Badges'));
    await tester.ensureVisible(badgesChip);
    await tester.pumpAndSettle();
    await tester.tap(badgesChip);
    await tester.pumpAndSettle();
    expect(find.text('Level 4 Cyber Sentinel • 1,240 XP'), findsWidgets);
    expect(find.text('7-Day Milestone Celebration'), findsWidgets);
    expect(find.text('Phishing Sentinel (Level 2)'), findsWidgets);

    // 2. Reports view
    final reportsChip = find.byKey(const ValueKey('filter_Reports'));
    await tester.ensureVisible(reportsChip);
    await tester.pumpAndSettle();
    await tester.tap(reportsChip);
    await tester.pumpAndSettle();
    expect(find.text('Weekly Protection Report'), findsWidgets);
    expect(find.text('Device Security Health Audit'), findsWidgets);
    expect(find.text('Blocked Incident History'), findsWidgets);

    // 3. Family view
    final familyChip = find.byKey(const ValueKey('filter_Family'));
    await tester.ensureVisible(familyChip);
    await tester.pumpAndSettle();
    await tester.tap(familyChip);
    await tester.pumpAndSettle();
    expect(find.text('Emergency SOS Panic Button'), findsWidgets);
    expect(find.text('Your Safety Circle'), findsWidgets);
    expect(find.text('Emergency & Cyber Helplines'), findsWidgets);
    expect(find.text('Safe Zones & Geofencing'), findsWidgets);

    // 4. Quizzes view
    final quizzesChip = find.byKey(const ValueKey('filter_Quizzes'));
    await tester.ensureVisible(quizzesChip);
    await tester.pumpAndSettle();
    await tester.tap(quizzesChip);
    await tester.pumpAndSettle();
    expect(find.text('Spot the Fake SBI KYC SMS'), findsWidgets);
    expect(find.text('Senior Cyber Shield Reflexes'), findsWidgets);
    expect(find.text('Digital Arrest & Police Video Scam'), findsWidgets);
  });
}
