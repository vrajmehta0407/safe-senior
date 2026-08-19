import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/guardian_contact.dart';
import '../services/guardian_service.dart';
import '../state/guardian_provider.dart';

class FamilyInviteScreen extends ConsumerStatefulWidget {
  const FamilyInviteScreen({super.key});

  @override
  ConsumerState<FamilyInviteScreen> createState() => _FamilyInviteScreenState();
}

class _FamilyInviteScreenState extends ConsumerState<FamilyInviteScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _customNoteCtrl = TextEditingController(
    text: 'Hi! I\'m inviting you as my trusted family guardian on SafeSenior to help protect my phone against banking scams and fraud.',
  );
  String _relation = 'Son / Daughter';
  bool _isSaving = false;

  final List<String> _relations = [
    'Son / Daughter',
    'Spouse / Partner',
    'Grandchild',
    'Brother / Sister',
    'Trusted Friend',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _customNoteCtrl.dispose();
    super.dispose();
  }

  void _sendInvite() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter your guardian\'s name and mobile number.',
            style: GoogleFonts.atkinsonHyperlegible(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFAA361F),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final contact = GuardianContact(
      name: name,
      phone: phone,
      email: _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : null,
      relationship: _relation,
      isPrimary: false,
      addedAt: DateTime.now(),
    );

    await ref.read(guardianListProvider.notifier).addGuardian(contact);
    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🎉 Invitation sent to $name via SMS/WhatsApp!',
          style: GoogleFonts.atkinsonHyperlegible(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryTeal,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
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
                    'Invite Family Guardian',
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
                    // Header card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2F2),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryTeal,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Shared Protection Circle',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryTeal,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Your guardian receives automated SMS alerts only when critical scams or threats occur.',
                                  style: GoogleFonts.atkinsonHyperlegible(
                                    fontSize: 13.5,
                                    color: const Color(0xFF004F4F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Guardian Name
                    Text(
                      'Guardian\'s Full Name',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameCtrl,
                      style: GoogleFonts.atkinsonHyperlegible(fontSize: 16, color: AppTheme.textDark),
                      decoration: _inputDecoration('e.g. Priya Sharma'),
                    ),
                    const SizedBox(height: 16),

                    // Phone Number
                    Text(
                      'Mobile Phone Number',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.atkinsonHyperlegible(fontSize: 16, color: AppTheme.textDark),
                      decoration: _inputDecoration('+91 98250 12345'),
                    ),
                    const SizedBox(height: 16),

                    // Relationship
                    Text(
                      'Relationship',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE3E2E2)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _relation,
                          isExpanded: true,
                          style: GoogleFonts.atkinsonHyperlegible(fontSize: 16, color: AppTheme.textDark),
                          items: _relations.map((r) {
                            return DropdownMenuItem(value: r, child: Text(r));
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _relation = v);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Optional Personal Note
                    Text(
                      'Personal Invitation Message',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _customNoteCtrl,
                      maxLines: 3,
                      style: GoogleFonts.atkinsonHyperlegible(fontSize: 14.5, color: AppTheme.textDark),
                      decoration: _inputDecoration(''),
                    ),
                    const SizedBox(height: 32),

                    // Send Invitation Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _sendInvite,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.send, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Send Guardian Invitation',
                                    style: GoogleFonts.atkinsonHyperlegible(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.atkinsonHyperlegible(fontSize: 15, color: const Color(0xFF717171)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
    );
  }
}
