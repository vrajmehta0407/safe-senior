import 'dart:convert';
import 'package:dio/dio.dart';

/// Service powering the SafeSenior AI Companion & Chatbot.
/// Uses resilient cloud LLM endpoints with an intelligent, multi-language
/// contextual offline fallback engine for senior citizens.
class OpenRouterService {
  static const String _primaryApiUrl = 'https://text.pollinations.ai/';

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 18),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json, text/plain, */*',
      },
    ),
  );

  /// Sends a message along with previous chat history to the AI agent
  static Future<String> sendMessage({
    required String userMessage,
    List<Map<String, String>> history = const [],
    String languageCode = 'en',
    String? guardianName,
    String? userName,
  }) async {
    final cleanInput = userMessage.trim();
    if (cleanInput.isEmpty) {
      return _getIntelligentFallback(cleanInput, languageCode, guardianName, userName);
    }

    String langInstruction = 'Respond in clear, warm, simple English.';
    if (languageCode == 'hi') {
      langInstruction = 'Respond in simple, respectful, and reassuring Hindi (हिन्दी). Avoid complex terms.';
    } else if (languageCode == 'gu') {
      langInstruction = 'Respond in simple, respectful, and reassuring Gujarati (ગુજરાતી). Avoid complex terms.';
    }

    final systemPrompt = '''
You are SafeSenior AI Guardian, a caring, reassuring, and protective digital assistant designed specifically for senior citizens and their family guardians.
The senior user's name is ${userName ?? 'Senior'}. Their primary guardian contact is ${guardianName ?? 'Family Guardian'}.
Your duties:
1. Explain scam messages, phishing SMS, suspicious bank calls, OTP safety, digital arrest scams, and digital security in plain, calm terms.
2. Reassure the senior that they are safe and guided.
3. Advise them NEVER to share OTPs, bank passwords, or remote desktop screen access (like AnyDesk or TeamViewer).
4. If they suspect danger, blackmail, or a medical emergency, remind them to press the Emergency SOS button in SafeSenior or call the 1930 Cyber Helpline.
5. Keep explanations concise (2 to 4 sentences usually), clear, warm, and free of difficult computer jargon.
$langInstruction
''';

    // ── Attempt 1: Cloud AI Generation (POST) ──
    try {
      final List<Map<String, String>> apiMessages = [
        {'role': 'system', 'content': systemPrompt},
      ];

      // Add recent history for conversational continuity
      for (final msg in history.take(6)) {
        final role = (msg['sender'] == 'user' || msg['isUser'] == 'true' || msg['role'] == 'user')
            ? 'user'
            : 'assistant';
        final content = msg['text'] ?? msg['content'] ?? '';
        if (content.isNotEmpty) {
          apiMessages.add({'role': role, 'content': content});
        }
      }

      apiMessages.add({'role': 'user', 'content': cleanInput});

      final response = await _dio.post(
        _primaryApiUrl,
        data: {
          'messages': apiMessages,
          'model': 'openai',
          'seed': 42,
          'jsonMode': false,
        },
        options: Options(responseType: ResponseType.plain),
      );

      if (response.statusCode == 200 && response.data != null) {
        final raw = response.data.toString().trim();
        if (raw.isNotEmpty) {
          final parsed = _extractContent(raw);
          if (parsed != null && parsed.isNotEmpty) {
            return parsed;
          }
        }
      }
    } catch (_) {
      // Fall through to Attempt 2
    }

    // ── Attempt 2: Cloud AI Fallback (GET) ──
    try {
      final promptQuery = '$systemPrompt\n\nUser Question: $cleanInput';
      final encodedUrl = '$_primaryApiUrl${Uri.encodeComponent(promptQuery)}?model=openai';

      final getResponse = await _dio.get(
        encodedUrl,
        options: Options(responseType: ResponseType.plain),
      );

      if (getResponse.statusCode == 200 && getResponse.data != null) {
        final raw = getResponse.data.toString().trim();
        if (raw.isNotEmpty) {
          final parsed = _extractContent(raw);
          if (parsed != null && parsed.isNotEmpty) {
            return parsed;
          }
        }
      }
    } catch (_) {
      // Fall through to Intelligent Knowledge Engine
    }

    // ── Attempt 3: Context-Aware Senior Defense Knowledge Engine (Offline/Reliable) ──
    return _getIntelligentFallback(cleanInput, languageCode, guardianName, userName);
  }

  /// Parses both plain text responses and JSON structures if returned by provider
  static String? _extractContent(String raw) {
    if (raw.startsWith('{') && raw.endsWith('}')) {
      try {
        final map = json.decode(raw);
        if (map is Map) {
          final choices = map['choices'];
          if (choices is List && choices.isNotEmpty) {
            final content = choices[0]?['message']?['content'];
            if (content != null && content.toString().trim().isNotEmpty) {
              return content.toString().trim();
            }
          }
          final fallbackContent = map['content'] ?? map['response'] ?? map['text'];
          if (fallbackContent != null && fallbackContent.toString().trim().isNotEmpty) {
            return fallbackContent.toString().trim();
          }
        }
      } catch (_) {
        // If JSON parsing fails, treat as raw plain text
      }
    }
    return raw.trim();
  }

  /// Comprehensive Context-Aware Senior Safety Knowledge Engine.
  /// Categorizes questions so the senior never gets a repetitive generic answer.
  static String _getIntelligentFallback(
    String query,
    String lang,
    String? guardianName,
    String? userName,
  ) {
    final q = query.toLowerCase();
    final gName = guardianName ?? 'your guardian';

    // 1. GREETINGS & INTRODUCTIONS
    if (q.contains('hello') ||
        q.contains('hi') ||
        q.contains('hey') ||
        q.contains('namaste') ||
        q.contains('kem cho') ||
        q.contains('नमस्ते') ||
        q.contains('કેમ છો') ||
        q.contains('who are you') ||
        q.contains('who r u') ||
        q.contains('कौन हो') ||
        q.contains('કોણ છો')) {
      if (lang == 'hi') {
        return 'नमस्ते ${userName ?? ''}! मैं आपका SafeSenior AI सुरक्षा सहायक हूँ। मैं आपको बैंक फ्रॉड, संदिग्ध कॉल, मैसेज और ऐप के उपयोग में मदद करने के लिए यहाँ हूँ। आप मुझसे कुछ भी पूछ सकते हैं।';
      } else if (lang == 'gu') {
        return 'નમસ્તે ${userName ?? ''}! હું તમારો SafeSenior AI સુરક્ષા સહાયક છું. શંકાસ્પદ કૉલ્સ, બેંક મેસેજ, OTP સુરક્ષા અને એપના ઉપયોગ વિશે તમે મને કંઈ પણ પૂછી શકો છો.';
      }
      return 'Hello ${userName ?? 'there'}! I am your SafeSenior AI Guardian Companion. Ask me anything about suspicious phone calls, unknown SMS, OTP safety, or how to stay safe online.';
    }

    // 2. OTP & PIN SECURITY
    if (q.contains('otp') ||
        q.contains('pin') ||
        q.contains('password') ||
        q.contains('code') ||
        q.contains('ओटीपी') ||
        q.contains('पासवर्ड') ||
        q.contains('पिन') ||
        q.contains('પાસવર્ડ')) {
      if (lang == 'hi') {
        return 'सावधान! अपना OTP या पासवर्ड कभी किसी के साथ साझा न करें। बैंक या पुलिस कभी भी फोन पर OTP नहीं मांगते। यदि किसी ने OTP पूछा है, तो तुरंत फोन काट दें और अपने अभिभावक ($gName) को सूचित करें।';
      } else if (lang == 'gu') {
        return 'સાવધાન! તમારો OTP અથવા PIN ક્યારેય કોઈને આપશો નહીં. કોઈ પણ બેંક કે સરકારી અધિકારી ક્યારેય ફોન પર OTP માંગતા નથી. જો કોઈ માંગે તો તરત જ ફોન કાપી નાખો અને $gName ને જણાવો.';
      }
      return 'Stop! Never share your OTP or banking PIN with anyone over the phone. Real bank managers and police officers will NEVER ask for your OTP. If someone is asking for it, hang up immediately.';
    }

    // 3. DIGITAL ARREST / POLICE / CBI / CUSTOMS SCAMS
    if (q.contains('police') ||
        q.contains('arrest') ||
        q.contains('cbi') ||
        q.contains('custom') ||
        q.contains('drugs') ||
        q.contains('parcel') ||
        q.contains('money laundering') ||
        q.contains('court') ||
        q.contains('digital arrest') ||
        q.contains('वारंट') ||
        q.contains('पुलिस') ||
        q.contains('કસ્ટમ્સ') ||
        q.contains('પોલીસ')) {
      if (lang == 'hi') {
        return 'यह 100% फर्जी ‘डिजिटल अरेस्ट’ स्कैम है! भारतीय कानून में वीडियो कॉल या व्हाट्सएप पर अरेस्ट करने का कोई नियम नहीं है। डरे नहीं, तुरंत कॉल काटें और 1930 साइबर हेल्पलाइन पर रिपोर्ट करें।';
      } else if (lang == 'gu') {
        return 'આ સંપૂર્ણપણે ‘ડિજિટલ અરેસ્ટ’ સ્કેમ છે! પોલીસ કે સીબીઆઇ ક્યારેય વોટ્સએપ કે વીડિયો કૉલ પર ધરપકડ કરતી નથી. જરાય ડરશો નહીં, તરત ફોન કાપી 1930 સાયબર હેલ્પલાઇન પર કૉલ કરો.';
      }
      return 'Warning! This is a fake "Digital Arrest" scam. Police, CBI, and Customs NEVER interrogate or arrest citizens over WhatsApp video calls. Do not pay any money. Disconnect immediately and call 1930.';
    }

    // 4. BANKING & ACCOUNT SUSPENSION / KYC EXPIRED
    if (q.contains('bank') ||
        q.contains('sbi') ||
        q.contains('hdfc') ||
        q.contains('icici') ||
        q.contains('kyc') ||
        q.contains('pan') ||
        q.contains('blocked') ||
        q.contains('freeze') ||
        q.contains('suspend') ||
        q.contains('खाता') ||
        q.contains('बैंक') ||
        q.contains('બેંક') ||
        q.contains('કેવાયસી')) {
      if (lang == 'hi') {
        return 'बैंक खाते या KYC ब्लॉक होने का संदेश आम तौर पर फर्जी होता है। SMS में दिए गए किसी भी लिंक पर क्लिक न करें। केवल अपनी नजदीकी बैंक शाखा में जाएं या पासबुक पर दिए आधिकारिक नंबर पर बात करें।';
      } else if (lang == 'gu') {
        return 'બેંક ખાતું અથવા KYC બંધ થવાનો SMS મોટાભાગે છેતરપિંડી હોય છે. મેસેજમાં આપેલી લિંક પર ક્લિક ન કરશો. હંમેશા તમારી બેંક શાખાની રૂબરૂ મુલાકાત લો અથવા પાસબુક પરના નંબર પર કૉલ કરો.';
      }
      return 'Bank account suspension and KYC expiration SMS are almost always fraudulent phishing attempts. Never click links in messages. Visit your local bank branch directly or call the number on the back of your card.';
    }

    // 5. ELECTRICITY BILL / POWER CUT SCAMS
    if (q.contains('electricity') ||
        q.contains('power') ||
        q.contains('bill') ||
        q.contains('light') ||
        q.contains('bijli') ||
        q.contains('बिजली') ||
        q.contains('बिल') ||
        q.contains('વીજળી') ||
        q.contains('બિલ')) {
      if (lang == 'hi') {
        return 'बिजली काटने की धमकी देने वाले SMS फर्जी होते हैं। बिजली विभाग किसी निजी मोबाइल नंबर से कॉल करने को नहीं कहता। SMS में दिए नंबर पर कॉल न करें और न ही कोई बिल पेमेंट ऐप डाउनलोड करें।';
      } else if (lang == 'gu') {
        return 'વીજળી કનેક્શન કાપી નાખવાનો SMS ફેક સ્કેમ છે. વીજ કંપની ક્યારેય અંગત મોબાઈલ નંબર પરથી આવા મેસેજ મોકલતી નથી. મેસેજના નંબર પર કૉલ ન કરશો.';
      }
      return 'Electricity disconnection SMS claiming your power will be cut tonight are well-known scams. Electricity boards never send SMS from personal mobile numbers asking you to call an officer.';
    }

    // 6. SCREEN SHARING / REMOTE ACCESS (AnyDesk, TeamViewer, APK)
    if (q.contains('anydesk') ||
        q.contains('teamviewer') ||
        q.contains('quicksupport') ||
        q.contains('rustdesk') ||
        q.contains('apk') ||
        q.contains('download') ||
        q.contains('install') ||
        q.contains('screen') ||
        q.contains('ऐप') ||
        q.contains('ડાઉનલોડ')) {
      if (lang == 'hi') {
        return 'खतरा! अनजान व्यक्ति के कहने पर AnyDesk, TeamViewer या कोई APK ऐप कभी डाउनलोड न करें। इससे वे आपके पूरे फोन और बैंक खातों पर कब्जा कर सकते हैं। तुरंत ऐप अनइंस्टॉल करें।';
      } else if (lang == 'gu') {
        return 'ખતરો! કોઈ અજાણ્યા વ્યક્તિના કહેવાથી AnyDesk, TeamViewer કે કોઈ APK એપ ડાઉનલોડ ન કરશો. આ એપથી સ્કેમર તમારા ફોન અને બેંક એકાઉન્ટને નિયંત્રિત કરી શકે છે.';
      }
      return 'Danger! Never download AnyDesk, TeamViewer, QuickSupport, or unknown APK files requested by a caller. These screen-sharing apps give fraudsters complete remote control over your bank accounts.';
    }

    // 7. LOTTERY / CASH PRIZES / KBC REWARDS
    if (q.contains('lottery') ||
        q.contains('prize') ||
        q.contains('kbc') ||
        q.contains('won') ||
        q.contains('reward') ||
        q.contains('lucky') ||
        q.contains('gift') ||
        q.contains('लॉटरी') ||
        q.contains('इनाम') ||
        q.contains('લોટરી')) {
      if (lang == 'hi') {
        return 'यह लॉटरी फर्जी है! अगर आपने कोई टिकट नहीं खरीदा, तो आप कोई इनाम नहीं जीत सकते। इनाम पाने के नाम पर कभी कोई ‘प्रोसेसिंग फीस’ या ‘टैक्स’ न भेजें। ऐसे मैसेज डिलीट कर दें।';
      } else if (lang == 'gu') {
        return 'આ સંપૂર્ણ ફેક લૉટરી સ્કેમ છે! જો તમે કોઈ ટિકિટ ખરીદી જ નથી, તો ઇનામ મળી શકે નહીં. ઇનામ મેળવવા માટે ક્યારેય કોઈ ‘ટેક્સ’ કે ‘પ્રોસેસિંગ ફી’ ચૂકવશો નહીં.';
      }
      return 'This is a 100% fake lottery scam. You cannot win a prize or contest you never entered. Scammers will ask for an "advance tax" or "processing fee"—never send any money.';
    }

    // 8. FAMILY & CHILD EMERGENCY / ACCIDENT / BAIL
    if (q.contains('son') ||
        q.contains('daughter') ||
        q.contains('grandson') ||
        q.contains('accident') ||
        q.contains('hospital') ||
        q.contains('bail') ||
        q.contains('money') ||
        q.contains('बेटा') ||
        q.contains('बेटी') ||
        q.contains('દિકરો') ||
        q.contains('દિકરી') ||
        q.contains('અકસ્માત')) {
      if (lang == 'hi') {
        return 'शांत रहें। स्कैमर्स आवाज बदलकर परिवार के सदस्य के संकट का नाटक करते हैं। तुरंत फोन काटें और अपने परिवार ($gName) के असली नंबर पर फोन करके सच्चाई जानें। जल्दबाजी में पैसे न भेजें।';
      } else if (lang == 'gu') {
        return 'શાંત રહો. સ્કેમર્સ AI વડે અવાજ બદલીને પરિવારના સભ્યના અકસ્માતનું ખોટું નાટક રચે છે. તરત ફોન કાપો અને $gName ના જાણીતા નંબર પર કૉલ કરીને ખરાઈ કરો.';
      }
      return 'Stay calm. Scammers often use voice cloning or impersonation claiming your family member is in an accident or arrested. Hang up immediately and call them directly on their known phone number or contact $gName.';
    }

    // 9. SOS & EMERGENCY BUTTON EXPLANATION
    if (q.contains('sos') ||
        q.contains('emergency') ||
        q.contains('help') ||
        q.contains('helpline') ||
        q.contains('1930') ||
        q.contains('14567') ||
        q.contains('आपात') ||
        q.contains('मदद') ||
        q.contains('કટોકટી')) {
      if (lang == 'hi') {
        return 'SafeSenior में लाल रंग का SOS बटन दबाते ही आपके अभिभावक ($gName) को तुरंत लाइव लोकेशन के साथ आपातकालीन अलर्ट भेजा जाता है। इसके अलावा साइबर धोखाधड़ी के लिए 1930 और बुजुर्ग सहायता के लिए 14567 डायल करें।';
      } else if (lang == 'gu') {
        return 'SafeSenior માં લાલ SOS બટન દબાવવાથી તમારા ગાર્ડિયન ($gName) ને તાત્કાલિક લાઇવ લોકેશન સાથે એલર્ટ મોકલવામાં આવે છે. સાયબર ફ્રોડ માટે 1930 અને વરિષ્ઠ નાગરિકો માટે 14567 ડાયલ કરી શકો છો.';
      }
      return 'Pressing the red SOS button immediately sends an emergency alert with your live GPS location to $gName. For national cyber fraud assistance, call 1930, or call 14567 for Elder Line support.';
    }

    // 10. APP FEATURES & HOW TO USE
    if (q.contains('how to use') ||
        q.contains('feature') ||
        q.contains('scam library') ||
        q.contains('quiz') ||
        q.contains('shield') ||
        q.contains('उपयोग') ||
        q.contains('फीचर') ||
        q.contains('ઉપયોગ')) {
      if (lang == 'hi') {
        return 'SafeSenior आपके फोन पर आने वाले SMS और कॉल की सुरक्षा करता है। आप होम स्क्रीन पर जाकर सुरक्षा क्विज़ खेल सकते हैं, स्कैम लाइब्रेरी देख सकते हैं, और संदिग्ध संदेशों को सीधे अभिभावक से वेरिफाई करवा सकते हैं।';
      } else if (lang == 'gu') {
        return 'SafeSenior તમારા ફોનમાં SMS અને કૉલની રક્ષા કરે છે. તમે હોમ સ્ક્રીન પર ક્વિઝ રમી શકો છો, સ્કેમ લાઇબ્રેરી જોઈ શકો છો અને શંકાસ્પદ મેસેજ ગાર્ડિયન સાથે શેર કરી શકો છો.';
      }
      return 'SafeSenior automatically protects you against scam SMS and dangerous caller patterns. You can take safety quizzes, explore the Scam Library, and alert your family circle with one tap.';
    }

    // 11. GENERAL REASSURING SENIOR GUARDIAN ANSWER
    if (lang == 'hi') {
      return 'मैं आपकी सुरक्षा के लिए यहाँ हूँ। किसी भी संदिग्ध संदेश, अज्ञात कॉल या लिंक पर भरोसा न करें। यदि कोई आपसे पैसे या निजी जानकारी मांगे, तो पहले अपने अभिभावक ($gName) से बात करें। आपात स्थिति में लाल SOS बटन दबाएँ।';
    } else if (lang == 'gu') {
      return 'હું તમારી સુરક્ષા માટે હંમેશા હાજર છું. કોઈ પણ અજાણ્યા કૉલ, મેસેજ કે લિંક પર વિશ્વાસ ન કરશો. કોઈ પૈસા કે માહિતી માંગે તો પહેલા તમારા ગાર્ડિયન ($gName) સાથે વાત કરો. કટોકટીમાં લાલ SOS બટન દબાવો.';
    }
    return 'I am here to guide and protect you. Never share banking passwords or OTP codes with unknown callers. When in doubt, consult $gName or press the red Emergency SOS button in SafeSenior.';
  }
}
