import 'package:flutter/material.dart';
import '../apis/backend.dart';
import '../theme/colors.dart';
import '../utils/generator.dart' as pg;
import '../utils/strength.dart';
import '../widgets/status_pill.dart';

class Generator extends StatefulWidget {
  const Generator({super.key});

  @override
  State<Generator> createState() => _GeneratorState();
}

class _GeneratorState extends State<Generator> {
  double _length = 16;
  bool _uppercase = true;
  bool _numbers = true;
  bool _symbols = true;
  String _preview = '';

  final _site = TextEditingController();
  final _user = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _regenerate();
  }

  @override
  void dispose() {
    _site.dispose();
    _user.dispose();
    super.dispose();
  }

  void _regenerate() {
    setState(() {
      _preview = pg.PasswordGenerator.generate(
        length: _length.round(),
        uppercase: _uppercase,
        numbers: _numbers,
        symbols: _symbols,
      );
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_site.text.trim().isEmpty || _user.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Site and username are required')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final res = await Backend.savePassword(
          _site.text.trim(), _user.text.trim(), _preview);
      if (!mounted) return;
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Password saved')));
      } else {
        _showError('Save failed (${res.statusCode})');
      }
    } catch (e) {
      if (mounted) _showError('$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String msg) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Error'),
              content: Text(msg),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'))
              ],
            ));
  }

  Widget _chip(String label, bool value, ValueChanged<bool> onChanged) {
    return FilterChip(
      label: Text(label),
      selected: value,
      onSelected: (v) {
        onChanged(v);
        _regenerate();
      },
      selectedColor: PGColors.accent,
      backgroundColor: PGColors.chip,
      showCheckmark: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strength = passwordStrength(_preview);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: ListView(
        children: [
          Text('Generator',
              style: uiText(
                  size: 28, weight: FontWeight.w700, color: PGColors.ink)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: PGColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PGColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        _preview,
                        style: monoText(size: 18, color: PGColors.ink),
                      ),
                    ),
                    IconButton(
                        onPressed: _regenerate,
                        icon: const Icon(Icons.refresh)),
                  ],
                ),
                const SizedBox(height: 8),
                StatusPill(strength: strength),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Text('Length',
                style: uiText(
                    size: 14,
                    weight: FontWeight.w600,
                    color: PGColors.ink)),
            const Spacer(),
            Text('${_length.round()}',
                style: monoText(size: 16, color: PGColors.ink)),
          ]),
          Slider(
            value: _length,
            min: 8,
            max: 32,
            divisions: 24,
            activeColor: PGColors.ink,
            onChanged: (v) => setState(() => _length = v),
            onChangeEnd: (_) => _regenerate(),
          ),
          Wrap(spacing: 8, children: [
            _chip('Uppercase', _uppercase, (v) => setState(() => _uppercase = v)),
            _chip('Numbers', _numbers, (v) => setState(() => _numbers = v)),
            _chip('Symbols', _symbols, (v) => setState(() => _symbols = v)),
          ]),
          const SizedBox(height: 20),
          TextField(
            controller: _site,
            decoration: const InputDecoration(labelText: 'Site or app'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _user,
            decoration:
                const InputDecoration(labelText: 'Username or email'),
          ),
          const SizedBox(height: 20),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: PGColors.accent,
              foregroundColor: PGColors.accentInk,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text('Save to vault',
                    style: uiText(
                        size: 16,
                        weight: FontWeight.w600,
                        color: PGColors.accentInk)),
          ),
        ],
      ),
    );
  }
}
