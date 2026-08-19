import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'warning_alert_screen.dart';

class ScamPattern {
  final String title;
  final String category;
  final String riskLevel; // 'HIGH RISK' | 'MEDIUM RISK' | 'CAUTION'
  final Color riskColor;
  final String description;
  final String exampleText;
  final List<String> redFlags;
  final String defenseAction;

  const ScamPattern({
    required this.title,
    required this.category,
    required this.riskLevel,
    required this.riskColor,
    required this.description,
    required this.exampleText,
    required this.redFlags,
    required this.defenseAction,
  });
}

final List<ScamPattern> kScamPatterns = [
  const ScamPattern(
    title: 'Digital Arrest & Police Video Threat',
    category: 'Government & Police',
    riskLevel: 'HIGH RISK',
    riskColor: Color(0xFFAA361F),
    description: 'Impersonators posing as CBI or State Police claiming a parcel with illegal items has been seized in your name.',
    exampleText: '"Sir, you are on digital arrest. Do not disconnect this Skype video call. You must transfer your funds to the RBI verification account."',
    redFlags: [
      'Demand to stay on video call for hours without disconnecting',
      'Threat of immediate physical arrest if money is not sent',
      'Requests to transfer savings to "clear your name"',
    ],
    defenseAction: 'Disconnect the call immediately. Real police never place citizens under "Digital Arrest". Dial Cyber Police 1930.',
  ),
  const ScamPattern(
    title: 'Electricity Bill Disconnection SMS',
    category: 'Utility Bills',
    riskLevel: 'HIGH RISK',
    riskColor: Color(0xFFAA361F),
    description: 'Urgent SMS threatening that power will be cut tonight at 9:30 PM due to unpaid balance.',
    exampleText: '"Dear consumer, your electricity power will be disconnected tonight at 9:30 PM because previous month bill was not updated. Contact electricity officer at 9876543210 immediately."',
    redFlags: [
      'Sent from a regular 10-digit mobile number instead of official utility sender ID (like BP-UGVCL)',
      'Mentions power cut within a few hours (typically 9:30 PM)',
      'Asks to call a personal phone number or install a "quick payment" APK',
    ],
    defenseAction: 'Do not call the number. Check your bill status exclusively on your official electricity board website or payment app.',
  ),
  const ScamPattern(
    title: 'Fake SBI / HDFC Bank KYC Expiry',
    category: 'Banking',
    riskLevel: 'HIGH RISK',
    riskColor: Color(0xFFAA361F),
    description: 'Deceptive text messages claiming your bank account or NetBanking is blocked due to unlinked PAN card.',
    exampleText: '"Dear Customer, your SBI YONO account has been blocked today. Please click http://sbi-pan-kyc.top to update your PAN immediately."',
    redFlags: [
      'Links with suspicious domains (.top, .xyz, .site, .apk)',
      'Artificial urgency ("blocked within 24 hours")',
      'Asks for NetBanking password, profile password, or OTP on the web form',
    ],
    defenseAction: 'Never click links in SMS. Always open your official bank app directly from your phone.',
  ),
  const ScamPattern(
    title: 'AI Grandchild Voice Clone Emergency',
    category: 'Family Emergency',
    riskLevel: 'HIGH RISK',
    riskColor: Color(0xFFAA361F),
    description: 'Scammers clone a family member\'s voice using social media audio clips and call claiming an urgent medical or legal emergency.',
    exampleText: '"Dadi! I had an accident and need ₹25,000 for hospital deposit right now. Please don\'t tell mom, just send it to this UPI ID!"',
    redFlags: [
      'Call comes from an unknown phone number',
      'Crying voice begging you not to tell other family members',
      'Demands immediate UPI payment to an unfamiliar ID',
    ],
    defenseAction: 'Hang up and dial the family member directly on their known, saved phonebook number.',
  ),
  const ScamPattern(
    title: 'Part-Time YouTube/Telegram Task Fraud',
    category: 'Job Offers',
    riskLevel: 'MEDIUM RISK',
    riskColor: Color(0xFFFE7356),
    description: 'WhatsApp messages offering ₹2,000 to ₹5,000 daily for liking videos or rating hotels on Google Maps.',
    exampleText: '"Congratulations! You have been selected for part-time work. Like 3 YouTube videos to earn ₹500 immediately."',
    redFlags: [
      'Small payouts (₹150–₹500) sent initially to gain trust',
      'Later demands "VIP prepaid deposits" to unlock earnings',
      'All communication conducted on Telegram channels',
    ],
    defenseAction: 'Block and report the sender. Never pay money to receive money.',
  ),
  const ScamPattern(
    title: 'Failed Courier / India Post Address Update',
    category: 'Fake Delivery',
    riskLevel: 'MEDIUM RISK',
    riskColor: Color(0xFFFE7356),
    description: 'Fake India Post or courier message claiming your parcel could not be delivered due to an incorrect postal code.',
    exampleText: '"India Post: Your package cannot be delivered due to missing house number. Please update address at https://indiapost-parcel.link and pay ₹5 re-delivery fee."',
    redFlags: [
      '₹5 or ₹10 token fee requested via credit card form',
      'Form captures full card number, CVV, and OTP for unauthorized high-value charges',
    ],
    defenseAction: 'Track parcels only using the official tracking number on indiapost.gov.in.',
  ),
];

