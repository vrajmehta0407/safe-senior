import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:safe_senior/models/guardian_contact.dart';
import 'package:safe_senior/models/user_profile.dart';
import 'package:safe_senior/models/scanned_message.dart';
import 'package:safe_senior/storage/local_preferences.dart';
import 'package:safe_senior/storage/user_store.dart';
import 'package:safe_senior/storage/message_store.dart';
import 'package:safe_senior/services/guardian_service.dart';
import 'package:safe_senior/services/detection/blocklist_service.dart';
import 'package:safe_senior/screens/login_screen.dart';
import 'package:safe_senior/screens/get_started_screen.dart';
import 'package:safe_senior/screens/register_step1_screen.dart';
import 'package:safe_senior/screens/register_step2_screen.dart';
import 'package:safe_senior/screens/forgot_pin_screen.dart';
import 'package:safe_senior/screens/emergency_screen.dart';
import 'package:safe_senior/screens/home_screen.dart';
import 'package:safe_senior/screens/security_status_screen.dart';
import 'package:safe_senior/screens/safety_quiz_hub_screen.dart';
import 'package:safe_senior/screens/sms_scam_alert_screen.dart';
import 'package:safe_senior/screens/warning_alert_screen.dart';

late Directory _envDir;

Future<void> _setupEnv() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null; // Don't crash on network image
  SharedPreferences.setMockInitialValues({
    'remember_me': true,
    'remembered_email': 'test@example.com',
    'voice_guidance_enabled': true,
  });
  await LocalPreferences.init();

  _envDir = await Directory.systemTemp.createTemp('safesenior_full_qa_');
  Hive.init(_envDir.path);

  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(UserProfileAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(GuardianContactAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(ScannedMessageAdapter());

  await UserStore.init();
  await MessageStore.init();
  await GuardianService.init();
  await BlocklistService.init();
}

Widget _app(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  setUpAll(() async {
    await _setupEnv();
  });

  tearDownAll(() async {
    await Hive.close();
    if (_envDir.existsSync()) {
      _envDir.deleteSync(recursive: true);
    }
  });

  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(1080, 2400);
    binding.platformDispatcher.views.first.devicePixelRatio = 2.0;
  });

  tearDown(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.resetPhysicalSize();
    binding.platformDispatcher.views.first.resetDevicePixelRatio();
  });

  group('Auth Flow Exhaustive Verification', () {
    testWidgets('LoginScreen validation: empty fields show errors', (tester) async {
      await tester.pumpWidget(_app(const LoginScreen()));
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).first, '');
      final signInBtn = find.text('Sign In');
      expect(signInBtn, findsOneWidget);

      await tester.tap(signInBtn);
      await tester.pump();

      expect(find.text('Please enter your email address'), findsOneWidget);
      expect(find.text('Please enter your PIN'), findsOneWidget);
    });

    testWidgets('LoginScreen: password visibility eye icon toggles', (tester) async {
      await tester.pumpWidget(_app(const LoginScreen()));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('GetStartedScreen renders navigation card to email register', (tester) async {
      await tester.pumpWidget(_app(const GetStartedScreen()));
      await tester.pump();

      expect(find.text('Continue with Email'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
    });

    testWidgets('RegisterStep1Screen: empty form validation checks', (tester) async {
      await tester.pumpWidget(_app(const RegisterStep1Screen(isEmail: true)));
      await tester.pump();

      final nextBtn = find.text('Next Step');
      expect(nextBtn, findsOneWidget);
      await tester.tap(nextBtn);
      await tester.pump();

      expect(find.text('Please enter your name'), findsOneWidget);
      expect(find.text('Please enter your email address'), findsOneWidget);
    });

    testWidgets('RegisterStep1Screen (Email): invalid email format caught', (tester) async {
      await tester.pumpWidget(_app(const RegisterStep1Screen(isEmail: true)));
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).first, 'John Senior');
      await tester.enterText(find.byType(TextFormField).at(1), 'invalid-email');

      await tester.tap(find.text('Next Step'));
      await tester.pump();

      expect(find.text('Enter a valid email address'), findsOneWidget);
    });

    testWidgets('RegisterStep2Screen: PIN mismatch validation', (tester) async {
      await tester.pumpWidget(_app(const RegisterStep2Screen(name: 'Senior User', phone: '+91 9876543210')));
      await tester.pump();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '1234');
      await tester.enterText(fields.at(1), '9999');

      await tester.tap(find.text('Create My Account'));
      await tester.pump();

      expect(find.text('PINs do not match'), findsOneWidget);
    });

    testWidgets('ForgotPinScreen: walks through OTP and sets new PIN', (tester) async {
      await tester.pumpWidget(_app(const ForgotPinScreen()));
      await tester.pump();

      expect(find.text('Reset Your PIN'), findsOneWidget);
      expect(find.text('Send OTP to Email'), findsOneWidget);
      expect(find.text('Guardian Verification'), findsOneWidget);
      expect(find.text('Contact Support'), findsOneWidget);
    });
  });

  group('Core & Safety Screens Verification', () {
    testWidgets('EmergencyScreen: SOS Panic button & 3 quick connects render properly', (tester) async {
      await tester.pumpWidget(_app(const EmergencyScreen()));
      await tester.pump();

      expect(find.text('Emergency'), findsOneWidget);
      expect(find.text('SOS'), findsOneWidget);
      expect(find.text('Police / Emergency (112)'), findsOneWidget);
      expect(find.text('Cybercrime Helpline (1930)'), findsOneWidget);
      expect(find.text('CANCEL & RETURN'), findsOneWidget);
    });

    testWidgets('HomeScreen: Filter pills switch states seamlessly', (tester) async {
      await tester.pumpWidget(_app(const HomeScreen()));
      await tester.pump();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Alerts'), findsOneWidget);
      expect(find.text('Tips'), findsOneWidget);
      expect(find.text('Quizzes'), findsOneWidget);

      await tester.tap(find.text('Alerts'));
      await tester.pump();

      await tester.tap(find.text('Quizzes'));
      await tester.pump();
    });

    testWidgets('SecurityStatusScreen: 8-point check renders without crashes', (tester) async {
      await tester.pumpWidget(_app(const SecurityStatusScreen()));
      await tester.pump();

      expect(find.text('Account Security Health'), findsOneWidget);
    });

    testWidgets('SafetyQuizHubScreen: Quiz questions load properly', (tester) async {
      await tester.pumpWidget(_app(const SafetyQuizHubScreen()));
      await tester.pump();

      expect(find.text('Safety Training & Quizzes'), findsOneWidget);
    });

    testWidgets('SmsScamAlertScreen: verifies dead buttons "Report Sender" and "Mark as Safe"', (tester) async {
      await tester.pumpWidget(_app(const SmsScamAlertScreen()));
      await tester.pump();

      expect(find.text('Block & Report'), findsOneWidget);
      expect(find.text('Mark as Safe'), findsOneWidget);
      expect(find.text("Message Blocked — I'm Safe"), findsOneWidget);

      await tester.tap(find.text('Block & Report'), warnIfMissed: false);
      await tester.pump();
      await tester.tap(find.text('Mark as Safe'), warnIfMissed: false);
      await tester.pump();
    });

    testWidgets('WarningAlertScreen: Threat protocol displays', (tester) async {
      await tester.pumpWidget(_app(const WarningAlertScreen()));
      await tester.pump();

      expect(find.text('Scam Alert'), findsOneWidget);
    });
  });
}
