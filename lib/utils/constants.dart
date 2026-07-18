// lib/utils/constants.dart
// Central constants: keyword lists, safety tips, plan data, app-wide values.

class AppConstants {
  // ─── Scam keyword lists ────────────────────────────────────────────────────
  static const List<String> suspiciousKeywords = [
    'winner', 'won', 'prize', 'lottery', 'urgent', 'account blocked',
    'verify', 'kyc', 'suspend', 'expiration', 'unusual activity', 'refund',
    'claim', 'deposit', 'investment', 'profit', 'otp', 'pin', 'password',
    'cvv', 'atm card', 'credit card',
  ];

  static const List<String> urgencyPhrases = [
    'immediately', 'now', 'today only', 'within 24 hours', 'action required',
    'act now', 'limited time', 'expires soon', "don't wait",
    'risk of suspension', 'legal action',
  ];

  static const List<String> authorityImpersonationKeywords = [
    'police', 'cbi', 'rbi', 'income tax', 'customs', 'irs', 'court',
    'warrant', 'arrest', 'manager',
  ];

  static const List<String> remoteAccessKeywords = [
    'anydesk', 'teamviewer', 'quicksupport', 'screen share', 'remote access',
    'ammyy', 'supremo', 'ultraviewer', 'rustdesk', 'zoho assist',
    'logmein', 'gotomypc',
  ];

  static const List<String> knownPhishingDomains = [
    'bit.ly', 'tinyurl.com', 'goo.gl', 'ow.ly', 't.co',
  ];

  // Multilingual scam keywords (Hindi / Gujarati / Tamil / Telugu / Bengali)
  static const List<String> multilingualScamKeywords = [
    // Hindi
    'इनाम', 'जीत', 'पुरस्कार', 'लॉटरी', 'तुरंत', 'खाता बंद', 'सत्यापित',
    'ओटीपी', 'पिन', 'पासवर्ड',
    // Gujarati
    'ઇનામ', 'જીત', 'ઓટીપી',
    // Tamil
    'பரிசு', 'வெற்றி', 'OTP',
    // Telugu
    'బహుమతి', 'గెలుపు', 'OTP',
    // Bengali
    'পুরস্কার', 'জয়', 'ওটিপি',
  ];

  // ─── OTP regex ─────────────────────────────────────────────────────────────
  static final RegExp otpPattern = RegExp(r'(?<!\d)\d{4,8}(?!\d)');
  static final RegExp urlPattern = RegExp(r'https?://[^\s]+');

