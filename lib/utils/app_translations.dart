import 'package:flutter/widgets.dart';

/// Unified translation dictionary supporting English ('en'), Hindi ('hi'), and Gujarati ('gu')
class AppTranslations {
  static final Map<String, Map<String, String>> _translations = {
    // ── Navigation & Common ──
    'Home': {'hi': 'होम', 'gu': 'હોમ'},
    'Shield': {'hi': 'सुरक्षा', 'gu': 'સુરક્ષા'},
    'Family': {'hi': 'परिवार', 'gu': 'પરિવાર'},
    'Settings': {'hi': 'सेटिंग्स', 'gu': 'સેટિંગ્સ'},
    'SafeSenior': {'hi': 'SafeSenior', 'gu': 'SafeSenior'},
    'Back': {'hi': 'पीछे', 'gu': 'પાછળ'},
    'Save': {'hi': 'सहेजें', 'gu': 'સાચવો'},
    'Cancel': {'hi': 'रद्द करें', 'gu': 'રદ કરો'},
    'Confirm': {'hi': 'पुष्टि करें', 'gu': 'પુષ્ટિ કરો'},
    'Done': {'hi': 'पूर्ण', 'gu': 'પૂર્ણ'},
    'Loading...': {'hi': 'लोड हो रहा है...', 'gu': 'લોડ થઈ રહ્યું છે...'},
    'Sign Out': {'hi': 'साइन आउट', 'gu': 'સાઇન આઉટ'},

    // ── Language Screen ──
    'Language': {'hi': 'भाषा', 'gu': 'ભાષા'},
    'Select your primary display & translation language.': {
      'hi': 'अपनी प्राथमिक प्रदर्शन और अनुवाद भाषा चुनें।',
      'gu': 'તમારી પ્રાથમિક પ્રદર્શન અને અનુવાદ ભાષા પસંદ કરો.',
    },
    'Scam alerts and high-urgency notifications are automatically translated into your active language.': {
      'hi': 'घोटाले के अलर्ट और उच्च-महत्वपूर्ण सूचनाएं आपकी सक्रिय भाषा में स्वचालित रूप से अनुवादित होती हैं।',
      'gu': 'સ્કેમ ચેતવણીઓ અને ઉચ્ચ-તાકીદની સૂચનાઓ તમારી સક્રિય ભાષામાં આપમેળે અનુવાદિત થાય છે.',
    },
    'English (Default)': {'hi': 'अंग्रेज़ी (डिफ़ॉल्ट)', 'gu': 'અંગ્રેજી (ડિફૉલ્ટ)'},
    'Hindi • हिंदी भाषा': {'hi': 'हिन्दी • हिंदी भाषा', 'gu': 'હિન્દી • હિંદી ભાષા'},
    'Gujarati • ગુજરાતી ભાષા': {'hi': 'गुजराती • ગુજરાતી ભાષા', 'gu': 'ગુજરાતી • ગુજરાતી ભાષા'},

    // ── Voice Assistant Screen ──
    'Voice Assistant': {'hi': 'वॉइस असिस्टेंट', 'gu': 'વોઇસ આસિસ્ટન્ટ'},
    'Enable Voice Assistant': {'hi': 'वॉइस असिस्टेंट सक्षम करें', 'gu': 'વોઇસ આસિસ્ટન્ટ સક્ષમ કરો'},
    'Voice Type': {'hi': 'वॉइस प्रकार', 'gu': 'અવાજનો પ્રકાર'},
    'Calm Female': {'hi': 'शांत महिला', 'gu': 'શાંત મહિલા'},
    'Soothing and clear': {'hi': 'सुखदायक और स्पष्ट', 'gu': 'શાંત અને સ્પષ્ટ'},
    'Voice Speed (Reading Pace)': {'hi': 'बोलने की गति (पढ़ने की गति)', 'gu': 'વાંચવાની ઝડપ (બોલવાની ગતિ)'},
    'Slower': {'hi': 'धीमी', 'gu': 'ધીમી'},
    'Faster': {'hi': 'तेज़', 'gu': 'ઝડપી'},
    'Save Voice Settings': {'hi': 'वॉइस सेटिंग्स सहेजें', 'gu': 'વોઇસ સેટિંગ્સ સાચવો'},
    'Voice settings saved': {'hi': 'वॉइस सेटिंग्स सहेज ली गईं', 'gu': 'વોઇસ સેટિંગ્સ સાચવવામાં આવી'},

    // ── Help & Support / Mini Chat ──
    'Help & Support': {'hi': 'सहायता और समर्थन', 'gu': 'સહાય અને સહાયતા'},
    'Help & Emergency Support': {'hi': 'सहायता और आपातकालीन समर्थन', 'gu': 'સહાય અને કટોકટી સપોર્ટ'},
    'Hello there.': {'hi': 'नमस्ते।', 'gu': 'નમસ્તે.'},
    'How can I help protect your sanctuary today?': {
      'hi': 'आज मैं आपकी सुरक्षा में कैसे मदद कर सकता हूँ?',
      'gu': 'આજે હું તમારી સુરક્ષામાં કેવી રીતે મદદ કરી શકું?',
    },
    'Type a message...': {'hi': 'संदेश लिखें...', 'gu': 'સંદેશ લખો...'},
    'Ask SafeSenior AI...': {'hi': 'SafeSenior AI से पूछें...', 'gu': 'SafeSenior AI ને પૂછો...'},
    'Guardian Assistant': {'hi': 'अभिभावक सहायक', 'gu': 'ગાર્ડિયન આસિસ્ટન્ટ'},
    'Thinking...': {'hi': 'सोच रहा हूँ...', 'gu': 'વિચારી રહ્યો છું...'},
    'Listening...': {'hi': 'सुन रहा हूँ...', 'gu': 'સાંભળી રહ્યો છું...'},

    // ── Settings Screen ──
    'Security Preferences': {'hi': 'सुरक्षा प्राथमिकताएं', 'gu': 'સુરક્ષા પસંદગીઓ'},
    'Guardian Network': {'hi': 'अभिभावक नेटवर्क', 'gu': 'ગાર્ડિયન નેટવર્ક'},
    'Emergency & Family Contacts': {'hi': 'आपातकालीन और परिवार संपर्क', 'gu': 'કટોકટી અને પારિવારિક સંપર્કો'},
    'Voice Alerts & Reading Pace': {'hi': 'वॉइस अलर्ट और पढ़ने की गति', 'gu': 'વોઇસ એલર્ટ્સ અને વાંચવાની ઝડપ'},
    'English, Hindi, Gujarati': {'hi': 'अंग्रेज़ी, हिन्दी, गुजराती', 'gu': 'અંગ્રેજી, હિન્દી, ગુજરાતી'},
    'App Updates & Threat Engine': {'hi': 'ऐप अपडेट और थ्रेट इंजन', 'gu': 'એપ અપડેટ્સ અને થ્રેટ એન્જિન'},
    '24/7 Helpline & FAQs': {'hi': '24/7 हेल्पलाइन और अक्सर पूछे जाने वाले सवाल', 'gu': '24/7 હેલ્પલાઇન અને પ્રશ્નોત્તરી'},
    'Preferences': {'hi': 'प्राथमिकताएं', 'gu': 'પસંદગીઓ'},
    'Dark Mode': {'hi': 'डार्क मोड', 'gu': 'ડાર્ક મોડ'},
    'Comfort reading at night': {'hi': 'रात में पढ़ने के लिए आरामदायक', 'gu': 'રાત્રે વાંચવા માટે આરામદાયક'},
    'Account & Family': {'hi': 'खाता और परिवार', 'gu': 'ખાતું અને પરિવાર'},

    // ── Home Screen ──
    'All': {'hi': 'सभी', 'gu': 'બધા'},
    'Calls': {'hi': 'कॉल', 'gu': 'કોલ્સ'},
    'Messages': {'hi': 'संदेश', 'gu': 'સંદેશાઓ'},
    'WhatsApp': {'hi': 'व्हाट्सएप', 'gu': 'વોટ્સએપ'},
    'Email': {'hi': 'ईमेल', 'gu': 'ઇમેઇલ'},
    'Protection Active': {'hi': 'सुरक्षा सक्रिय', 'gu': 'સુરક્ષા સક્રિય'},
    'All communications monitored safely': {
      'hi': 'सभी संचार सुरक्षित रूप से मॉनिटर किए जा रहे हैं',
      'gu': 'બધા સંચાર સુરક્ષિત રીતે મોનિટર કરવામાં આવી રહ્યા છે',
    },
    'EMERGENCY SOS': {'hi': 'आपातकालीन SOS', 'gu': 'કટોકટી SOS'},
    'HELP ME!': {'hi': 'मेरी मदद करो!', 'gu': 'મને મદદ કરો!'},
    'Recent Alerts': {'hi': 'हालिया अलर्ट', 'gu': 'તાજેતરના એલર્ટ'},
    'Family Circle': {'hi': 'परिवार का दायरा', 'gu': 'પરિવાર સર્કલ'},
    'View All': {'hi': 'सभी देखें', 'gu': 'બધા જુઓ'},
    'Live Security Status': {'hi': 'लाइव सुरक्षा स्थिति', 'gu': 'લાઇવ સુરક્ષા સ્થિતિ'},
    'Daily Safety Tip': {'hi': 'दैनिक सुरक्षा सुझाव', 'gu': 'દૈનિક સુરક્ષા સલાહ'},
    'Threats Blocked': {'hi': 'अवरुद्ध खतरे', 'gu': 'રોકેલા જોખમો'},
    'Scanned Messages': {'hi': 'स्कैन किए गए संदेश', 'gu': 'સ્કેન કરેલા સંદેશાઓ'},
    'Calls Protected': {'hi': 'सुरक्षित कॉल', 'gu': 'સુરક્ષિત કોલ્સ'},
    'Device Protected': {'hi': 'उपकरण सुरक्षित है', 'gu': 'ડિવાઇસ સુરક્ષિત છે'},
    'No Recent Threats': {'hi': 'कोई हालिया खतरा नहीं', 'gu': 'કોઈ તાજેતરનું જોખમ નથી'},

    // ── Guardian & Contacts ──
    'Guardian Contacts': {'hi': 'अभिभावक संपर्क', 'gu': 'ગાર્ડિયન સંપર્કો'},
    'Add Guardian': {'hi': 'अभिभावक जोड़ें', 'gu': 'ગાર્ડિયન ઉમેરો'},
    'Primary Contact': {'hi': 'प्राथमिक संपर्क', 'gu': 'પ્રાથમિક સંપર્ક'},
    'Secondary Contact': {'hi': 'द्वितीयक संपर्क', 'gu': 'દ્વિતીય સંપર્ક'},
    'Call Guardian': {'hi': 'अभिभावक को कॉल करें', 'gu': 'ગાર્ડિયનને કૉલ કરો'},
    'Message Guardian': {'hi': 'अभिभावक को संदेश भेजें', 'gu': 'ગાર્ડિયનને સંદેશ મોકલો'},
    'Send Emergency Alert': {'hi': 'आपातकालीन अलर्ट भेजें', 'gu': 'કટોકટી એલર્ટ મોકલો'},

    // ── Security & Alerts ──
    'Security Status': {'hi': 'सुरक्षा स्थिति', 'gu': 'સુરક્ષા સ્થિતિ'},
    'Safe & Protected': {'hi': 'सुरक्षित और संरक्षित', 'gu': 'સુરક્ષિત અને રક્ષિત'},
    'Stop! Do Not Share': {'hi': 'रुकें! साझा न करें', 'gu': 'રોકાઓ! શેર કરશો નહીં'},
    'STOP! DO NOT SHARE!': {'hi': 'रुकें! साझा न करें!', 'gu': 'રોકાઓ! શેર કરશો નહીં!'},
    'Never share this code with anyone': {
      'hi': 'यह कोड कभी किसी के साथ साझा न करें',
      'gu': 'આ કોડ ક્યારેય કોઈની સાથે શેર કરશો નહીં',
    },
    'I Did NOT Share This Code': {'hi': 'मैंने यह कोड साझा नहीं किया', 'gu': 'મેં આ કોડ શેર કર્યો નથી'},
    'I Understand - Close': {'hi': 'मैं समझता हूँ - बंद करें', 'gu': 'હું સમજું છું - બંધ કરો'},

    // ── Additional Hubs & UI ──
    'Settings & Preferences': {'hi': 'सेटिंग्स और प्राथमिकताएं', 'gu': 'સેટિંગ્સ અને પસંદગીઓ'},
    'Alerts': {'hi': 'अलर्ट', 'gu': 'એલર્ટ'},
    'Quizzes': {'hi': 'क्विज़', 'gu': 'ક્વિઝ'},
    'Tips': {'hi': 'टिप्स', 'gu': 'ટિપ્સ'},
    'DAILY SAFETY QUIZ': {'hi': 'दैनिक सुरक्षा क्विज़', 'gu': 'દૈનિક સુરક્ષા ક્વિઝ'},
    'HIGH RISK THREAT ALERT': {'hi': 'उच्च जोखिम खतरा अलर्ट', 'gu': 'ઉચ્ચ જોખમ થ્રેટ એલર્ટ'},
    'Test Fake OTP': {'hi': 'नकली OTP टेस्ट करें', 'gu': 'નકલી OTP ટેસ્ટ કરો'},
    'Test Fake Call': {'hi': 'नकली कॉल टेस्ट करें', 'gu': 'નકલી કૉલ ટેસ્ટ કરો'},
    'Scam Pattern Library': {'hi': 'स्कैम पैटर्न लाइब्रेरी', 'gu': 'સ્કેમ પેટર્ન લાયબ્રેરી'},
    'Explore 50+ verified fraud tactics & red flags.': {
      'hi': '50+ सत्यापित धोखाधड़ी रणनीति और संकेत देखें।',
      'gu': '50+ ચકાસાયેલ છેતરપિંડી યુક્તિઓ અને સંકેતો જુઓ.',
    },
    'Shield Center': {'hi': 'सुरक्षा केंद्र', 'gu': 'સુરક્ષા કેન્દ્ર'},
    '100% Safe': {'hi': '100% सुरक्षित', 'gu': '100% સુરક્ષિત'},
    'SMS Scam & OTP Shield': {'hi': 'SMS स्कैम और OTP शील्ड', 'gu': 'SMS સ્કેમ અને OTP શીલ્ડ'},
    'In-Call Scam Detection': {'hi': 'कॉल के दौरान स्कैम पहचान', 'gu': 'કૉલ દરમિયાન સ્કેમ ડિટેક્શન'},
    'Voice Assistant Guidance': {'hi': 'वॉइस असिस्टेंट मार्गदर्शन', 'gu': 'વોઇસ આસિસ્ટન્ટ માર્ગદર્શન'},
    'Scam Library': {'hi': 'स्कैम लाइब्रेरी', 'gu': 'સ્કેમ લાયબ્રેરી'},
    'Weekly Report': {'hi': 'साप्ताहिक रिपोर्ट', 'gu': 'સાપ્તાહિક અહેવાલ'},
    'Achievements': {'hi': 'उपलब्धियां', 'gu': 'સિદ્ધિઓ'},
    'Safety Checklist': {'hi': 'सुरक्षा चेकलिस्ट', 'gu': 'સુરક્ષા ચેકલિસ્ટ'},
    'APP & SECURITY': {'hi': 'ऐप और सुरक्षा', 'gu': 'એપ અને સુરક્ષા'},
    'FAMILY & PROTECTION HUBS': {'hi': 'परिवार और सुरक्षा केंद्र', 'gu': 'પરિવાર અને સુરક્ષા કેન્દ્રો'},
    'Reset Security PIN': {'hi': 'सुरक्षा पिन रीसेट करें', 'gu': 'સુરક્ષા પિન રીસેટ કરો'},
    'Update your 4-digit master PIN': {'hi': 'अपना 4-अंकीय मास्टर पिन अपडेट करें', 'gu': 'તમારો 4-અંકનો માસ્ટર પિન અપડેટ કરો'},

    // ── Location Alert & Leaflet Map ──
    'LOCATION ALERT': {'hi': 'लोकेशन अलर्ट', 'gu': 'લોકેશન એલર્ટ'},
    '⚠️ LOCATION ALERT': {'hi': '⚠️ लोकेशन अलर्ट', 'gu': '⚠️ લોકેશન એલર્ટ'},
    'Unusual Location Pattern': {'hi': 'असामान्य स्थान पैटर्न', 'gu': 'અસામાન્ય લોકેશન પેટર્ન'},
    'Unusual Location Alert': {'hi': 'असामान्य स्थान चेतावनी', 'gu': 'અસામાન્ય લોકેશન ચેતવણી'},
    'Detected at': {'hi': 'समय', 'gu': 'શોધાયેલ સમય'},
    'Current Location': {'hi': 'वर्तमान स्थान', 'gu': 'વર્તમાન સ્થળ'},
    'Your Home Area': {'hi': 'आपका घर क्षेत्र', 'gu': 'તમારો ઘરનો વિસ્તાર'},
    'Unusual — not your typical area': {'hi': 'असामान्य — आपका सामान्य क्षेत्र नहीं', 'gu': 'અસામાન્ય — તમારો સામાન્ય વિસ્તાર નથી'},
    'Your usual location': {'hi': 'आपका सामान्य निवास स्थान', 'gu': 'તમારું સામાન્ય રહેઠાણ'},
    'Location Map': {'hi': 'स्थान मानचित्र', 'gu': 'સ્થળ નકશો'},
    'Current': {'hi': 'वर्तमान', 'gu': 'વર્તમાન'},
    'Home': {'hi': 'घर', 'gu': 'ઘર'},
    "I'm Safe — Went Out Intentionally": {'hi': 'मैं सुरक्षित हूँ — खुद बाहर गया था', 'gu': 'હું સુરક્ષિત છું — જાણીજોઈને બહાર ગયો હતો'},
    'Call Guardian': {'hi': 'अभिभावक को कॉल करें', 'gu': 'ગાર્ડિયનને કૉલ કરો'},
    'SOS': {'hi': 'एसओएस', 'gu': 'કટોકટી SOS'},
    'Share Current Location with Family': {'hi': 'परिवार के साथ वर्तमान लोकेशन साझा करें', 'gu': 'પરિવાર સાથે વર્તમાન સ્થળ શેર કરો'},
    'What should you do?': {'hi': 'आपको क्या करना चाहिए?', 'gu': 'તમારે શું કરવું જોઈએ?'},
    "If you went out intentionally, you're safe. Just confirm below.": {
      'hi': 'यदि आप जानबूझकर बाहर गए हैं, तो आप सुरक्षित हैं। बस नीचे पुष्टि करें।',
      'gu': 'જો તમે જાણીજોઈને બહાર ગયા હોવ, તો તમે સુરક્ષિત છો. ફક્ત નીચે પુષ્ટિ કરો.',
    },
    "If you're confused or feel unsafe, call a guardian immediately.": {
      'hi': 'यदि आप भ्रमित हैं या असुरक्षित महसूस कर रहे हैं, तो तुरंत अभिभावक को कॉल करें।',
      'gu': 'જો તમે મૂંઝવણમાં હોવ અથવા અસુરક્ષિત અનુભવતા હોવ, તો તરત જ ગાર્ડિયનને કૉલ કરો.',
    },
    'If someone forced you to go somewhere, press the SOS button.': {
      'hi': 'यदि किसी ने आपको जबरन कहीं ले जाने की कोशिश की, तो SOS बटन दबाएं।',
      'gu': 'જો કોઈએ તમને ક્યાંય જવાની ફરજ પાડી હોય, તો તરત જ SOS બટન દબાવો.',
    },
    'Fit Both': {'hi': 'दोनों देखें', 'gu': 'બંને જુઓ'},
    'Open in Maps': {'hi': 'मैप में खोलें', 'gu': 'નકશામાં ખોલો'},
    'Distance from home': {'hi': 'घर से दूरी', 'gu': 'ઘરથી અંતર'},
    'SafeSenior Location Notice': {'hi': 'SafeSenior लोकेशन सूचना', 'gu': 'SafeSenior લોકેશન નોટિસ'},
    'Simulate / Change Location': {'hi': 'स्थान बदलें / सिमुलेट करें', 'gu': 'સ્થળ બદલો / સિમ્યુલેટ કરો'},
  };

  /// Translate a string given the language code ('en', 'hi', 'gu')
  static String tr(String text, String langCode) {
    if (langCode == 'en' || langCode.isEmpty) {
      return text;
    }
    final match = _translations[text];
    if (match != null && match.containsKey(langCode)) {
      return match[langCode]!;
    }
    // Also try case-insensitive or trimmed match
    for (final entry in _translations.entries) {
      if (entry.key.toLowerCase().trim() == text.toLowerCase().trim()) {
        final val = entry.value[langCode];
        if (val != null) return val;
      }
    }
    return text;
  }
}

/// Extension for easy translation anywhere in BuildContext
extension TranslationContextExt on BuildContext {
  String tr(String text) {
    try {
      final code = Localizations.localeOf(this).languageCode;
      return AppTranslations.tr(text, code);
    } catch (_) {
      return text;
    }
  }
}

/// Extension on String to translate with language code
extension StringTranslateExt on String {
  String trCode(String langCode) => AppTranslations.tr(this, langCode);
}
