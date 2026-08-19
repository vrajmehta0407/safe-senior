// lib/screens/admin/admin_patterns_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/admin_api_client.dart';

class AdminPatternsScreen extends ConsumerStatefulWidget {
  const AdminPatternsScreen({super.key});

  @override
  ConsumerState<AdminPatternsScreen> createState() =>
      _AdminPatternsScreenState();
}

class _AdminPatternsScreenState extends ConsumerState<AdminPatternsScreen> {
  List<dynamic> _patterns = [];
  int _total = 0;
  int _offset = 0;
  bool _loading = true;
  String? _filterSeverity;
  String? _filterActive;
  static const _limit = 50;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) setState(() => _offset = 0);
    setState(() => _loading = true);
    final result = await ref.read(adminApiProvider).getPatterns(
          limit: _limit,
          offset: reset ? 0 : _offset,
          severity: _filterSeverity,
          active: _filterActive,
        );
    if (mounted) {
      setState(() {
        _patterns = result?['patterns'] as List<dynamic>? ?? [];
        _total = (result?['total'] as num?)?.toInt() ?? 0;
        _loading = false;
      });
    }
  }

  void _showCreateDialog() => _showPatternDialog(null);

  void _showEditDialog(Map<String, dynamic> pattern) =>
      _showPatternDialog(pattern);

  void _showPatternDialog(Map<String, dynamic>? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A2035),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _PatternForm(
        existing: existing,
        onSaved: () => _load(reset: existing == null),
      ),
    );
  }

  Future<void> _deactivate(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2035),
        title: const Text('Deactivate Pattern',
            style: TextStyle(color: Colors.white)),
        content: const Text('This will hide the pattern from the app.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Deactivate',
                  style: TextStyle(color: Colors.orangeAccent))),
        ],
      ),
    );
    if (confirm != true) return;
    await ref.read(adminApiProvider).deactivatePattern(id);
    _load();
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
          title: Text('Patterns ($_total)',
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w600)),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _showCreateDialog,
              tooltip: 'New pattern',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showCreateDialog,
          backgroundColor: const Color(0xFF4F8EF7),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('New Pattern',
              style: TextStyle(color: Colors.white)),
        ),
        body: Column(
          children: [
            // Filters
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                Expanded(
                  child: _Drop(
                    value: _filterSeverity,
                    hint: 'Severity',
                    items: const ['high-risk', 'suspicious'],
                    onChanged: (v) {
                      setState(() => _filterSeverity = v);
                      _load(reset: true);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Drop(
                    value: _filterActive,
                    hint: 'Status',
                    items: const ['true', 'false'],
                    labels: const ['Active', 'Inactive'],
                    onChanged: (v) {
                      setState(() => _filterActive = v);
                      _load(reset: true);
                    },
                  ),
                ),
              ]),
            ),

            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation(Color(0xFF4F8EF7))))
                  : _patterns.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.security,
                                  color: Colors.white24, size: 40),
                              const SizedBox(height: 12),
                              const Text('No patterns found',
                                  style:
                                      TextStyle(color: Colors.white38)),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _showCreateDialog,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF4F8EF7)),
                                child: const Text('Add First Pattern'),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => _load(reset: true),
                          color: const Color(0xFF4F8EF7),
                          child: ListView.separated(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            itemCount: _patterns.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                              final p =
                                  _patterns[i] as Map<String, dynamic>;
                              final active = p['is_active'] == true;
                              final sev =
                                  p['severity'] as String? ?? '';
                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A2035),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: active
                                          ? Colors.white
                                              .withValues(alpha: 0.07)
                                          : Colors.white
                                              .withValues(alpha: 0.03)),
                                ),
                                child: Row(children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          _Chip(
                                              label: sev,
                                              color: sev == 'high-risk'
                                                  ? Colors.redAccent
                                                  : Colors.orangeAccent),
                                          const SizedBox(width: 6),
                                          _Chip(
                                              label:
                                                  p['type'] as String? ??
                                                      '',
                                              color:
                                                  const Color(0xFF4F8EF7)),
                                          const SizedBox(width: 6),
                                          if (!active)
                                            _Chip(
                                                label: 'Inactive',
                                                color: Colors.white38),
                                        ]),
                                        const SizedBox(height: 8),
                                        Text(
                                          p['pattern'] as String? ?? '',
                                          style: TextStyle(
                                            color: active
                                                ? Colors.white
                                                : Colors.white38,
                                            fontSize: 13,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if ((p['category'] as String?)
                                                ?.isNotEmpty ==
                                            true) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            p['category'] as String,
                                            style: const TextStyle(
                                                color: Colors.white38,
                                                fontSize: 11),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined,
                                          color: Color(0xFF4F8EF7),
                                          size: 18),
                                      onPressed: () => _showEditDialog(p),
                                    ),
                                    if (active)
                                      IconButton(
                                        icon: const Icon(
                                            Icons.visibility_off_outlined,
                                            color: Colors.orangeAccent,
                                            size: 18),
                                        onPressed: () => _deactivate(
                                            (p['id'] as num).toInt()),
                                      ),
                                  ]),
                                ]),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pattern create/edit form ──────────────────────────────────────────────────
