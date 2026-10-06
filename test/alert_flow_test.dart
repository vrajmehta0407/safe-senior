// test/alert_flow_test.dart
// Tests for Fake OTP and Fake Call Red Page Alert flow.
// Verifies that alerts trigger every time without stopping at 2-3 times.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:safe_senior/models/scanned_message.dart';
import 'package:safe_senior/models/user_profile.dart';
import 'package:safe_senior/models/guardian_contact.dart';
import 'package:safe_senior/storage/local_preferences.dart';
import 'package:safe_senior/storage/message_store.dart';
import 'package:safe_senior/services/detection/blocklist_service.dart';
import 'package:safe_senior/services/detection/scam_rule_engine.dart';
import 'package:safe_senior/services/call_service.dart';
import 'package:safe_senior/services/sms_service.dart';
import 'package:safe_senior/services/alert_manager.dart';

late Directory _alertTestDir;

Future<void> _initEnv() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  await LocalPreferences.init();

  _alertTestDir = await Directory.systemTemp.createTemp('safesenior_alert_test_');
  Hive.init(_alertTestDir.path);

  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(UserProfileAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(GuardianContactAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(ScannedMessageAdapter());

  await MessageStore.init();
  await BlocklistService.init();
}

void main() {
  setUpAll(() async {
    await _initEnv();
  });

  tearDownAll(() async {
    await Hive.close();
    if (_alertTestDir.existsSync()) {
      _alertTestDir.deleteSync(recursive: true);
    }
  });

  test('ScamRuleEngine detects Fake OTP messages as DANGER on 1st, 2nd, 3rd and subsequent attempts', () {
    const fakeOtpMsg = 'Your SBI NetBanking OTP is 849201 for payment of Rs 45,000 to Unknown Beneficiary. Do not share.';
    
    // Test 10 consecutive arrivals — must be danger every single time!
    for (int i = 1; i <= 10; i++) {
      final result = ScamRuleEngine.analyze('+91 98210 44921', fakeOtpMsg);
      expect(result.riskLevel, equals(RiskLevel.danger), reason: 'Attempt $i must be classified as DANGER');
      expect(result.extractedCode, isNotNull);
    }
  });

  test('ScamRuleEngine detects Blocked Senders as DANGER immediately', () {
    const sender = '+91 99999 88888';
    BlocklistService.blockSender(sender);

    final result = ScamRuleEngine.analyze(sender, 'Hello please reply');
    expect(result.riskLevel, equals(RiskLevel.danger));
    expect(result.reasons.any((r) => r.contains('Blocklist')), isTrue);
  });

  test('CallService triggers danger callback every time a suspicious call is detected', () async {
    int callAlertCount = 0;
    String lastPhone = '';

    CallService.setDangerCallback((phone, reason) {
      callAlertCount++;
      lastPhone = phone;
    });

    // Simulate 5 consecutive fake calls
    for (int i = 1; i <= 5; i++) {
      await CallService.onSuspiciousCallDetected('+91 11 2309 4712 (CBI Spoofed Call)', reason: 'Digital Arrest Call');
      expect(callAlertCount, equals(i), reason: 'Call alert must fire for attempt $i');
      expect(lastPhone, contains('CBI Spoofed Call'));
    }
  });

  test('SmsService triggers danger callback every time a fake OTP arrives without limit', () async {
    int smsAlertCount = 0;

    SmsService.setDangerCallback((msg) {
      smsAlertCount++;
    });

    // Process 8 consecutive fake OTP messages
    for (int i = 1; i <= 8; i++) {
      await SmsService.processMessage(
        sender: '+91 98765 0000$i',
        body: 'Urgent OTP 492$i for authorization of Rs 50,000 to merchant.',
      );
      expect(smsAlertCount, equals(i), reason: 'SMS danger callback must fire for attempt $i');
    }
  });

  test('AlertManager records consecutive alert invocations for many times', () {
    final initial = AlertManager.alertCount;

    // Trigger showOtpAlert 6 times
    for (int i = 1; i <= 6; i++) {
      AlertManager.showOtpAlert(
        sender: '+91 98210 44921',
        message: 'Your verification code is 123456',
        code: '123456',
      );
    }

    // Trigger showCallAlert 4 times
    for (int i = 1; i <= 4; i++) {
      AlertManager.showCallAlert(
        phoneNumber: '+91 11 2309 4712',
        reason: 'Police Extortion Call',
      );
    }

    expect(AlertManager.alertCount - initial, equals(10));
  });
}
