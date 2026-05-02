import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/login.dart';
import 'theme/colors.dart';
import 'widgets/app_tab_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: PGColors.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: PGColors.accent,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: PGColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: PGColors.line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: PGColors.line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: PGColors.ink, width: 1.2),
          ),
        ),
      ),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  Future<bool>? _loggedIn;

  @override
  void initState() {
    super.initState();
    _loggedIn = _checkJwt();
  }

  Future<bool> _checkJwt() async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt');
    return jwt != null && jwt.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _loggedIn,
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: PGColors.bg,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return (snap.data == true) ? const AppShell() : const LoginScreen();
      },
    );
  }
}
