import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../state/auth_provider.dart';
import '../state/guardian_provider.dart';
import '../services/api_client.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'settings_screen.dart';

class TrustedSendersScreen extends ConsumerStatefulWidget {
  const TrustedSendersScreen({super.key});

  @override
  ConsumerState<TrustedSendersScreen> createState() => _TrustedSendersScreenState();
}

class _TrustedSendersScreenState extends ConsumerState<TrustedSendersScreen> {
  List<Map<String, dynamic>> _senders = [];
  bool _loading = true;

  final _senderCtrl = TextEditingController();
  final _labelCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _senderCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.get('/trusted-senders');
      if (res != null && res['success'] == true) {
        setState(() => _senders = List<Map<String, dynamic>>.from(res['trustedSenders'] ?? []));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _add() async {
    final sender = _senderCtrl.text.trim().toUpperCase();
    final label = _labelCtrl.text.trim();
    if (sender.isEmpty) return;

    final res = await ApiClient.post('/trusted-senders', {'sender': sender, 'label': label.isEmpty ? sender : label});
    if (res != null && res['success'] == true) {
      _senderCtrl.clear();
      _labelCtrl.clear();
      if (mounted) Navigator.pop(context);
      await _load();
    }
  }

  Future<void> _delete(int id) async {
    final res = await ApiClient.delete('/trusted-senders/$id');
    if (res != null && res['success'] == true) {
      await _load();
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Add Trusted Sender', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _senderCtrl,
              decoration: InputDecoration(
                labelText: 'Sender ID / Phone number',
                hintText: 'e.g. +91 98250 14820 or VM-SBIINB',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _labelCtrl,
              decoration: InputDecoration(
                labelText: 'Name (optional)',
                hintText: 'e.g. Amit Patel, State Bank of India',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: _add,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final guardians = ref.watch(guardianListProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFD6ECE8),
                      backgroundImage: user?.avatarPath != null
                          ? FileImage(File(user!.avatarPath!)) as ImageProvider
                          : const NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150'),
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

                    // Title & Subtitle
                    Text(
                      'Trusted Circle',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Verified contacts whose communications bypass high-urgency filters.',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 14.5,
                        color: const Color(0xFF5E706D),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Dynamic Constellation View Box
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF3F0),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTeal,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryTeal.withValues(alpha: 0.25),
                                  blurRadius: 20,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.shield, color: Colors.white, size: 30),
                            ),
                          ),
                          ...guardians.asMap().entries.map((e) {
                            final idx = e.key;
                            final g = e.value;
                            final offset = idx == 0
                                ? const Offset(-70, -40)
                                : (idx == 1 ? const Offset(70, 40) : const Offset(-70, 40));

                            return Transform.translate(
                              offset: offset,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      g.name.isNotEmpty ? g.name[0].toUpperCase() : 'G',
                                      style: GoogleFonts.atkinsonHyperlegible(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    g.name,
                                    style: GoogleFonts.atkinsonHyperlegible(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF2C3937)),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Add Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _showAddDialog,
                        icon: const Icon(Icons.add, size: 20),
                        label: Text(
                          'Add Trusted Sender',
                          style: GoogleFonts.atkinsonHyperlegible(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Dynamic Members List Container
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Members',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                          const SizedBox(height: 16),

                          ...guardians.map((g) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: const Color(0xFFD6ECE8),
                                    child: Text(
                                      g.name.isNotEmpty ? g.name[0].toUpperCase() : 'G',
                                      style: GoogleFonts.atkinsonHyperlegible(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          g.name,
                                          style: GoogleFonts.atkinsonHyperlegible(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF2C3937)),
                                        ),
                                        Text(
                                          g.phone,
                                          style: GoogleFonts.atkinsonHyperlegible(fontSize: 12.5, color: const Color(0xFF6B7B78)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.verified, color: AppTheme.primaryTeal, size: 20),
                                ],
                              ),
                            );
                          }).toList(),

                          ..._senders.map((s) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Color(0xFFD6ECE8),
                                    child: Icon(Icons.phone, color: AppTheme.primaryTeal, size: 18),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s['label'] ?? s['sender'],
                                          style: GoogleFonts.atkinsonHyperlegible(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF2C3937)),
                                        ),
                                        Text(
                                          s['sender'] ?? '',
                                          style: GoogleFonts.atkinsonHyperlegible(fontSize: 12.5, color: const Color(0xFF6B7B78)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                    onPressed: () => _delete(s['id'] as int),
                                  ),
                                ],
                              ),
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
