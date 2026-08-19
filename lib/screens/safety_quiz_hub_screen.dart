import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'safety_quiz_screen.dart';
import 'achievements_screen.dart';

class QuizTopic {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String difficulty;
  final int questionCount;
  final int xpReward;
  final IconData icon;
  final Color themeColor;
  final String scenarioPreview;
  final List<QuizQuestion> questions;

  const QuizTopic({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.difficulty,
    required this.questionCount,
    required this.xpReward,
    required this.icon,
    required this.themeColor,
    required this.scenarioPreview,
    required this.questions,
  });
}

class QuizQuestion {
  final String scenario;
  final String? senderName;
  final String? messageContent;
  final bool isSimulatedMessage;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String safetyRule;

  const QuizQuestion({
    required this.scenario,
    this.senderName,
    this.messageContent,
    this.isSimulatedMessage = false,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.safetyRule,
  });
}

final List<QuizTopic> kSafetyQuizTopics = [
  QuizTopic(
    id: 'bank_kyc',
    title: 'Bank KYC & Urgent Account Freeze',
    subtitle: 'Learn to identify fake bank warnings and spoofed SMS headers.',
    category: 'Banking & UPI',
    difficulty: 'Beginner',
    questionCount: 3,
    xpReward: 50,
    icon: Icons.account_balance,
    themeColor: AppTheme.primaryTeal,
    scenarioPreview: 'SMS: "Dear customer, your SBI account will be blocked today. Click sbi-kyc-update.xyz immediately."',
    questions: [
      QuizQuestion(
        scenario: 'You receive an urgent SMS at 8:00 PM claiming your bank account is suspended.',
        senderName: 'VK-SBIINB',
        messageContent: 'URGENT: Your SBI NetBanking is deactivated due to pending PAN update. Update within 2 hours at https://sbi-pan-kyc.top or account will be permanently closed.',
        isSimulatedMessage: true,
        options: [
          'Click the link immediately so you don\'t lose access to your money.',
          'Forward the SMS to family and ask them to click it.',
          'Ignore the link and verify directly via official bank branch or official app.',
          'Reply to the SMS with your PAN and Aadhaar number.',
        ],
        correctIndex: 2,
        explanation: 'Real banks NEVER send short links ending in .top, .xyz or threaten immediate closure within 2 hours.',
        safetyRule: 'Rule: Always open your official banking app directly — never click links in text messages.',
      ),
      QuizQuestion(
        scenario: 'A caller claiming to be "Bank Manager Sharma" calls asking for a 6-digit OTP to unblock your ATM card.',
        senderName: '+91 98250 14820 (Caller ID: SBI Manager)',
        messageContent: 'Sir, I have unblocked your card. Please read out the 6-digit OTP you just received to finalize.',
        isSimulatedMessage: false,
        options: [
          'Read the OTP since the caller is polite and knows your name.',
          'Hang up immediately. Bank staff never ask for OTPs or PINs.',
          'Give only the first 3 digits of the OTP.',
          'Ask him to call your guardian first and give it to them.',
        ],
        correctIndex: 1,
        explanation: 'No bank employee will EVER ask for an OTP, password, or ATM PIN under any circumstance.',
        safetyRule: 'Rule: An OTP is your personal digital signature. Sharing it gives scammers full access to your funds.',
      ),
      QuizQuestion(
        scenario: 'A message arrives on WhatsApp with an APK file named "SBI_Security_Update.apk".',
        senderName: 'State Bank Helpdesk',
        messageContent: 'Please install our new mandatory safety app to prevent unauthorized withdrawals: SBI_Security_Update.apk',
        isSimulatedMessage: true,
        options: [
          'Download and install it to keep your phone protected.',
          'Never install APK files sent via WhatsApp or SMS. Delete it immediately.',
          'Send the APK file to friends so they stay safe too.',
          'Open it on another device first.',
        ],
        correctIndex: 1,
        explanation: 'APK files sent on messaging apps are malware that read your screen, steal passwords, and auto-forward OTPs.',
        safetyRule: 'Rule: Only install apps from Google Play Store or Apple App Store.',
      ),
    ],
  ),
  QuizTopic(
    id: 'grandchild_sos',
    title: 'Grandchild SOS & AI Voice Clones',
    subtitle: 'Recognize synthetic voice calls and frantic family emergency scams.',
    category: 'Family Impersonation',
    difficulty: 'Intermediate',
    questionCount: 3,
    xpReward: 60,
    icon: Icons.record_voice_over,
    themeColor: Color(0xFFFE7356),
    scenarioPreview: 'Late night call sounds like your grandson crying: "Dadi, I got in an accident, don\'t tell mom..."',
    questions: [
      QuizQuestion(
        scenario: 'You receive a frantic call from an unknown number. The voice sounds remarkably like your grandchild, crying and asking for urgent money.',
        senderName: 'Unknown Number (+91 70123 45678)',
        messageContent: 'Voice call: "Grandpa! I was in a minor car accident and police are holding me. Please send ₹30,000 to this UPI ID right now, please don\'t tell dad!"',
        isSimulatedMessage: false,
        options: [
          'Send the money right away through GPay/PhonePe to save them.',
          'Hang up and immediately call your grandchild or their parents on their known saved phone number.',
          'Post about the emergency on Facebook asking for help.',
          'Ask the caller for their credit card details.',
        ],
        correctIndex: 1,
        explanation: 'Scammers use 3-second clips from social media to clone voices with AI. Always verify by hanging up and calling their known number.',
        safetyRule: 'Rule: Always hang up and dial your family member directly on their trusted number saved in your phonebook.',
      ),
      QuizQuestion(
        scenario: 'What is a "Family Safe Word" and how does it protect you from AI voice scams?',
        options: [
          'A secret password agreed upon with your family to prove identity in emergencies.',
          'A word you give to customer support representatives.',
          'Your bank account password.',
          'A voice command to turn off your smartphone.',
        ],
        correctIndex: 0,
        explanation: 'A private secret word known only to close family members immediately exposes AI voice impersonators.',
        safetyRule: 'Rule: Establish a secret family codeword that only you and your trusted family know.',
      ),
      QuizQuestion(
        scenario: 'A WhatsApp message from an unknown number has your daughter\'s profile photo: "Mom, I lost my phone. This is my new number, please pay my college fee now."',
        senderName: '+91 88990 11223',
        messageContent: 'Hi Mum, I dropped my phone in water. Using this temporary number. Urgent: my fee deadline is in 30 mins, please send ₹15,000 to tutor@upi.',
        isSimulatedMessage: true,
        options: [
          'Transfer the fee immediately since the profile photo matches.',
          'Call your daughter on her ORIGINAL number or contact her spouse/workplace to verify.',
          'Delete WhatsApp from your phone.',
          'Ask for her bank account number instead.',
        ],
        correctIndex: 1,
        explanation: 'Profile pictures are publicly accessible and easily copied. Never trust a "new number" without direct voice verification.',
        safetyRule: 'Rule: Photo and name on WhatsApp can be set by anyone. Always verify via another channel.',
      ),
    ],
  ),
  QuizTopic(
    id: 'digital_arrest',
    title: 'Digital Arrest & Police Video Scam',
    subtitle: 'Spot fake CBI, ED, and Mumbai Police video interrogation threats.',
    category: 'Government / Law',
    difficulty: 'Advanced',
    questionCount: 3,
    xpReward: 70,
    icon: Icons.gavel,
    themeColor: Color(0xFFAA361F),
    scenarioPreview: 'Video call from "CBI Officer": "A parcel with drugs was seized under your Aadhaar. You are placed under digital arrest."',
    questions: [
      QuizQuestion(
        scenario: 'You receive a Skype video call from a man in a police uniform sitting in front of a police emblem. He says you are under "Digital Arrest".',
        senderName: 'CBI Cyber Cell Department',
        messageContent: '"A Fedex courier with illegal contraband registered in your name has been seized. You cannot disconnect this call or local police will raid your house."',
        isSimulatedMessage: false,
        options: [
          'Comply with all instructions, stay on video, and transfer your life savings to the "RBI verification account".',
          'Disconnect immediately. "Digital Arrest" is 100% fake — law enforcement does not arrest or try citizens over video calls.',
          'Show your passport and Aadhaar card on camera to clear your name.',
          'Apologize and ask for a discount on the penalty.',
        ],
        correctIndex: 1,
        explanation: 'No law in India permits "Digital Arrest". Real police and courts never conduct legal proceedings or demand money via WhatsApp/Skype video calls.',
        safetyRule: 'Rule: Digital Arrest is a complete scam. Immediately hang up and dial Cyber Crime helpline 1930.',
      ),
      QuizQuestion(
        scenario: 'The caller insists you must transfer your savings to a "Safe Government Escrow Account" for 24 hours while your innocence is verified.',
        options: [
          'Transfer the money because government accounts are always safe.',
          'Refuse and disconnect. Government agencies NEVER ask citizens to transfer money to "clear" their accounts.',
          'Transfer half the money as security.',
          'Ask if you can pay in cash.',
        ],
        correctIndex: 1,
        explanation: 'Any demand to transfer funds to "verify" or "protect" them is the core objective of the fraud.',
        safetyRule: 'Rule: The government never requests money transfers to verify your innocence.',
      ),
      QuizQuestion(
        scenario: 'What is the official National Cyber Crime Helpline number in India?',
        options: [
          '100',
          '108',
          '1930',
          '911',
        ],
        correctIndex: 2,
        explanation: 'Dialing 1930 connects you directly to the National Cyber Crime Reporting Portal to freeze fraudulent transfers.',
        safetyRule: 'Rule: Dial 1930 immediately if you suspect you have shared financial details with a scammer.',
      ),
    ],
  ),
  QuizTopic(
    id: 'tech_support',
    title: 'AnyDesk & Remote Desktop Scams',
    subtitle: 'Prevent scammers from taking remote control of your phone or tablet.',
    category: 'Tech Support',
    difficulty: 'Intermediate',
    questionCount: 3,
    xpReward: 60,
    icon: Icons.phonelink_setup,
    themeColor: Color(0xFF735C00),
    scenarioPreview: 'Caller claiming to be Microsoft/Google: "Your device is infected. Download TeamViewer to remove malware."',
    questions: [
      QuizQuestion(
        scenario: 'A pop-up on your screen sounds a loud siren saying: "Windows Virus Detected! Call Toll-Free 1800-XXX-XXXX immediately."',
        options: [
          'Call the number on the screen right away.',
          'Close the browser tab or restart your browser. Legitimate companies never put phone numbers in pop-ups.',
          'Download whatever tool the pop-up recommends.',
          'Give your credit card number to the voice recording.',
        ],
        correctIndex: 1,
        explanation: 'Browser pop-ups with sirens and phone numbers are fake warnings designed to scare seniors into calling scam boiler rooms.',
        safetyRule: 'Rule: Close the tab. Real operating systems never ask you to call a phone number to fix a virus.',
      ),
      QuizQuestion(
        scenario: 'A "Customer Support Representative" asks you to download "AnyDesk" or "TeamViewer QuickSupport" and read the 9-digit code.',
        options: [
          'Read the code so they can fix your phone.',
          'Refuse and uninstall the app. Giving that code gives them complete remote control of your phone and banking apps.',
          'Give the code only if they promise to be quick.',
          'Ask your neighbor to read the code.',
        ],
        correctIndex: 1,
        explanation: 'Remote support apps allow scammers to view your screen in real time, see your OTPs as they arrive, and transfer funds.',
        safetyRule: 'Rule: Never install AnyDesk, TeamViewer, or RustDesk at the request of an incoming caller.',
      ),
      QuizQuestion(
        scenario: 'You are having trouble with a refund from Swiggy/Amazon. You search Google for "Swiggy Customer Care Number" and call the first result.',
        options: [
          'Trust the number because it was the top Google result.',
          'Be extremely cautious: scammers create fake Google Maps listings with their own numbers. Only use in-app support chat.',
          'Tell the person your UPI PIN when asked.',
          'Share your screen so they can process the refund.',
        ],
        correctIndex: 1,
        explanation: 'Scammers hijack Google search results with fake helpline numbers. Always use official in-app help centers.',
        safetyRule: 'Rule: Never search for customer service phone numbers on Google — use the official app.',
      ),
    ],
  ),
];

