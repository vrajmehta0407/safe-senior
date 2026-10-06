import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/guardian_contact.dart';
import '../state/auth_provider.dart';
import '../state/guardian_provider.dart';
import '../services/permission_service.dart';
import '../storage/local_preferences.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'settings_screen.dart';
import 'guardian_profile_screen.dart';

class GuardianContactsScreen extends ConsumerStatefulWidget {
  const GuardianContactsScreen({super.key});

  @override
  ConsumerState<GuardianContactsScreen> createState() => _GuardianContactsScreenState();
}

class _GuardianContactsScreenState extends ConsumerState<GuardianContactsScreen> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (!LocalPreferences.isLoggedIn()) return;
      setState(() => _loading = true);
      await ref.read(guardianListProvider.notifier).fetchFromBackend();
      if (mounted) setState(() => _loading = false);
    });
  }

  /// Directly opens the native phone contacts picker.
  /// After picking, shows a small bottom sheet to confirm relationship & primary flag.
  Future<void> _pickContactDirectly() async {
    // 1. Check permission
    final hasPermission = await PermissionService.requestContactsPermission();
    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Contacts permission required. Please allow in Settings → Apps → SafeSenior → Permissions.',
            style: GoogleFonts.atkinsonHyperlegible(color: Colors.white),
          ),
          backgroundColor: AppTheme.dangerRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    // 2. Open native contacts picker
    final picked = await FlutterContacts.openExternalPick();
    if (picked == null || !mounted) return;

    // 3. Fetch full contact details (name + phones)
    final full = await FlutterContacts.getContact(picked.id);
    if (full == null || !mounted) return;

    final name  = full.displayName.trim();
    final phone = full.phones.isNotEmpty ? full.phones.first.number.trim() : '';

    if (name.isEmpty || phone.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected contact has no phone number.')),
      );
      return;
    }

    // 4. Show a small bottom sheet to confirm relationship & primary flag
    String relationship = 'family';
    bool   isPrimary    = ref.read(guardianListProvider).isEmpty; // first contact = primary by default

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Contact preview
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primaryTeal.withValues(alpha: 0.15),
                    child: Text(
                      name[0].toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(phone,
                        style: GoogleFonts.atkinsonHyperlegible(
                          fontSize: 14, color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Relationship selector
              Text('Relationship', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: ['family', 'medical', 'friend', 'neighbour', 'caregiver'].map((rel) {
                  final selected = relationship == rel;
                  return GestureDetector(
                    onTap: () => setSheet(() => relationship = rel),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.primaryTeal : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selected ? AppTheme.primaryTeal : Colors.grey.shade300),
                      ),
                      child: Text(
                        rel[0].toUpperCase() + rel.substring(1),
                        style: GoogleFonts.atkinsonHyperlegible(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: selected ? Colors.white : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Primary guardian toggle
              GestureDetector(
                onTap: () => setSheet(() => isPrimary = !isPrimary),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        color: isPrimary ? AppTheme.primaryTeal : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.primaryTeal, width: 2),
                      ),
                      child: isPrimary
                          ? const Icon(Icons.check, color: Colors.white, size: 14)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Set as Primary Guardian (receives scam alerts first)',
                      style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Confirm button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ref.read(guardianListProvider.notifier).addGuardian(
                      GuardianContact(
                        name:         name,
                        phone:        phone,
                        addedAt:      DateTime.now(),
                        isPrimary:    isPrimary,
                        relationship: relationship,
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '✅ $name added as guardian!',
                          style: GoogleFonts.atkinsonHyperlegible(color: Colors.white),
                        ),
                        backgroundColor: AppTheme.primaryTeal,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  child: Text(
                    'Add $name as Guardian',
                    style: GoogleFonts.atkinsonHyperlegible(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user     = ref.watch(authProvider).user;
    final contacts = ref.watch(guardianListProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Header Bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryTeal,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.shield, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'SafeSenior',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFD6ECE8),
                      backgroundImage: user?.avatarPath != null
                          ? FileImage(File(user!.avatarPath!))
                          : null,
                      child: user?.avatarPath == null
                          ? const Icon(Icons.person, color: AppTheme.primaryTeal, size: 20)
                          : null,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // ── Title & Description ─────────────────────────────────
                    Text(
                      'Guardian Contacts',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Manage your trusted network. Your primary guardian receives scam alerts.',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 14.5,
                        color: const Color(0xFF5E706D),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── User Hero Box ───────────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F6F4),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFD6ECE8),
                                  border: Border.all(color: AppTheme.primaryTeal, width: 2.5),
                                  image: user?.avatarPath != null
                                      ? DecorationImage(
                                          image: FileImage(File(user!.avatarPath!)),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: user?.avatarPath == null
                                    ? const Icon(Icons.person, color: AppTheme.primaryTeal, size: 48)
                                    : null,
                              ),
                              Positioned(
                                bottom: -6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.08),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    user?.name.toUpperCase() ?? 'YOU',
                                    style: GoogleFonts.atkinsonHyperlegible(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2C3937),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'Tap ★ to set a contact as your primary guardian.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 14.5,
                              color: const Color(0xFF5E706D),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Add Contact Button ──────────────────────────────────
                    GestureDetector(
                      onTap: _pickContactDirectly,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryTeal,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person_add_alt_1_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Add Trusted Contact',
                                    style: GoogleFonts.atkinsonHyperlegible(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryTeal,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Expand your protection network.',
                                    style: GoogleFonts.atkinsonHyperlegible(
                                      fontSize: 13,
                                      color: const Color(0xFF6B7B78),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                size: 16, color: Color(0xFFA2B0AD)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Contacts List ───────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _loading
                          ? const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.primaryTeal,
                                ),
                              ),
                            )
                          : contacts.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.people_outline,
                                        size: 48,
                                        color: Color(0xFFA2B0AD),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No guardian contacts yet.',
                                        style: GoogleFonts.atkinsonHyperlegible(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF4A5E5B),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Add a trusted person above so Safe Senior knows who to alert when a scam is detected.',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.atkinsonHyperlegible(
                                          fontSize: 13,
                                          color: const Color(0xFF6B7B78),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  children: [
                                    ...contacts.asMap().entries.map((entry) {
                                      final idx = entry.key;
                                      final c   = entry.value;
                                      final rel = (c.relationship ?? '').toLowerCase();
                                      final isMedical = rel == 'medical' ||
                                          c.name.toLowerCase().contains('dr');

                                      return Column(
                                        children: [
                                          if (idx > 0)
                                            const Divider(
                                              height: 24,
                                              color: Color(0xFFEEF3EE),
                                            ),
                                          GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => GuardianProfileScreen(
                                                    name: c.name,
                                                    phone: c.phone,
                                                    relation: c.relationship ?? 'Guardian',
                                                    isPrimary: c.isPrimary,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 24,
                                                  backgroundColor: const Color(0xFFD6ECE8),
                                                  child: Text(
                                                    c.name.isNotEmpty
                                                        ? c.name[0].toUpperCase()
                                                        : 'G',
                                                    style: GoogleFonts.atkinsonHyperlegible(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppTheme.primaryTeal,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 14),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        c.name,
                                                        style: GoogleFonts.atkinsonHyperlegible(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                          color: const Color(0xFF2C3937),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            isMedical
                                                                ? Icons.local_hospital_outlined
                                                                : Icons.smartphone,
                                                            size: 14,
                                                            color: const Color(0xFF6B7B78),
                                                          ),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            c.phone,
                                                            style: GoogleFonts.atkinsonHyperlegible(
                                                              fontSize: 13,
                                                              color: const Color(0xFF6B7B78),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              // Badge driven by real isPrimary flag
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: c.isPrimary
                                                      ? const Color(0xFFFF7A59)
                                                      : (isMedical
                                                          ? const Color(0xFF4A6860)
                                                          : AppTheme.primaryTeal),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  c.isPrimary
                                                      ? 'PRIMARY'
                                                      : (isMedical ? 'MEDICAL' : 'TRUSTED'),
                                                  style: GoogleFonts.atkinsonHyperlegible(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                              // Set Primary button (only for non-primary)
                                              if (!c.isPrimary)
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.star_border,
                                                    color: Color(0xFFA2B0AD),
                                                    size: 20,
                                                  ),
                                                  tooltip: 'Set as primary guardian',
                                                  onPressed: () => ref
                                                      .read(guardianListProvider.notifier)
                                                      .setPrimary(idx),
                                                ),
                                              // Delete button
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  color: Color(0xFFA2B0AD),
                                                  size: 20,
                                                ),
                                                onPressed: () => ref
                                                    .read(guardianListProvider.notifier)
                                                    .removeGuardianAt(idx),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                    }),
                                  ],
                                ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }
}
