import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/guardian_contact.dart';
import '../state/auth_provider.dart';
import '../state/guardian_provider.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../services/permission_service.dart';
import 'settings_screen.dart';
import 'guardian_profile_screen.dart';
import 'family_circle_board_screen.dart';
import 'family_invite_screen.dart';
import 'emergency_verification_screen.dart';

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
    // Fetch latest guardians from backend on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      setState(() => _loading = true);
      await ref.read(guardianListProvider.notifier).fetchFromBackend();
      if (mounted) setState(() => _loading = false);
    });
  }

  void _showAddContactDialog() {
    final nameCtrl         = TextEditingController();
    final phoneCtrl        = TextEditingController();
    final relationshipCtrl = TextEditingController();
    bool  isPrimary        = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text(
            'Add Trusted Contact',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryTeal,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.contacts_rounded, size: 20),
                label: Text('Import from Phone Contacts', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                onPressed: () async {
                  final hasPermission = await PermissionService.requestContactsPermission();
                  if (!hasPermission && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Contacts permission is required to select from phonebook.')),
                    );
                    return;
                  }
                  // Prefill sample contact if accessed
                  nameCtrl.text = nameCtrl.text.isEmpty ? 'Trusted Contact' : nameCtrl.text;
                  phoneCtrl.text = phoneCtrl.text.isEmpty ? '+91 98765 43210' : phoneCtrl.text;
                  setDialogState(() {});
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('OR MANUAL ENTRY', style: GoogleFonts.atkinsonHyperlegible(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name (e.g. Mom, Sarah)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: relationshipCtrl,
                decoration: const InputDecoration(
                  labelText: 'Relationship (e.g. family, medical)',
                  hintText: 'family',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: isPrimary,
                    activeColor: AppTheme.primaryTeal,
                    onChanged: (v) => setDialogState(() => isPrimary = v ?? false),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Set as primary guardian',
                    style: GoogleFonts.atkinsonHyperlegible(fontSize: 13, color: const Color(0xFF5E706D)),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final name  = nameCtrl.text.trim();
                final phone = phoneCtrl.text.trim();
                final rel   = relationshipCtrl.text.trim();
                if (name.isNotEmpty && phone.isNotEmpty) {
                  ref.read(guardianListProvider.notifier).addGuardian(
                    GuardianContact(
                      name:         name,
                      phone:        phone,
                      addedAt:      DateTime.now(),
                      isPrimary:    isPrimary,
                      relationship: rel.isEmpty ? 'family' : rel,
                    ),
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add Contact'),
            ),
          ],
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
                          ? FileImage(File(user!.avatarPath!)) as ImageProvider
                          : const NetworkImage(
                              'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150'),
                      child: user?.avatarPath == null && (user?.name.isEmpty ?? true)
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
                                  border: Border.all(color: AppTheme.primaryTeal, width: 2.5),
                                  image: DecorationImage(
                                    image: user?.avatarPath != null
                                        ? FileImage(File(user!.avatarPath!)) as ImageProvider
                                        : const NetworkImage(
                                            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
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
                      onTap: _showAddContactDialog,
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
                                    }).toList(),
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
