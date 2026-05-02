import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../apis/backend.dart';
import '../theme/colors.dart';
import '../utils/generator.dart' as pg;
import '../utils/strength.dart';
import '../widgets/site_tile.dart';
import '../widgets/status_pill.dart';

class RevealSheet extends StatefulWidget {
  final String site;
  const RevealSheet({super.key, required this.site});

  @override
  State<RevealSheet> createState() => _RevealSheetState();
}

class _RevealSheetState extends State<RevealSheet> {
  Future<List<dynamic>>? _load;
  String _username = '';
  String _password = '';
  bool _obscure = true;
  bool _editing = false;
  bool _saving = false;
  final _userCtl = TextEditingController();
  final _pwCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load = _fetch();
  }

  @override
  void dispose() {
    _userCtl.dispose();
    _pwCtl.dispose();
    super.dispose();
  }

  Future<List<dynamic>> _fetch() async {
    final rows = await Backend.getPassword(widget.site);
    if (rows.isNotEmpty) {
      final first = rows.first as Map<String, dynamic>;
      _username = (first['userName'] ?? first['username'] ?? '').toString();
      _password = (first['password'] ?? '').toString();
      _userCtl.text = _username;
      _pwCtl.text = _password;
    }
    return rows;
  }

  Future<void> _saveEdits() async {
    setState(() => _saving = true);
    try {
      final res = await Backend.updatePassword(
          widget.site, _userCtl.text.trim(), _pwCtl.text);
      if (!mounted) return;
      if (res.statusCode == 200) {
        setState(() {
          _username = _userCtl.text.trim();
          _password = _pwCtl.text;
          _editing = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Updated')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Update failed (${res.statusCode})')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _rotate() async {
    final fresh = pg.PasswordGenerator.generate(length: 20);
    setState(() => _pwCtl.text = fresh);
    await _saveEdits();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (ctx, scroll) => Container(
        decoration: const BoxDecoration(
          color: PGColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: FutureBuilder<List<dynamic>>(
          future: _load,
          builder: (_, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(
                  child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator()));
            }
            if (snap.hasError) {
              return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Failed: ${snap.error}',
                      style: uiText(color: PGColors.danger)));
            }
            return ListView(
              controller: scroll,
              padding: const EdgeInsets.all(20),
              children: [
                Row(children: [
                  SiteTile(site: widget.site, size: 48),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(widget.site,
                        style: uiText(
                            size: 20,
                            weight: FontWeight.w700,
                            color: PGColors.ink)),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _editing = !_editing),
                    icon: Icon(_editing ? Icons.close : Icons.edit_outlined),
                  ),
                ]),
                const SizedBox(height: 20),
                _field(
                  label: 'Username',
                  controller: _userCtl,
                  obscure: false,
                  trailing: IconButton(
                    onPressed: () =>
                        Clipboard.setData(ClipboardData(text: _userCtl.text)),
                    icon: const Icon(Icons.copy),
                  ),
                ),
                const SizedBox(height: 12),
                _field(
                  label: 'Password',
                  controller: _pwCtl,
                  obscure: _obscure,
                  mono: true,
                  trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                            icon: Icon(_obscure
                                ? Icons.visibility
                                : Icons.visibility_off)),
                        IconButton(
                            onPressed: () => Clipboard.setData(
                                ClipboardData(text: _pwCtl.text)),
                            icon: const Icon(Icons.copy)),
                      ]),
                ),
                const SizedBox(height: 20),
                _strengthBlock(),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: PGColors.accent,
                        foregroundColor: PGColors.accentInk,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _saving
                          ? null
                          : (_editing
                              ? _saveEdits
                              : () => Clipboard.setData(
                                  ClipboardData(text: _pwCtl.text))),
                      child: Text(
                          _editing ? 'Save changes' : 'Copy password',
                          style: uiText(
                              size: 15,
                              weight: FontWeight.w600,
                              color: PGColors.accentInk)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _saving ? null : _rotate,
                    icon: const Icon(Icons.refresh),
                    style: IconButton.styleFrom(
                      backgroundColor: PGColors.chip,
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                ]),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    bool mono = false,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: PGColors.surface,
        border: Border.all(color: PGColors.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              readOnly: !_editing,
              style: mono
                  ? monoText(color: PGColors.ink)
                  : uiText(color: PGColors.ink),
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _strengthBlock() {
    final strength = passwordStrength(_pwCtl.text);
    final filled = switch (strength) {
      Strength.strong => 5,
      Strength.fair => 3,
      Strength.weak => 1,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text('Strength',
              style: uiText(
                  size: 13,
                  weight: FontWeight.w600,
                  color: PGColors.inkMuted)),
          const Spacer(),
          StatusPill(strength: strength),
        ]),
        const SizedBox(height: 8),
        Row(
            children: List.generate(
                5,
                (i) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i == 4 ? 0 : 4),
                        height: 6,
                        decoration: BoxDecoration(
                          color: i < filled ? PGColors.ink : PGColors.chip,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ))),
        const SizedBox(height: 6),
        Text('${_pwCtl.text.length} chars',
            style: uiText(size: 12, color: PGColors.inkMuted)),
      ],
    );
  }
}
