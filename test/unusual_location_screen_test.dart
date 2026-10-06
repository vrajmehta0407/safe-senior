import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:safe_senior/models/guardian_contact.dart';
import 'package:safe_senior/models/user_profile.dart';
import 'package:safe_senior/models/scanned_message.dart';
import 'package:safe_senior/screens/unusual_location_screen.dart';
import 'package:safe_senior/storage/local_preferences.dart';
import 'package:safe_senior/services/guardian_service.dart';

late Directory _testDir;

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({
      'home_location_address': 'Malviya Nagar, Delhi',
      'home_lat': 28.5284,
      'home_lng': 77.2065,
      'last_known_location_address': 'Connaught Place, Delhi',
      'last_known_lat': 28.6315,
      'last_known_lng': 77.2167,
    });
    await LocalPreferences.init();

    _testDir = await Directory.systemTemp.createTemp('safesenior_unusual_loc_test_');
    Hive.init(_testDir.path);

    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(UserProfileAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(GuardianContactAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(ScannedMessageAdapter());

    await GuardianService.init();
  });

  tearDownAll(() async {
    await Hive.close();
    if (_testDir.existsSync()) {
      _testDir.deleteSync(recursive: true);
    }
  });

  testWidgets('UnusualLocationScreen renders dynamic Leaflet FlutterMap, location cards and actions', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: UnusualLocationScreen(
            detectedLocation: 'Connaught Place, Delhi',
            expectedLocation: 'Malviya Nagar, Delhi',
            timeDetected: '3:47 PM',
            currentLat: 28.6315,
            currentLng: 77.2167,
            homeLat: 28.5284,
            homeLng: 77.2065,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Header
    expect(find.text('⚠️ LOCATION ALERT'), findsOneWidget);
    expect(find.text('Unusual Location Pattern'), findsOneWidget);
    expect(find.text('Detected at 3:47 PM'), findsOneWidget);

    // Verify FlutterMap is present and rendered
    expect(find.byType(FlutterMap), findsOneWidget);

    // Verify Location info
    expect(find.text('Current Location'), findsOneWidget);
    expect(find.text('Connaught Place, Delhi'), findsOneWidget);
    expect(find.text('Your Home Area'), findsOneWidget);
    expect(find.text('Malviya Nagar, Delhi'), findsOneWidget);

    // Verify Dynamic Action Buttons
    expect(find.text("I'm Safe — Went Out Intentionally"), findsOneWidget);
    expect(find.text('Call Guardian'), findsOneWidget);
    expect(find.text('SOS'), findsOneWidget);
  });
}