  // ─── Safety Tips ───────────────────────────────────────────────────────────
  static const List<Map<String, String>> safetyTips = [
    {
      'title': 'Banks Never Ask for OTP',
      'body': 'Your bank will NEVER call or text asking for your One-Time Password (OTP). If someone does, hang up immediately.',
      'icon': 'bank',
    },
    {
      'title': 'Never Install Remote-Access Apps',
      'body': 'Never install AnyDesk, TeamViewer, or similar apps for a stranger who called you. This gives them full control of your phone.',
      'icon': 'phone',
    },
    {
      'title': 'Government Agencies Don\'t Demand Instant Payment',
      'body': 'Real government officials never call demanding immediate payment via gift cards, wire transfer, or cryptocurrency.',
      'icon': 'government',
    },
    {
      'title': 'Verify Before You Click',
      'body': 'Always verify a link before clicking. Hover over it or long-press to see the real URL. If it looks strange, don\'t click.',
      'icon': 'link',
    },
    {
      'title': 'Too Good to Be True',
      'body': 'If a message says you\'ve won a prize you didn\'t enter, it\'s almost certainly a scam. Delete and block.',
      'icon': 'prize',
    },
    {
      'title': 'Use Strong, Unique Passwords',
      'body': 'Use a different password for each account. A strong password has letters, numbers, and symbols.',
      'icon': 'password',
    },
    {
      'title': 'Don\'t Share OTPs with Anyone',
      'body': 'An OTP is for YOUR eyes only. No legitimate company will ever ask you to share your OTP over phone or text.',
      'icon': 'otp',
    },
    {
      'title': 'Beware of Misspelled URLs',
      'body': 'Scammers use websites like "g00gle.com" (with zeros) to trick you. Always check the spelling of website addresses.',
      'icon': 'url',
    },
    {
      'title': 'Check the Caller ID',
      'body': 'Scammers can fake caller IDs to look like your bank or government. When in doubt, hang up and call the official number.',
      'icon': 'call',
    },
    {
      'title': 'Guard Your Aadhaar & PAN Details',
      'body': 'Never share your Aadhaar number, PAN card number, or date of birth with unknown callers or on untrusted websites.',
      'icon': 'id',
    },
    {
      'title': 'Update Your Apps Regularly',
      'body': 'Keep your phone and apps updated. Updates often fix security holes that scammers can exploit.',
      'icon': 'update',
    },
    {
      'title': 'Be Careful on Public Wi-Fi',
      'body': 'Avoid accessing your bank or sensitive accounts when connected to public Wi-Fi at cafes or airports.',
      'icon': 'wifi',
    },
    {
      'title': 'Report Suspicious Calls',
      'body': 'If you receive a suspicious call, report it to your local cybercrime cell or use Safe Senior\'s "Report Scam" feature.',
      'icon': 'report',
    },
    {
      'title': 'Trust Your Instincts',
      'body': 'If a call, message, or email makes you feel pressured, scared, or confused — stop, pause, and call a trusted family member before doing anything.',
      'icon': 'trust',
    },
    {
      'title': 'Lock Your SIM Card',
      'body': 'Enable a SIM PIN to prevent unauthorized use if your phone is lost or stolen. Ask your carrier or check Settings > Security.',
      'icon': 'sim',
    },
    {
      'title': 'Enable Two-Factor Authentication',
      'body': 'For your email and bank apps, enable Two-Factor Authentication (2FA). This adds an extra layer of security even if your password is stolen.',
      'icon': 'twofactor',
    },
    {
      'title': 'Don\'t Click "Unsubscribe" in Spam Emails',
      'body': 'Clicking "Unsubscribe" in a spam email can confirm your address is active and lead to more spam. Simply delete it.',
      'icon': 'email',
    },
    {
      'title': 'Grandparent Scam Warning',
      'body': 'A caller pretending to be your grandchild in an emergency is a classic scam. Always verify by calling your family directly before sending money.',
      'icon': 'family',
    },
  ];

  // ─── Premium Plans ─────────────────────────────────────────────────────────
  // Mirrors the values visually shown in plan_selection_screen.dart
  static const Map<String, dynamic> monthlyPlan = {
    'id': 'monthly',
    'name': 'Basic Protection',
    'label': 'Monthly Plan',
    'price': 9.99,
    'period': 'month',
    'yearlyEquivalent': null,
  };

  static const Map<String, dynamic> annualPlan = {
    'id': 'annual',
    'name': 'Premium Protection',
    'label': 'Annual Plan',
    'price': 89.99,
    'period': 'year',
    'yearlyEquivalent': 7.50, // per month
  };

  // ─── Trial ─────────────────────────────────────────────────────────────────
  static const int trialDurationDays = 7;

  // ─── Hive Box Names ────────────────────────────────────────────────────────
  static const String userBoxName = 'users';
  static const String messageBoxName = 'messages';
  static const String statsBoxName = 'stats';
  static const String settingsBoxName = 'settings';

  // ─── SharedPreferences Keys ────────────────────────────────────────────────
  static const String keyCurrentUserEmail = 'current_user_email';
  static const String keyLanguage = 'selected_language';
  static const String keyVoiceEnabled = 'voice_enabled';
  static const String keyVoiceSpeed = 'voice_speed';
  static const String keyVoiceType = 'voice_type';
  static const String keyVoiceGender = 'voice_gender';
  static const String keyThemeMode = 'theme_mode';
  static const String keyPremiumStatus = 'premium_status';
  static const String keyTrialStartDate = 'trial_start_date';
  static const String keySelectedPlanId = 'selected_plan_id';
  static const String keyJwtToken = 'jwt_token';

  // ─── Supported Languages ───────────────────────────────────────────────────
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'hi', 'name': 'Hindi', 'native': 'हिन्दी'},
    {'code': 'gu', 'name': 'Gujarati', 'native': 'ગુજરાતી'},
    {'code': 'ta', 'name': 'Tamil', 'native': 'தமிழ்'},
    {'code': 'te', 'name': 'Telugu', 'native': 'తెలుగు'},
    {'code': 'bn', 'name': 'Bengali', 'native': 'বাংলা'},
  ];
}
