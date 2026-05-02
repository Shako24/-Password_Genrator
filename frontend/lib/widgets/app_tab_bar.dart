import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../pages/home.dart';
import '../pages/generator.dart';
import '../pages/vault.dart';

class AppShell extends StatefulWidget {
  final int initialIndex;
  const AppShell({super.key, this.initialIndex = 0});

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  void goTo(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PGColors.bg,
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: const [Home(), Generator(), VaultPage()],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: PGColors.surface,
        selectedIndex: _index,
        onDestinationSelected: goTo,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.vpn_key_rounded), label: 'Generator'),
          NavigationDestination(icon: Icon(Icons.remove_red_eye_outlined), label: 'Vault'),
        ],
      ),
    );
  }
}
