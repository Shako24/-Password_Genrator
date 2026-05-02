import 'package:flutter/material.dart';
import '../apis/backend.dart';
import '../theme/colors.dart';
import '../widgets/app_tab_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController();
  final _pw = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _username.dispose();
    _pw.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final res = await Backend.login(_username.text.trim(), _pw.text);
      if (!mounted) return;
      if (res.statusCode == 200) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AppShell()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed (${res.statusCode})')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login error: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PGColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Text('Welcome back',
                  style: uiText(
                      size: 28, weight: FontWeight.w700, color: PGColors.ink)),
              const SizedBox(height: 8),
              Text('Sign in to your vault',
                  style: uiText(size: 14, color: PGColors.inkMuted)),
              const SizedBox(height: 32),
              TextField(
                controller: _username,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pw,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 32),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: PGColors.accent,
                  foregroundColor: PGColors.accentInk,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text('Sign in',
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
