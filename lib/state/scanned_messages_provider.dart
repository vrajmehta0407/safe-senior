// lib/state/scanned_messages_provider.dart
// Riverpod provider for scanned messages — dynamic threat & complaint intelligence.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scanned_message.dart';

class ScannedMessagesNotifier extends StateNotifier<List<ScannedMessage>> {
  ScannedMessagesNotifier()
      : super([
          ScannedMessage(
            sender: 'VM-SBIINB (Spoofed)',
            body: '"Your SBI YONO account has been suspended due to pending PAN KYC. Click here immediately to verify: http://sbi-kyc-verify-882.in"',
            maskedBody: '"Your SBI YONO account has been suspended due to pending PAN KYC. Click here immediately to verify: http://sbi-kyc-verify-882.in"',
            riskLevelIndex: 2, // danger
            reasons: ['Suspicious Phishing URL', 'Urgency Coercion', 'Impersonates SBI Bank'],
            matchedKeywords: ['suspended', 'kyc', 'immediately', 'verify'],
            receivedAt: DateTime.now().subtract(const Duration(hours: 2)),
            isBlocked: true,
          ),
          ScannedMessage(
            sender: 'BP-UGVCL-Notice',
            body: '"Dear Consumer, your electricity power will be disconnected tonight at 9:30 PM due to unpaid bill of ₹2,840. Call electricity officer at +91 94820 11928 to avoid power cut."',
            maskedBody: '"Dear Consumer, your electricity power will be disconnected tonight at 9:30 PM due to unpaid bill of ₹2,840. Call electricity officer at +91 94820 11928 to avoid power cut."',
            riskLevelIndex: 2, // danger
            reasons: ['Fake Utility Disconnection', '10-Digit Mobile Callback Trap', 'Urgent Disconnection Threat'],
            matchedKeywords: ['disconnected', 'unpaid bill', 'electricity officer'],
            receivedAt: DateTime.now().subtract(const Duration(hours: 6)),
            isBlocked: true,
          ),
          ScannedMessage(
            sender: 'CBI Cyber Crime (Spoofed)',
            body: '"Video Call Notice: An unauthorized Fedex parcel with contraband was booked under your Aadhaar. Connect Skype immediately for digital arrest bail clearance."',
            maskedBody: '"Video Call Notice: An unauthorized Fedex parcel with contraband was booked under your Aadhaar. Connect Skype immediately for digital arrest bail clearance."',
            riskLevelIndex: 2, // danger
            reasons: ['Digital Arrest Threat', 'Impersonates Law Enforcement', 'Extortion Coercion'],
            matchedKeywords: ['cbi', 'contraband', 'digital arrest', 'skype'],
            receivedAt: DateTime.now().subtract(const Duration(hours: 14)),
            isBlocked: true,
          ),
          ScannedMessage(
            sender: 'Amazon India Support?',
            body: '"A large debit order of ₹45,999 on iPhone 16 was placed from your account. If this was not you, call +91 98765 43210 immediately."',
            maskedBody: '"A large debit order of ₹45,999 on iPhone 16 was placed from your account. If this was not you, call +91 98765 43210 immediately."',
            riskLevelIndex: 1, // caution
            reasons: ['Impersonates Brand', 'Urgency Call-back Bait'],
            matchedKeywords: ['order', 'was not you', 'immediately'],
            receivedAt: DateTime.now().subtract(const Duration(days: 1)),
            isBlocked: true,
          ),
          ScannedMessage(
            sender: '+91 98251 09841',
            body: '"KBC Lucky Winner: Congratulations, you have won ₹25,00,000 lottery cash prize! Scan UPI QR or send processing fee ₹4,999 to claim in bank account."',
            maskedBody: '"KBC Lucky Winner: Congratulations, you have won ₹25,00,000 lottery cash prize! Scan UPI QR or send processing fee ₹4,999 to claim in bank account."',
            riskLevelIndex: 2, // danger
            reasons: ['Reverse UPI Scam', 'Lottery Fee Extortion', 'Unregistered Sender'],
            matchedKeywords: ['lottery', 'winner', 'processing fee', 'claim'],
            receivedAt: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
            isBlocked: true,
          ),
          ScannedMessage(
            sender: 'HDFC Bank Alert (Spoofed)',
            body: '"Your HDFC NetBanking has been locked due to multiple invalid login attempts. Unlock now by entering OTP at https://hdfc-security-portal.top"',
            maskedBody: '"Your HDFC NetBanking has been locked due to multiple invalid login attempts. Unlock now by entering OTP at https://hdfc-security-portal.top"',
            riskLevelIndex: 2, // danger
            reasons: ['Phishing Domain (.top)', 'Credential Harvesting', 'Urgent Account Freeze'],
            matchedKeywords: ['locked', 'netbanking', 'otp', 'unlock'],
            receivedAt: DateTime.now().subtract(const Duration(days: 2)),
            isBlocked: true,
          ),
          ScannedMessage(
            sender: 'India Post Delivery',
            body: '"Delivery failed: Package #INP-88291 could not be delivered to your address. Update address within 24 hours at https://indiapost-update.xyz/track"',
            maskedBody: '"Delivery failed: Package #INP-88291 could not be delivered to your address. Update address within 24 hours at https://indiapost-update.xyz/track"',
            riskLevelIndex: 2, // danger
            reasons: ['Parcel Smishing', 'Malicious TLD (.xyz)', 'Fake Courier Surcharge'],
            matchedKeywords: ['delivery failed', 'package', 'update address'],
            receivedAt: DateTime.now().subtract(const Duration(days: 2, hours: 10)),
            isBlocked: true,
          ),
          ScannedMessage(
            sender: '+91 88990 11223',
            body: '"Mummy, my phone screen broke so I am using this temp number. Need ₹12,000 urgently for tuition deposit, please send to tutor@upi right now!"',
            maskedBody: '"Mummy, my phone screen broke so I am using this temp number. Need ₹12,000 urgently for tuition deposit, please send to tutor@upi right now!"',
            riskLevelIndex: 2, // danger
            reasons: ['Family Impersonation', 'Urgent Fund Transfer Bait', 'Unverified Phone Number'],
            matchedKeywords: ['temp number', 'urgently', 'send right now'],
            receivedAt: DateTime.now().subtract(const Duration(days: 3)),
            isBlocked: true,
          ),
          ScannedMessage(
            sender: 'PM Pension Yojana Desk',
            body: '"Government Pension Department: Your senior pension installment of ₹18,000 is on hold. Call officer at +91 99201 44820 to release funds."',
            maskedBody: '"Government Pension Department: Your senior pension installment of ₹18,000 is on hold. Call officer at +91 99201 44820 to release funds."',
            riskLevelIndex: 2, // danger
            reasons: ['Govt Pension Fraud', 'Personal Mobile Helpline Scam', 'Urgency Coercion'],
            matchedKeywords: ['pension', 'on hold', 'release funds'],
            receivedAt: DateTime.now().subtract(const Duration(days: 3, hours: 8)),
            isBlocked: true,
          ),
          ScannedMessage(
            sender: '+91 140 928374',
            body: '"Automated Robocall: Pre-approved senior citizen health insurance loan of ₹5,00,000. Press 1 to speak with executive."',
            maskedBody: '"Automated Robocall: Pre-approved senior citizen health insurance loan of ₹5,00,000. Press 1 to speak with executive."',
            riskLevelIndex: 1, // caution
            reasons: ['Telemarketing Spam', 'Unregistered Telemarketer (+140)'],
            matchedKeywords: ['pre-approved', 'loan', 'insurance'],
            receivedAt: DateTime.now().subtract(const Duration(days: 4)),
            isBlocked: true,
          ),
          ScannedMessage(
            sender: 'Telecom SIM Helpdesk',
            body: '"Urgent: Your Airtel/Jio SIM card KYC will be terminated in 12 hours. Send SMS SIMREQ 1234 to 121 to prevent permanent disconnection."',
            maskedBody: '"Urgent: Your Airtel/Jio SIM card KYC will be terminated in 12 hours. Send SMS SIMREQ 1234 to 121 to prevent permanent disconnection."',
            riskLevelIndex: 2, // danger
            reasons: ['SIM Swap Attack', 'Identity Hijacking Attempt', 'Urgent Disconnection Threat'],
            matchedKeywords: ['sim card', 'kyc', 'terminated', 'disconnection'],
            receivedAt: DateTime.now().subtract(const Duration(days: 4, hours: 12)),
            isBlocked: true,
          ),
          ScannedMessage(
            sender: 'Telegram Work-From-Home',
            body: '"Earn ₹3,000 daily from home! Like 3 YouTube videos and receive ₹500 immediately. Contact @ManagerRahul on Telegram."',
            maskedBody: '"Earn ₹3,000 daily from home! Like 3 YouTube videos and receive ₹500 immediately. Contact @ManagerRahul on Telegram."',
            riskLevelIndex: 1, // caution
            reasons: ['Part-Time Task Scam', 'Prepaid Task Trap', 'Unregulated Messaging Channel'],
            matchedKeywords: ['earn daily', 'work from home', 'telegram'],
            receivedAt: DateTime.now().subtract(const Duration(days: 5)),
            isBlocked: true,
          ),
          ScannedMessage(
            sender: 'Priya (Granddaughter)',
            body: '"Namaste Dadaji! Just checking in to see if you took your evening medicines? Amit Bhaiyya is visiting tomorrow. Love you!"',
            maskedBody: '"Namaste Dadaji! Just checking in to see if you took your evening medicines? Amit Bhaiyya is visiting tomorrow. Love you!"',
            riskLevelIndex: 0, // safe
            reasons: [],
            matchedKeywords: [],
            receivedAt: DateTime.now().subtract(const Duration(days: 5, hours: 4)),
          ),
          ScannedMessage(
            sender: 'Apollo Pharmacy Bengaluru',
            body: '"Your monthly prescription refill is ready for free home delivery. Order #AP-99201."',
            maskedBody: '"Your monthly prescription refill is ready for free home delivery. Order #AP-99201."',
            riskLevelIndex: 0, // safe
            reasons: [],
            matchedKeywords: [],
            receivedAt: DateTime.now().subtract(const Duration(days: 6)),
          ),
          ScannedMessage(
            sender: 'Torrent Power Official',
            body: '"Your electricity bill payment of ₹1,420 for Consumer ID 1009823 was received with thanks. Receipt #TP-8842."',
            maskedBody: '"Your electricity bill payment of ₹1,420 for Consumer ID 1009823 was received with thanks. Receipt #TP-8842."',
            riskLevelIndex: 0, // safe
            reasons: [],
            matchedKeywords: [],
            receivedAt: DateTime.now().subtract(const Duration(days: 6, hours: 18)),
          ),
        ]);

