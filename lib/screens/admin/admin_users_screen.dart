// lib/screens/admin/admin_users_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/admin_api_client.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  List<dynamic> _users = [];
  int _total = 0;
  int _offset = 0;
  bool _loading = true;
  final _searchCtrl = TextEditingController();
  static const _limit = 20;

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
    final result = await ref.read(adminApiProvider).getUsers(
          limit: _limit,
          offset: reset ? 0 : _offset,
          search: _searchCtrl.text.trim().isEmpty
              ? null
              : _searchCtrl.text.trim(),
        );
    if (mounted) {
      setState(() {
        _users = result?['users'] as List<dynamic>? ?? [];
        _total = (result?['total'] as num?)?.toInt() ?? 0;
        _loading = false;
      });
    }
  }

  void _showUserSheet(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2035),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _UserDetailSheet(
        user: user,
        onRefresh: () => _load(),
      ),
    );
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
          title: const Text('Users',
              style:
                  TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Text('$_total total',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12)),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search name, email, phone…',
                  hintStyle:
                      const TextStyle(color: Colors.white38, fontSize: 14),
                  prefixIcon: const Icon(Icons.search,
                      color: Colors.white38, size: 20),
                  filled: true,
                  fillColor: const Color(0xFF1A2035),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color(0xFF4F8EF7), width: 1.5),
                  ),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.white38, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            _load(reset: true);
                          },
                        )
                      : null,
                ),
                onSubmitted: (_) => _load(reset: true),
                onChanged: (_) {
                  if (_searchCtrl.text.isEmpty) _load(reset: true);
                },
              ),
            ),

            // List
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation(Color(0xFF4F8EF7))))
                  : _users.isEmpty
                      ? const Center(
                          child: Text('No users found',
                              style: TextStyle(color: Colors.white38)))
                      : RefreshIndicator(
                          onRefresh: () => _load(reset: true),
                          color: const Color(0xFF4F8EF7),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            itemCount: _users.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                              final u = _users[i] as Map<String, dynamic>;
                              final suspended =
                                  u['is_suspended'] == true;
                              return GestureDetector(
                                onTap: () => _showUserSheet(u),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A2035),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.07)),
                                  ),
                                  child: Row(
                                    children: [
                                      // Avatar
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: const Color(
                                            0xFF4F8EF7)
                                            .withValues(alpha: 0.2),
                                        child: Text(
                                          (u['name'] as String? ?? 'U')
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style: const TextStyle(
                                              color: Color(0xFF4F8EF7),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              u['name'] as String? ?? '—',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  fontSize: 14),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              u['email'] as String? ?? '',
                                              style: const TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: suspended
                                              ? Colors.red
                                                  .withValues(alpha: 0.15)
                                              : Colors.green
                                                  .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          suspended
                                              ? 'Suspended'
                                              : 'Active',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: suspended
                                                ? Colors.redAccent
                                                : Colors.greenAccent,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.chevron_right,
                                          color: Colors.white24, size: 18),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),

            // Pagination
            if (_total > _limit)
              Padding(
                padding: const EdgeInsets.all(16),
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
                                setState(() =>
                                    _offset = (_offset - _limit).clamp(
                                        0, _total));
                                _load();
                              },
                        child: const Text('← Prev',
                            style: TextStyle(color: Color(0xFF4F8EF7))),
                      ),
                      TextButton(
                        onPressed: _offset + _limit >= _total
                            ? null
                            : () {
                                setState(() => _offset += _limit);
                                _load();
                              },
                        child: const Text('Next →',
                            style: TextStyle(color: Color(0xFF4F8EF7))),
                      ),
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

// ── User detail bottom sheet ──────────────────────────────────────────────────
class _UserDetailSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onRefresh;

  const _UserDetailSheet({required this.user, required this.onRefresh});

  @override
  ConsumerState<_UserDetailSheet> createState() => _UserDetailSheetState();
}

class _UserDetailSheetState extends ConsumerState<_UserDetailSheet> {
  bool _loading = false;

  Future<void> _suspend(bool suspend) async {
    setState(() => _loading = true);
    final userId = (widget.user['id'] as num).toInt();
    await ref.read(adminApiProvider).suspendUser(userId, suspend: suspend);
    if (mounted) {
      Navigator.pop(context);
      widget.onRefresh();
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2035),
        title: const Text('Delete Account',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Permanently delete ${widget.user['name']}? This cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    setState(() => _loading = true);
    final userId = (widget.user['id'] as num).toInt();
    await ref.read(adminApiProvider).deleteUser(userId);
    if (mounted) {
      Navigator.pop(context);
      widget.onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    final suspended = u['is_suspended'] == true;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(children: [
            CircleAvatar(
              radius: 24,
              backgroundColor:
                  const Color(0xFF4F8EF7).withValues(alpha: 0.2),
              child: Text(
                (u['name'] as String? ?? 'U').substring(0, 1).toUpperCase(),
                style: const TextStyle(
                    color: Color(0xFF4F8EF7),
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(u['name'] as String? ?? '—',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  Text(u['email'] as String? ?? '',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12)),
                  Text(u['phone_number'] as String? ?? '',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: suspended
                    ? Colors.red.withValues(alpha: 0.15)
                    : Colors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                suspended ? 'Suspended' : 'Active',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: suspended ? Colors.redAccent : Colors.greenAccent,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          if (_loading)
            const Center(child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF4F8EF7))))
          else
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(
                      suspended ? Icons.check_circle_outline : Icons.block,
                      size: 16),
                  label: Text(suspended ? 'Reactivate' : 'Suspend'),
                  onPressed: () => _suspend(!suspended),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        suspended ? Colors.greenAccent : Colors.orangeAccent,
                    side: BorderSide(
                        color: suspended
                            ? Colors.greenAccent
                            : Colors.orangeAccent),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                  onPressed: _delete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ]),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
