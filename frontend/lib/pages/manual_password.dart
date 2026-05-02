import 'package:flutter/material.dart';
import '../apis/backend.dart';
import '../theme/colors.dart';
import '../widgets/app_tab_bar.dart';

class ManualPassword extends StatefulWidget {
  const ManualPassword({super.key});

  @override
  State<ManualPassword> createState() => _ManualPasswordState();
}

class _ManualPasswordState extends State<ManualPassword> {
  final _formKey = GlobalKey<FormState>();
  final _site = TextEditingController();
  final _user = TextEditingController();
  final _pw = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _site.dispose();
    _user.dispose();
    _pw.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final res = await Backend.savePassword(
          _site.text.trim(), _user.text.trim(), _pw.text);
      if (!mounted) return;
      if (res.statusCode == 200) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (_) => const AppShell(initialIndex: 2)),
          (_) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Save failed (${res.statusCode})')));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PGColors.bg,
      appBar: AppBar(
        backgroundColor: PGColors.bg,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: PGColors.ink),
            onPressed: () => Navigator.of(context).pop()),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              Text('Enter your existing credentials',
                  style: uiText(
                      size: 22,
                      weight: FontWeight.w700,
                      color: PGColors.ink)),
              const SizedBox(height: 8),
              Text('These are stored encrypted on the server.',
                  style: uiText(size: 13, color: PGColors.inkMuted)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _site,
                decoration:
                    const InputDecoration(labelText: 'Site or app'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _user,
                decoration: const InputDecoration(
                    labelText: 'Username or email'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pw,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Password'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirm,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Confirm password'),
                validator: (v) =>
                    (v != _pw.text) ? "Passwords don't match" : null,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PGColors.chip,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(children: [
                  const Icon(Icons.shield_outlined, color: PGColors.ink),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                        'End-to-end encrypted in transit using RSA-OAEP.',
                        style:
                            uiText(size: 12, color: PGColors.inkMuted)),
                  ),
                ]),
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
        ),
      ),
    );
  }
}