  void markReported(ScannedMessage msg) {
    state = [
      for (final m in state)
        if (m.sender == msg.sender && m.receivedAt == msg.receivedAt)
          ScannedMessage(
            sender: m.sender,
            body: m.body,
            maskedBody: m.maskedBody,
            riskLevelIndex: 2,
            reasons: m.reasons,
            matchedKeywords: m.matchedKeywords,
            receivedAt: m.receivedAt,
            isBlocked: true,
            isUserConfirmedScam: true,
          )
        else
          m,
    ];
  }

  /// Dynamically generates a new simulated threat complaint into the weekly feed
  void generateDynamicComplaint() {
    final now = DateTime.now();
    final newComplaintsPool = [
      ScannedMessage(
        sender: 'Income Tax Dept (Spoofed)',
        body: '"Tax Refund Alert: An excess deduction of ₹38,450 has been approved. Enter your bank details at https://incometax-refund.top to claim in your account."',
        maskedBody: '"Tax Refund Alert: An excess deduction of ₹38,450 has been approved. Enter your bank details at https://incometax-refund.top to claim in your account."',
        riskLevelIndex: 2,
        reasons: ['Fake Tax Refund', 'Malicious TLD (.top)', 'Bank Account Harvesting'],
        matchedKeywords: ['refund', 'approved', 'tax', 'claim'],
        receivedAt: now,
        isBlocked: true,
      ),
      ScannedMessage(
        sender: 'Traffic Police E-Challan',
        body: '"Traffic Violation Notice: Pending fine of ₹1,000 against vehicle GJ01-AB1234. Pay within 24 hours at http://echallan-pay.xyz/fine to avoid court summons."',
        maskedBody: '"Traffic Violation Notice: Pending fine of ₹1,000 against vehicle GJ01-AB1234. Pay within 24 hours at http://echallan-pay.xyz/fine to avoid court summons."',
        riskLevelIndex: 2,
        reasons: ['Spoofed Police Challan', 'Fake Court Summons Threat', 'Phishing Domain (.xyz)'],
        matchedKeywords: ['challan', 'violation', 'fine', 'summons'],
        receivedAt: now,
        isBlocked: true,
      ),
      ScannedMessage(
        sender: '+91 97120 44881',
        body: '"Ayushman Senior Health Card: Re-verify Aadhaar to prevent health cover cancellation. Call officer at +91 97120 44881."',
        maskedBody: '"Ayushman Senior Health Card: Re-verify Aadhaar to prevent health cover cancellation. Call officer at +91 97120 44881."',
        riskLevelIndex: 2,
        reasons: ['Ayushman Bharat Impersonation', 'Fake Scheme Cancellation Threat', 'Mobile Callback Trap'],
        matchedKeywords: ['ayushman', 'cancellation', 'health card'],
        receivedAt: now,
        isBlocked: true,
      ),
      ScannedMessage(
        sender: 'Customs Cyber Desk',
        body: '"Delhi Airport Customs: A parcel from UK addressed to you has been detained with undeclared cash. Pay ₹25,000 penalty immediately to avoid arrest."',
        maskedBody: '"Delhi Airport Customs: A parcel from UK addressed to you has been detained with undeclared cash. Pay ₹25,000 penalty immediately to avoid arrest."',
        riskLevelIndex: 2,
        reasons: ['Airport Customs Extortion', 'Fake Arrest Threat', 'Urgent Wire Transfer Demand'],
        matchedKeywords: ['customs', 'parcel', 'penalty', 'arrest'],
        receivedAt: now,
        isBlocked: true,
      ),
      ScannedMessage(
        sender: 'FASTag Security Alert',
        body: '"Your FASTag wallet has been blocked due to unlinked vehicle documents. Update at https://fastag-kyc.click within 12 hours."',
        maskedBody: '"Your FASTag wallet has been blocked due to unlinked vehicle documents. Update at https://fastag-kyc.click within 12 hours."',
        riskLevelIndex: 2,
        reasons: ['FASTag Wallet Phishing', 'Malicious TLD (.click)', 'Urgent Wallet Freeze'],
        matchedKeywords: ['fastag', 'blocked', 'update'],
        receivedAt: now,
        isBlocked: true,
      ),
    ];

    final pick = newComplaintsPool[now.millisecondsSinceEpoch % newComplaintsPool.length];
    state = [pick, ...state];
  }
}

final scannedMessagesProvider =
    StateNotifierProvider<ScannedMessagesNotifier, List<ScannedMessage>>(
  (ref) => ScannedMessagesNotifier(),
);

final suspiciousMessagesProvider = Provider<List<ScannedMessage>>((ref) {
  return ref
      .watch(scannedMessagesProvider)
      .where((m) => m.riskLevelIndex > 0)
      .toList();
});