class ScamLibraryScreen extends StatefulWidget {
  const ScamLibraryScreen({super.key});

  @override
  State<ScamLibraryScreen> createState() => _ScamLibraryScreenState();
}

class _ScamLibraryScreenState extends State<ScamLibraryScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = kScamPatterns.where((p) {
      final matchesCat = _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.exampleText.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

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
                    'Scam Pattern Library',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryTeal,
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
                    // ── Search Bar ──
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                      style: GoogleFonts.atkinsonHyperlegible(fontSize: 16, color: AppTheme.textDark),
                      decoration: InputDecoration(
                        hintText: 'Search 50+ scam keywords, tactics...',
                        hintStyle: GoogleFonts.atkinsonHyperlegible(fontSize: 15, color: const Color(0xFF717171)),
                        prefixIcon: const Icon(Icons.search, color: AppTheme.primaryTeal),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: AppTheme.textLight),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE3E2E2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE3E2E2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Category Pills ──
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          'All',
                          'Government & Police',
                          'Utility Bills',
                          'Banking',
                          'Family Emergency',
                          'Job Offers',
                          'Fake Delivery',
                        ].map((cat) {
                          final isActive = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedCategory = cat),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isActive ? AppTheme.primaryTeal : const Color(0xFFE0F2F2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  cat,
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 13.5,
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

                    // ── Results List or Empty State ──
                    if (filtered.isEmpty) ...[
                      // Stitch: Scam Library - No Results state
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE3E2E2)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF5F3F3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.search_off, size: 36, color: Color(0xFF717171)),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Scam Tactics Found',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'We couldn\'t find any scam entries matching "$_searchQuery".',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 15,
                                color: AppTheme.textLight,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _selectedCategory = 'All';
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryTeal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text('Reset All Filters'),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Verified Scam Patterns (${filtered.length})',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),

                      ...filtered.map((pattern) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border(
                                top: BorderSide(color: pattern.riskColor, width: 4),
                                left: const BorderSide(color: Color(0xFFE3E2E2)),
                                right: const BorderSide(color: Color(0xFFE3E2E2)),
                                bottom: const BorderSide(color: Color(0xFFE3E2E2)),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: pattern.riskColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        pattern.riskLevel,
                                        style: GoogleFonts.atkinsonHyperlegible(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: pattern.riskColor,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      pattern.category,
                                      style: GoogleFonts.atkinsonHyperlegible(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  pattern.title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  pattern.description,
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 15,
                                    color: AppTheme.textLight,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Script quote box
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F3F3),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFFE3E2E2)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Typical Scam Message / Pitch:',
                                        style: GoogleFonts.atkinsonHyperlegible(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.textLight,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        pattern.exampleText,
                                        style: GoogleFonts.atkinsonHyperlegible(
                                          fontSize: 14.5,
                                          fontStyle: FontStyle.italic,
                                          color: const Color(0xFF1B1C1C),
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Red flags bullet points
                                ...pattern.redFlags.map((flag) => Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('🚨 ', style: TextStyle(fontSize: 13)),
                                          Expanded(
                                            child: Text(
                                              flag,
                                              style: GoogleFonts.atkinsonHyperlegible(
                                                fontSize: 13.5,
                                                color: const Color(0xFF3E4949),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                const SizedBox(height: 14),

                                // Defense action footer
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0F2F2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.shield, color: AppTheme.primaryTeal, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          pattern.defenseAction,
                                          style: GoogleFonts.atkinsonHyperlegible(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.primaryTeal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
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
