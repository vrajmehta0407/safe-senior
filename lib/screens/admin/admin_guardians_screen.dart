// lib/screens/admin/admin_guardians_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/admin_api_client.dart';

class AdminGuardiansScreen extends ConsumerStatefulWidget {
  const AdminGuardiansScreen({super.key});

  @override
  ConsumerState<AdminGuardiansScreen> createState() =>
      _AdminGuardiansScreenState();
}

class _AdminGuardiansScreenState extends ConsumerState<AdminGuardiansScreen> {
  List<dynamic> _guardians = [];
  int _total = 0;
  int _offset = 0;
  bool _loading = true;
  final _searchCtrl = TextEditingController();
  static const _limit = 50;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) setState(() => _offset = 0);
    setState(() => _loading = true);
    final result = await ref.read(adminApiProvider).getGuardians(
          limit: _limit,
          offset: reset ? 0 : _offset,
          search: _searchCtrl.text.trim().isEmpty
              ? null
              : _searchCtrl.text.trim(),
        );
    if (mounted) {
      setState(() {
        _guardians = result?['guardians'] as List<dynamic>? ?? [];
        _total = (result?['total'] as num?)?.toInt() ?? 0;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0A0D14)),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF111521),
          elevation: 0,
          title: Text('Guardians ($_total)',
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w600)),
        ),
        body: Column(
          children: [
            // Search
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search by name or phone…',
                  hintStyle: const TextStyle(
                      color: Colors.white38, fontSize: 14),
                  prefixIcon: const Icon(Icons.search,
                      color: Colors.white38, size: 20),
                  filled: true,
                  fillColor: const Color(0xFF1A2035),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color:
                            Colors.white.withValues(alpha: 0.08)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color:
                            Colors.white.withValues(alpha: 0.08)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color(0xFF4F8EF7), width: 1.5),
                  ),
                ),
                onSubmitted: (_) => _load(reset: true),
              ),
            ),

            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation(Color(0xFF4F8EF7))))
                  : _guardians.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.family_restroom,
                                  color: Colors.white24, size: 40),
                              SizedBox(height: 12),
                              Text('No guardians found',
                                  style:
                                      TextStyle(color: Colors.white38)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => _load(reset: true),
                          color: const Color(0xFF4F8EF7),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            itemCount: _guardians.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                              final g =
                                  _guardians[i] as Map<String, dynamic>;
                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A2035),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.white
                                          .withValues(alpha: 0.07)),
                                ),
                                child: Row(children: [
                                  Container(
                                    width: 42, height: 42,
                                    decoration: BoxDecoration(
                                      color: Colors.greenAccent
                                          .withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.greenAccent
                                              .withValues(alpha: 0.3)),
                                    ),
                                    child: const Icon(Icons.favorite,
                                        color: Colors.greenAccent,
                                        size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          g['name'] as String? ?? '—',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          g['phone_number'] as String? ??
                                              '',
                                          style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12),
                                        ),
                                        if ((g['relationship'] as String?)
                                                ?.isNotEmpty ==
                                            true)
                                          Container(
                                            margin: const EdgeInsets.only(
                                                top: 4),
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 7,
                                                    vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withValues(alpha: 0.08),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      20),
                                            ),
                                            child: Text(
                                              g['relationship'] as String,
                                              style: const TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 10),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      const Text('Senior',
                                          style: TextStyle(
                                              color: Colors.white24,
                                              fontSize: 10)),
                                      const SizedBox(height: 2),
                                      Text(
                                        g['user_name'] as String? ?? '—',
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ]),
                              );
                            },
                          ),
                        ),
            ),

            if (_total > _limit)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_offset + 1}–${(_offset + _limit).clamp(0, _total)} of $_total',
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 12),
                    ),
                    Row(children: [
                      TextButton(
                          onPressed: _offset == 0
                              ? null
                              : () {
                                  setState(() => _offset =
                                      (_offset - _limit).clamp(0, _total));
                                  _load();
                                },
                          child: const Text('← Prev',
                              style:
                                  TextStyle(color: Color(0xFF4F8EF7)))),
                      TextButton(
                          onPressed: _offset + _limit >= _total
                              ? null
                              : () {
                                  setState(() => _offset += _limit);
                                  _load();
                                },
                          child: const Text('Next →',
                              style:
                                  TextStyle(color: Color(0xFF4F8EF7)))),
                    ]),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
