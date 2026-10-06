// test/widget_test.dart
// Safe Senior — Flutter test suite
// Tests cover core providers, model correctness, and screen smoke tests.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:safe_senior/models/guardian_contact.dart';
import 'package:safe_senior/models/user_profile.dart';
import 'package:safe_senior/screens/login_screen.dart';
import 'package:safe_senior/screens/guardian_contacts_screen.dart';
import 'package:safe_senior/services/guardian_service.dart';
import 'package:safe_senior/storage/user_store.dart';
import 'package:safe_senior/storage/local_preferences.dart';
import 'package:safe_senior/state/auth_provider.dart';
import 'package:safe_senior/state/guardian_provider.dart';

// ─── Hive & Prefs Test Setup ───────────────────────────────────────────────

late Directory _testTempDir;

Future<void> _initTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  await LocalPreferences.init();

  _testTempDir = await Directory.systemTemp.createTemp('safesenior_test_');
  Hive.init(_testTempDir.path);
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UserProfileAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(GuardianContactAdapter());
  }
  await UserStore.init();
  await GuardianService.init();
}

// ─── Helper to wrap a widget with ProviderScope + MaterialApp ─────────────

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(home: child),
  );
}

// ─── Tests ─────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() async {
    await _initTestEnvironment();
  });

  tearDownAll(() async {
    await Hive.close();
    if (_testTempDir.existsSync()) {
      await _testTempDir.delete(recursive: true);
    }
  });

  // ── AuthProvider ────────────────────────────────────────────────────────

  group('AuthProvider', () {
    test('initial state is unauthenticated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(authProvider);
      expect(state.isLoggedIn, isFalse);
      expect(state.user, isNull);
    });
  });

  // ── GuardianContact model ───────────────────────────────────────────────

  group('GuardianContact model', () {
    test('isPrimary defaults to false', () {
      final contact = GuardianContact(
        name:    'Test Person',
        phone:   '+1234567890',
        addedAt: DateTime.now(),
      );
      expect(contact.isPrimary, isFalse);
      expect(contact.serverId, isNull);
      expect(contact.relationship, isNull);
    });

    test('can set isPrimary, serverId and relationship', () {
      final contact = GuardianContact(
        name:         'Mom',
        phone:        '+1234567890',
        addedAt:      DateTime.now(),
        isPrimary:    true,
        serverId:     42,
        relationship: 'family',
      );
      expect(contact.isPrimary, isTrue);
      expect(contact.serverId, equals(42));
      expect(contact.relationship, equals('family'));
    });

    test('isActive defaults to true', () {
      final contact = GuardianContact(
        name:    'Dad',
        phone:   '+0987654321',
        addedAt: DateTime.now(),
      );
      expect(contact.isActive, isTrue);
    });
  });

  // ── GuardianNotifier ────────────────────────────────────────────────────

  group('GuardianNotifier', () {
    test('starts with a list (empty or stored)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final contacts = container.read(guardianListProvider);
      expect(contacts, isA<List<GuardianContact>>());
    });

    test('primaryGuardianProvider returns null when list is empty', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(guardianListProvider.notifier).removeAll();
      final primary = container.read(primaryGuardianProvider);
      expect(primary, isNull);
    });
  });

  // ── Screen smoke tests ──────────────────────────────────────────────────

  group('LoginScreen', () {
    testWidgets('renders at least one text input and one button', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));
      await tester.pump();

      expect(find.byType(TextField), findsWidgets);
      expect(
        find.byWidgetPredicate(
          (w) => w is ElevatedButton || w is TextButton || w is FilledButton,
        ),
        findsWidgets,
      );
    });
  });

  group('GuardianContactsScreen', () {
    testWidgets('renders Guardian Contacts title', (tester) async {
      await tester.pumpWidget(_wrap(const GuardianContactsScreen()));
      await tester.pump();

      expect(find.text('Guardian Contacts'), findsAtLeast(1));
    });

    testWidgets('shows Add Trusted Contact button', (tester) async {
      await tester.pumpWidget(_wrap(const GuardianContactsScreen()));
      await tester.pump();

      expect(find.textContaining('Add Trusted Contact'), findsWidgets);
    });
  });
}