class SafetyQuizHubScreen extends StatefulWidget {
  const SafetyQuizHubScreen({super.key});

  @override
  State<SafetyQuizHubScreen> createState() => _SafetyQuizHubScreenState();
}

class _SafetyQuizHubScreenState extends State<SafetyQuizHubScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final filteredTopics = _selectedCategory == 'All'
        ? kSafetyQuizTopics
        : kSafetyQuizTopics.where((t) => t.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFBF7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Safety Training & Quizzes',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE088),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFCCA830)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.emoji_events, color: Color(0xFF735C00), size: 18),
                          const SizedBox(width: 4),
                          Text(
                            'Badges',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF735C00),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header Banner ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF006565), Color(0xFF008080)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryTeal.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.school, color: Colors.white, size: 28),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Master Real-World Defense',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Earn trophies by testing your scam radar',
                                      style: GoogleFonts.atkinsonHyperlegible(
                                        fontSize: 14,
                                        color: const Color(0xFFE3FFFE),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.stars, color: Color(0xFFFFE088), size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Level 3 Guardian • 320 XP Earned',
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Category Pills ──
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          'All',
                          'Banking & UPI',
                          'Family Impersonation',
                          'Government / Law',
                          'Tech Support',
                        ].map((cat) {
                          final isActive = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedCategory = cat),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                                decoration: BoxDecoration(
                                  color: isActive ? AppTheme.primaryTeal : const Color(0xFFE0F2F2),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isActive ? AppTheme.primaryTeal : const Color(0xFFBDC9C8),
                                  ),
                                ),
                                child: Text(
                                  cat,
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isActive ? Colors.white : AppTheme.primaryTeal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Quiz Cards List ──
                    Text(
                      'Available Scenarios (${filteredTopics.length})',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...filteredTopics.map((topic) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SafetyQuizScreen(topic: topic),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFFE3E2E2)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: topic.themeColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(topic.icon, color: topic.themeColor, size: 26),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFEFEDED),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  topic.difficulty.toUpperCase(),
                                                  style: GoogleFonts.atkinsonHyperlegible(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w800,
                                                    color: AppTheme.textLight,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '${topic.questionCount} Questions',
                                                style: GoogleFonts.atkinsonHyperlegible(
                                                  fontSize: 13,
                                                  color: AppTheme.textLight,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            topic.title,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.textDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  topic.subtitle,
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 15,
                                    color: AppTheme.textLight,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Scenario snippet box
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F3F3),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE3E2E2)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.remove_red_eye_outlined, size: 16, color: AppTheme.textLight),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          topic.scenarioPreview,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.atkinsonHyperlegible(
                                            fontSize: 13.5,
                                            fontStyle: FontStyle.italic,
                                            color: AppTheme.textLight,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Start Quiz CTA button
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.stars, color: Color(0xFFCCA830), size: 20),
                                        const SizedBox(width: 6),
                                        Text(
                                          '+${topic.xpReward} XP',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF735C00),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryTeal,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Start Quiz',
                                            style: GoogleFonts.atkinsonHyperlegible(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(Icons.play_arrow, color: Colors.white, size: 18),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