class _PatternForm extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existing;
  final VoidCallback onSaved;

  const _PatternForm({this.existing, required this.onSaved});

  @override
  ConsumerState<_PatternForm> createState() => _PatternFormState();
}

class _PatternFormState extends ConsumerState<_PatternForm> {
  final _formKey     = GlobalKey<FormState>();
  late final TextEditingController _patternCtrl;
  late final TextEditingController _categoryCtrl;
  String _type     = 'sms';
  String _severity = 'suspicious';
  bool _active     = true;
  bool _saving     = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _patternCtrl  = TextEditingController(text: e?['pattern'] as String? ?? '');
    _categoryCtrl = TextEditingController(text: e?['category'] as String? ?? '');
    _type         = e?['type']     as String? ?? 'sms';
    _severity     = e?['severity'] as String? ?? 'suspicious';
    _active       = e?['is_active'] as bool? ?? true;
  }

  @override
  void dispose() {
    _patternCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; _error = null; });
    final body = {
      'pattern':   _patternCtrl.text.trim(),
      'type':      _type,
      'severity':  _severity,
      'category':  _categoryCtrl.text.trim(),
      'is_active': _active,
    };
    Map<String, dynamic>? result;
    if (widget.existing != null) {
      result = await ref.read(adminApiProvider)
          .updatePattern((widget.existing!['id'] as num).toInt(), body);
    } else {
      result = await ref.read(adminApiProvider).createPattern(body);
    }
    if (!mounted) return;
    if (result?['success'] == true) {
      Navigator.pop(context);
      widget.onSaved();
    } else {
      setState(() {
        _error = result?['message'] as String? ?? 'Save failed.';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20, right: 20, top: 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            Text(isEdit ? 'Edit Pattern' : 'New Pattern',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 16),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_error!,
                    style:
                        const TextStyle(color: Colors.redAccent, fontSize: 13)),
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: _patternCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: _inputDeco('Pattern text *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _DropField(
                  label: 'Type',
                  value: _type,
                  items: const ['sms', 'call', 'both'],
                  onChanged: (v) => setState(() => _type = v!),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DropField(
                  label: 'Severity',
                  value: _severity,
                  items: const ['suspicious', 'high-risk'],
                  onChanged: (v) => setState(() => _severity = v!),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            TextFormField(
              controller: _categoryCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: _inputDeco('Category (optional)'),
            ),
            if (isEdit) ...[
              const SizedBox(height: 12),
              Row(children: [
                const Text('Active',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 14)),
                const Spacer(),
                Switch(
                  value: _active,
                  onChanged: (v) => setState(() => _active = v),
                  activeColor: const Color(0xFF4F8EF7),
                ),
              ]),
            ],
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F8EF7),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: _saving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation(Colors.white)))
                    : Text(isEdit ? 'Save Changes' : 'Create Pattern',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF252D40),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFF4F8EF7), width: 1.5),
        ),
      );
}

class _DropField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final void Function(String?) onChanged;

  const _DropField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF252D40),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(label,
              style:
                  const TextStyle(color: Colors.white38, fontSize: 11)),
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: const Color(0xFF1A2035),
            items: items.map((v) => DropdownMenuItem(
                  value: v,
                  child: Text(v,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13)),
                )).toList(),
            onChanged: onChanged,
            iconEnabledColor: Colors.white38,
          ),
        ),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w600, color: color)),
      );
}

class _Drop extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final List<String>? labels;
  final void Function(String?) onChanged;

  const _Drop({
    required this.value,
    required this.hint,
    required this.items,
    this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2035),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: value,
            hint: Text(hint,
                style: const TextStyle(
                    color: Colors.white38, fontSize: 13)),
            dropdownColor: const Color(0xFF1A2035),
            isExpanded: true,
            items: [
              DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13))),
              ...items.asMap().entries.map((e) => DropdownMenuItem<String?>(
                    value: e.value,
                    child: Text(labels?[e.key] ?? e.value,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13)),
                  )),
            ],
            onChanged: onChanged,
            iconEnabledColor: Colors.white38,
          ),
        ),
      );
}
