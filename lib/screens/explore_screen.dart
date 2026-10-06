import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme.dart';
import 'phishing_guide_screen.dart';
import 'safety_quiz_hub_screen.dart';
import 'safety_quiz_screen.dart';
import 'scam_library_screen.dart';
import 'deepfake_warning_screen.dart';

class ExploreDiscoverScreen extends StatefulWidget {
  const ExploreDiscoverScreen({super.key});

  @override
  State<ExploreDiscoverScreen> createState() => _ExploreDiscoverScreenState();
}

class _ExploreDiscoverScreenState extends State<ExploreDiscoverScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isSearchOpen = false;

  Set<String> _exploredIds = {};
  Set<String> _bookmarkedIds = {};

  final List<String> _categories = [
    'All',
    'Scams',
    'Quizzes',
    'Tips',
    'Alerts',
    'Financial',
    'Bookmarked',
  ];

  late final List<_ExploreItem> _items;

  @override
  void initState() {
    super.initState();
    _initItems();
    _loadPreferences();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _exploredIds = (prefs.getStringList('explored_module_ids') ?? []).toSet();
      _bookmarkedIds = (prefs.getStringList('bookmarked_module_ids') ?? []).toSet();
    });
  }

  Future<void> _toggleBookmark(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_bookmarkedIds.contains(id)) {
        _bookmarkedIds.remove(id);
      } else {
        _bookmarkedIds.add(id);
      }
    });
    await prefs.setStringList('bookmarked_module_ids', _bookmarkedIds.toList());
  }

  Future<void> _toggleExplored(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_exploredIds.contains(id)) {
        _exploredIds.remove(id);
      } else {
        _exploredIds.add(id);
      }
    });
    await prefs.setStringList('explored_module_ids', _exploredIds.toList());
  }

  void _initItems() {
    _items = [
      _ExploreItem(
        id: 'digital_arrest',
        title: 'Digital Arrest Scam',
        subtitle: '2026\'s most dangerous extortion scheme',
        category: 'Scams',
        icon: Icons.gavel_outlined,
        color: const Color(0xFFB71C1C),
        isAlert: true,
        riskLevel: 'CRITICAL',
        description:
            'Extortionists impersonate CBI, ED, or State Police over WhatsApp/Skype video calls claiming a parcel containing drugs was seized in your Aadhaar name.',
        exampleText:
            '"Sir, you are under Digital Arrest. Do not cut this Skype video call. You must transfer ₹1,50,000 to the Supreme Court verification escrow account immediately."',
        redFlags: [
          'Demand to stay on video call for hours without disconnecting',
          'Threat of immediate physical arrest if money is not sent',
          'Claims that "Digital Arrest" is an official court order',
          'Demands money transfer to "clear your name"',
        ],
        defenseAction:
            'Disconnect the call immediately. Real police never conduct digital arrests or demand money on video calls. Dial 1930.',
        quizTopicId: 'digital_arrest',
      ),
      _ExploreItem(
        id: 'fake_bank_sms',
        title: 'Spot the Fake Bank SMS',
        subtitle: 'Can you identify fake SBI, HDFC & ICICI alerts?',
        category: 'Quizzes',
        icon: Icons.quiz_outlined,
        color: const Color(0xFF006565),
        isAlert: false,
        riskLevel: 'HIGH',
        description:
            'Test your skills at identifying malicious links, fake urgency ("blocked in 2 hours"), and spoofed sender IDs before you tap.',
        exampleText:
            '"Dear SBI Customer, your NetBanking is suspended due to expired PAN. Update within 2 hours at https://sbi-pan-kyc.top or account will be frozen permanently."',
        redFlags: [
          'Sent from 10-digit mobile number instead of bank sender header (e.g. AX-SBIINB)',
          'Suspicious domain (.top, .xyz, .site, .apk) instead of official bank portal',
          'Artificial panic stating your account will be deleted within 2 hours',
        ],
        defenseAction:
            'Never click links in SMS. Always open your official banking app directly or visit your local branch.',
        quizTopicId: 'bank_kyc',
      ),
      _ExploreItem(
        id: 'kyc_update_fraud',
        title: 'KYC Update Fraud',
        subtitle: 'Don\'t share OTP for fake KYC or PAN linking',
        category: 'Financial',
        icon: Icons.credit_card_outlined,
        color: const Color(0xFFB71C1C),
        isAlert: true,
        riskLevel: 'HIGH',
        description:
            'Scammers pretend to be bank managers offering to "renew your expired KYC" over the phone so your monthly pension or interest is not blocked.',
        exampleText:
            '"Namaste Uncleji, I am calling from bank headquarters. Your KYC has expired. Please share the 6-digit Aadhaar OTP to keep pension active."',
        redFlags: [
          'Caller insists on completing KYC over WhatsApp or phone call',
          'Asks for Aadhaar OTP, Debit Card CVV, or NetBanking password',
          'Threatens that pension payments will stop unless verified right now',
        ],
        defenseAction:
            'Hang up immediately. Banks never do full KYC over phone calls or ask for OTPs. Visit your home branch in person.',
        quizTopicId: 'bank_kyc',
      ),
      _ExploreItem(
        id: 'grandchild_impersonation',
        title: 'Grandchild Impersonation',
        subtitle: 'Learn how scammers clone family voices using AI',
        category: 'Scams',
        icon: Icons.family_restroom,
        color: const Color(0xFFE65100),
        isAlert: true,
        riskLevel: 'HIGH',
        description:
            'Using 3-second audio clips from social media, AI tools clone your grandchild\'s voice and call claiming a hospital or police emergency.',
        exampleText:
            '"Dadi! I was in a car accident and police are holding me. Please send ₹25,000 to this hospital UPI right now, please don\'t tell mummy!"',
        redFlags: [
          'Call comes from an unfamiliar or private number',
          'Frantic, crying voice begging you not to notify parents',
          'Demands immediate UPI payment to an unknown merchant handle',
        ],
        defenseAction:
            'Hang up immediately and dial your grandchild or their parents directly on their known, saved phonebook number.',
        quizTopicId: 'grandchild_sos',
      ),
      _ExploreItem(
        id: 'phishing_5_ways',
        title: '5 Ways to Spot Phishing',
        subtitle: 'Simple practical rules to stay 100% safe online',
        category: 'Tips',
        icon: Icons.tips_and_updates_outlined,
        color: const Color(0xFF006565),
        isAlert: false,
        riskLevel: 'SAFE',
        description:
            'Master the 5 essential red flags: mismatched sender domain, urgent pressure, unexpected file downloads (.apk), credential requests, and too-good-to-be-true claims.',
        exampleText:
            '"Income Tax Refund of ₹42,500 has been approved. Click here to confirm your bank account: incometax-gov.in.top"',
        redFlags: [
          'Generic greeting ("Dear Customer" instead of your actual name)',
          'Sender email is a public email (like @gmail.com) pretending to be a bank',
          'Subtle spelling variations in web address',
        ],
        defenseAction:
            'Always inspect the sender domain and never enter banking passwords on web links sent via email or chat.',
        linkedGuide: 'phishing_guide',
      ),
      _ExploreItem(
        id: 'romance_scam_training',
        title: 'Romance Scam & Matrimonial Trap',
        subtitle: 'How online friendship can turn into an extortion trap',
        category: 'Quizzes',
        icon: Icons.favorite_border,
        color: const Color(0xFF880E4F),
        isAlert: false,
        riskLevel: 'HIGH',
        description:
            'Fraudsters pose as affluent doctors, NRI engineers, or lonely widowers, build trust over weeks, then claim expensive gifts are stuck at customs.',
        exampleText:
            '"Darling, I sent you expensive gold jewelry and iPhone from London. Customs officer at Delhi airport is demanding ₹65,000 custom duty to release the package."',
        redFlags: [
          'Refuses video calls or face-to-face meetings in person',
          'Professes deep love or emotional attachment very quickly',
          'Claims customs officer is demanding personal UPI transfer to clear a parcel',
        ],
        defenseAction:
            'Never send money to someone you have only met online. Indian Customs never accepts duty into personal bank accounts or UPI.',
      ),
      _ExploreItem(
        id: 'electricity_bill_scam',
        title: 'Electricity Bill Scam',
        subtitle: 'Never pay power bills via unknown links or APKs',
        category: 'Financial',
        icon: Icons.electric_bolt_outlined,
        color: const Color(0xFFB71C1C),
        isAlert: true,
        riskLevel: 'MEDIUM',
        description:
            'Seniors receive an evening SMS warning their electricity will be disconnected tonight at 9:30 PM due to unpaid dues, instructing them to call a mobile number.',
        exampleText:
            '"Dear consumer, your electricity power will be disconnected tonight at 9:30 PM from power house because last month bill was not updated. Call electricity officer at 9876543210 immediately."',
        redFlags: [
          'Sent from a regular 10-digit phone number instead of official electricity board ID',
          'Threatens power disconnection within a few hours (typically 9:30 PM)',
          'Asks to install a "quick support app" (malicious APK) to update bill',
        ],
        defenseAction:
            'Check your bill exclusively on your physical electricity bill copy or official power company website (Torrent Power / UGVCL / BESCOM).',
      ),
      _ExploreItem(
        id: 'medicare_fraud_alert',
        title: 'Medicare & Ayushman Fraud Alert',
        subtitle: 'Protect your health insurance and senior pension',
        category: 'Financial',
        icon: Icons.medical_services_outlined,
        color: const Color(0xFFB71C1C),
        isAlert: true,
        riskLevel: 'HIGH',
        description:
            'Impostors claim your senior citizen government pension or Ayushman Bharat health card will be permanently cancelled unless you pay a "re-registration fee".',
        exampleText:
            '"PM Senior Health Scheme: Your Ayushman card renewal is pending. Pay ₹1,200 via UPI link to prevent cancellation of free medical benefits."',
        redFlags: [
          'Government schemes like Ayushman Bharat are 100% free and do not require fee transfers',
          'Asks to transfer money to a private UPI handle',
          'Demands bank account details to "credit bonus medical funds"',
        ],
        defenseAction:
            'Government pension and medical cards never charge activation fees via SMS or WhatsApp links. Verify at government hospitals or CSC centers.',
      ),
      _ExploreItem(
        id: 'tech_support_quiz',
        title: 'Tech Support Scam Quiz',
        subtitle: 'Would you fall for a fake Microsoft or Google call?',
        category: 'Quizzes',
        icon: Icons.computer_outlined,
        color: const Color(0xFF006565),
        isAlert: false,
        riskLevel: 'HIGH',
        description:
            'Browser pop-ups with loud sirens or cold-callers claiming your computer or phone is hacked, instructing you to install AnyDesk or TeamViewer.',
        exampleText:
            '"Windows Security Alert! 18 trojans detected on your device. Call Microsoft Certified Technician at 1800-420-1122 immediately to avoid permanent lockout."',
        redFlags: [
          'Loud audio sirens or full-screen lockups claiming malware infection',
          'Caller asks you to download AnyDesk, TeamViewer, or QuickSupport',
          'Caller requests your 9-digit remote access code',
        ],
        defenseAction:
            'Never grant remote access to unknown callers. Shut down or restart your device. Microsoft and Apple never cold-call customers.',
        quizTopicId: 'tech_support',
      ),
      _ExploreItem(
        id: 'part_time_job_trap',
        title: 'Part-Time Job Trap',
        subtitle: 'Too-good-to-be-true offers are always scams',
        category: 'Scams',
        icon: Icons.work_outline,
        color: const Color(0xFFE65100),
        isAlert: true,
        riskLevel: 'MEDIUM',
        description:
            'WhatsApp messages offering ₹3,000 daily for liking YouTube videos or Google reviews. They pay ₹200 initially, then demand thousands to "unlock prepaid task earnings".',
        exampleText:
            '"Work from home for retired seniors: Like 3 YouTube videos and earn ₹500. Click here to join our official Telegram channel and receive payment."',
        redFlags: [
          'Small initial payout (₹150–₹500) sent to build false trust',
          'Later demands large "VIP prepaid deposits" to unlock your funds',
          'All communications conducted on anonymous Telegram channels',
        ],
        defenseAction:
            'Block and report the sender. Never pay money to earn money.',
      ),
    ];
  }

  List<_ExploreItem> get _filteredItems {
    return _items.where((item) {
      // Category filter
      if (_selectedCategory == 'Bookmarked') {
        if (!_bookmarkedIds.contains(item.id)) return false;
      } else if (_selectedCategory != 'All' && item.category != _selectedCategory) {
        return false;
      }

      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = item.title.toLowerCase().contains(q);
        final matchSubtitle = item.subtitle.toLowerCase().contains(q);
        final matchDesc = item.description.toLowerCase().contains(q);
        final matchCategory = item.category.toLowerCase().contains(q);
        if (!matchTitle && !matchSubtitle && !matchDesc && !matchCategory) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  int get _completedCount => _items.where((i) => _exploredIds.contains(i.id)).length;

  Future<void> _callHelpline() async {
    final uri = Uri.parse('tel:1930');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Helpline number: 1930 (National Cyber Crime)')),
        );
      }
    }
  }

  void _shareAdvice(_ExploreItem item) {
    final text = 'SafeSenior Alert: "${item.title}"\n\n'
        'Warning: ${item.subtitle}\n\n'
        'Example: ${item.exampleText}\n\n'
        'Safety Rule: ${item.defenseAction}\n\n'
        'Protected by SafeSenior App.';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Safety warning copied! You can paste and share it on WhatsApp.',
            style: GoogleFonts.atkinsonHyperlegible(color: Colors.white)),
        backgroundColor: AppTheme.primaryTeal,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _launchActionForItem(_ExploreItem item) {
    if (item.quizTopicId != null) {
      final topic = kSafetyQuizTopics.firstWhere(
        (t) => t.id == item.quizTopicId,
        orElse: () => kSafetyQuizTopics.first,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SafetyQuizScreen(topic: topic)),
      );
    } else if (item.linkedGuide == 'phishing_guide') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PhishingGuideScreen()),
      );
    } else if (item.id == 'grandchild_impersonation') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DeepfakeWarningScreen()),
      );
    } else {
      _showItemDetailSheet(item);
    }
  }

  void _showPracticeDrillDialog(_ExploreItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.school_outlined, color: item.color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Interactive Drill',
                style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scenario: You receive this notification:',
              style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5F4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                item.exampleText,
                style: GoogleFonts.atkinsonHyperlegible(fontSize: 13.5, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'What should you do?',
              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dangerRed.withValues(alpha: 0.08),
                foregroundColor: AppTheme.dangerRed,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _showDrillFeedback(false, item);
              },
              child: const Text('A. Comply with instructions and send money / OTP'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal.withValues(alpha: 0.12),
                foregroundColor: AppTheme.primaryTeal,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _showDrillFeedback(true, item);
              },
              child: const Text('B. Disconnect immediately and verify via official channel'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDrillFeedback(bool isCorrect, _ExploreItem item) {
    if (isCorrect && !_exploredIds.contains(item.id)) {
      _toggleExplored(item.id);
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: isCorrect ? const Color(0xFF2E7D32) : AppTheme.dangerRed,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              isCorrect ? 'Well Done!' : 'Dangerous Mistake!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isCorrect ? const Color(0xFF2E7D32) : AppTheme.dangerRed,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isCorrect
                  ? 'Correct! You prevented an unauthorized transaction and protected your accounts.'
                  : 'Warning! Scammers use fear and urgency to trick seniors into giving up OTPs or money.',
              style: GoogleFonts.atkinsonHyperlegible(fontSize: 14.5, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Golden Rule: ${item.defenseAction}',
                style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showItemDetailSheet(_ExploreItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header with Badge & Bookmark
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.category.toUpperCase(),
                        style: GoogleFonts.atkinsonHyperlegible(fontSize: 11, fontWeight: FontWeight.bold, color: item.color),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (item.riskLevel.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (item.riskLevel == 'CRITICAL' ? AppTheme.dangerRed : Colors.orange).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.riskLevel,
                          style: GoogleFonts.atkinsonHyperlegible(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: item.riskLevel == 'CRITICAL' ? AppTheme.dangerRed : Colors.orange.shade800,
                          ),
                        ),
                      ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        _bookmarkedIds.contains(item.id) ? Icons.bookmark : Icons.bookmark_border,
                        color: _bookmarkedIds.contains(item.id) ? Colors.amber.shade800 : AppTheme.textSecondary,
                      ),
                      onPressed: () {
                        _toggleBookmark(item.id);
                        setModalState(() {});
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                      onPressed: () => Navigator.pop(modalContext),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Title
                Text(
                  item.title,
                  style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: GoogleFonts.atkinsonHyperlegible(fontSize: 14, color: AppTheme.textSecondary),
                ),

                const SizedBox(height: 14),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Threat Description
                        Text(
                          item.description,
                          style: GoogleFonts.atkinsonHyperlegible(fontSize: 15, color: AppTheme.textDark, height: 1.45),
                        ),
                        const SizedBox(height: 16),

                        // Simulated Threat Message Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F6F6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.red.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, size: 16, color: AppTheme.dangerRed),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Real-World Fraud Example / Script:',
                                    style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.dangerRed),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.exampleText,
                                style: GoogleFonts.atkinsonHyperlegible(fontSize: 13.5, fontStyle: FontStyle.italic, color: Colors.black87, height: 1.35),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Red Flags Checklist
                        Text(
                          'Red Flags to Watch For:',
                          style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                        ),
                        const SizedBox(height: 8),
                        ...item.redFlags.map(
                          (flag) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('🚨 ', style: TextStyle(fontSize: 13)),
                                Expanded(
                                  child: Text(
                                    flag,
                                    style: GoogleFonts.atkinsonHyperlegible(fontSize: 13.5, color: AppTheme.textDark, height: 1.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Immediate Defense Action
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.shield_outlined, color: Color(0xFF2E7D32), size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'How to Protect Yourself:',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.defenseAction,
                                      style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, color: Colors.black87, height: 1.35),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Interactive Bottom Action Buttons
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryTeal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.play_circle_fill, size: 18),
                            label: Text(
                              item.quizTopicId != null ? 'Take Quiz' : 'Practice Drill',
                              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13.5),
                            ),
                            onPressed: () {
                              Navigator.pop(modalContext);
                              if (item.quizTopicId != null) {
                                final topic = kSafetyQuizTopics.firstWhere(
                                  (t) => t.id == item.quizTopicId,
                                  orElse: () => kSafetyQuizTopics.first,
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => SafetyQuizScreen(topic: topic)),
                                );
                              } else {
                                _showPracticeDrillDialog(item);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: AppTheme.primaryTeal),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.phone_in_talk, size: 18, color: AppTheme.primaryTeal),
                            label: Text(
                              'Dial 1930',
                              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppTheme.primaryTeal),
                            ),
                            onPressed: _callHelpline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            icon: const Icon(Icons.share, size: 16),
                            label: const Text('Share Advisory with Family'),
                            onPressed: () => _shareAdvice(item),
                          ),
                        ),
                        TextButton.icon(
                          icon: Icon(
                            _exploredIds.contains(item.id) ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: _exploredIds.contains(item.id) ? Colors.green : Colors.grey,
                            size: 16,
                          ),
                          label: Text(
                            _exploredIds.contains(item.id) ? 'Mastered' : 'Mark Learned',
                            style: TextStyle(
                              color: _exploredIds.contains(item.id) ? Colors.green : Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () {
                            _toggleExplored(item.id);
                            setModalState(() {});
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;
    final progressFraction = _items.isNotEmpty ? _completedCount / _items.length : 0.0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppTheme.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Explore & Discover',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(_isSearchOpen ? Icons.close : Icons.search, color: AppTheme.primaryTeal),
                    onPressed: () {
                      setState(() {
                        _isSearchOpen = !_isSearchOpen;
                        if (!_isSearchOpen) {
                          _searchCtrl.clear();
                          _searchQuery = '';
                        }
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu_book_outlined, color: AppTheme.primaryTeal),
                    tooltip: 'Scam Encyclopedia',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ScamLibraryScreen()),
                    ),
                  ),
                ],
              ),
            ),

            // ── Real-Time In-Page Search Bar ──
            if (_isSearchOpen)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search scams, quizzes, keywords...',
                    hintStyle: GoogleFonts.atkinsonHyperlegible(fontSize: 14, color: Colors.grey.shade500),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primaryTeal),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppTheme.primaryTeal),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                ),
              ),

            // ── Interactive Learning Progress Tracker Card ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE0F2F2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.shield_outlined, size: 18, color: AppTheme.primaryTeal),
                            const SizedBox(width: 8),
                            Text(
                              'Safety Readiness Score',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$_completedCount of ${_items.length} Mastered',
                          style: GoogleFonts.atkinsonHyperlegible(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progressFraction,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 6),

            // ── Dynamic Category Filter Pills ──
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  final isSelected = _selectedCategory == cat;
                  int count = 0;
                  if (cat == 'All') {
                    count = _items.length;
                  } else if (cat == 'Bookmarked') {
                    count = _bookmarkedIds.length;
                  } else {
                    count = _items.where((it) => it.category == cat).length;
                  }

                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryTeal : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryTeal : AppTheme.dividerColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            cat,
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white.withValues(alpha: 0.25) : Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // ── Featured Daily Quiz Banner ──
            if (_selectedCategory == 'All' || _selectedCategory == 'Quizzes')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SafetyQuizHubScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF006565), Color(0xFF004D4D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  '🔥 SENIOR SAFETY HUB',
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Practice Daily Scam Scenarios',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Interactive drills with real audio & SMS simulations',
                                style: GoogleFonts.atkinsonHyperlegible(
                                  fontSize: 12.5,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primaryTeal,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SafetyQuizHubScreen()),
                          ),
                          child: Text(
                            'Open Hub',
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 8),

            // ── Dynamic Items List ──
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _buildExploreCard(filtered[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreCard(_ExploreItem item) {
    final isExplored = _exploredIds.contains(item.id);
    final isBookmarked = _bookmarkedIds.contains(item.id);

    return InkWell(
      onTap: () => _showItemDetailSheet(item),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isExplored ? const Color(0xFFC8E6C9) : const Color(0xFFE8E8E8),
            width: isExplored ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Themed Icon Box
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(item.icon, color: item.color, size: 24),
                ),
                const SizedBox(width: 12),

                // Title, Category & Risk
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          if (item.riskLevel.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: (item.riskLevel == 'CRITICAL' ? AppTheme.dangerRed : Colors.orange).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                item.riskLevel,
                                style: GoogleFonts.atkinsonHyperlegible(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: item.riskLevel == 'CRITICAL' ? AppTheme.dangerRed : Colors.orange.shade800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.subtitle,
                        style: GoogleFonts.atkinsonHyperlegible(fontSize: 12.5, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),

                // Bookmark Star
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked ? Colors.amber.shade800 : Colors.grey.shade400,
                    size: 22,
                  ),
                  onPressed: () => _toggleBookmark(item.id),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Card Bottom Actions Bar
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    item.category,
                    style: GoogleFonts.atkinsonHyperlegible(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                  ),
                ),
                if (isExplored) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check, color: Color(0xFF2E7D32), size: 12),
                        const SizedBox(width: 3),
                        Text(
                          'Mastered',
                          style: GoogleFonts.atkinsonHyperlegible(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32)),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),

                // Working Action Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: item.color.withValues(alpha: 0.12),
                    foregroundColor: item.color,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: Icon(
                    item.quizTopicId != null
                        ? Icons.play_arrow_rounded
                        : (item.linkedGuide != null ? Icons.menu_book : Icons.security),
                    size: 16,
                  ),
                  label: Text(
                    item.quizTopicId != null
                        ? 'Start Quiz'
                        : (item.linkedGuide != null ? 'Read Guide' : 'Breakdown'),
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _launchActionForItem(item),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_outlined, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            _searchQuery.isNotEmpty ? 'No matches for "$_searchQuery"' : 'No items in "$_selectedCategory"',
            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark),
          ),
          const SizedBox(height: 6),
          Text(
            'Try clearing your search query or selecting "All"',
            style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ExploreItem {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final IconData icon;
  final Color color;
  final bool isAlert;
  final String riskLevel;
  final String description;
  final String exampleText;
  final List<String> redFlags;
  final String defenseAction;
  final String? quizTopicId;
  final String? linkedGuide;

  const _ExploreItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.color,
    required this.isAlert,
    required this.riskLevel,
    required this.description,
    required this.exampleText,
    required this.redFlags,
    required this.defenseAction,
    this.quizTopicId,
    this.linkedGuide,
  });
}
