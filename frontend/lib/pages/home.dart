import 'package:flutter/material.dart';
import '../apis/backend.dart';
import '../theme/colors.dart';
import '../widgets/app_tab_bar.dart';
import '../widgets/site_tile.dart';
import 'manual_password.dart';
import 'reveal_sheet.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<List<dynamic>>? _sites;

  @override
  void initState() {
    super.initState();
    _sites = Backend.getSites();
  }

  void _goTab(int i) {
    context.findAncestorStateOfType<AppShellState>()?.goTo(i);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: ListView(
        children: [
          _Header(),
          const SizedBox(height: 16),
          _vaultCard(),
          const SizedBox(height: 16),
          _actionGrid(context),
          const SizedBox(height: 24),
          Text('Recents',
              style: uiText(
                  size: 14,
                  weight: FontWeight.w700,
                  color: PGColors.inkMuted)),
          const SizedBox(height: 8),
          FutureBuilder<List<dynamic>>(
            future: _sites,
            builder: (ctx, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()));
              }
              if (snap.hasError) {
                return Text('Failed to load: ${snap.error}',
                    style: uiText(color: PGColors.danger));
              }
              final sites = (snap.data ?? [])
                  .map((e) => e.toString())
                  .take(4)
                  .toList();
              return Column(children: sites.map(_recentRow).toList());
            },
          ),
        ],
      ),
    );
  }

  Widget _vaultCard() {
    return FutureBuilder<List<dynamic>>(
      future: _sites,
      builder: (ctx, snap) {
        final count = (snap.data ?? []).length;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: PGColors.ink,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                    color: PGColors.accent, shape: BoxShape.circle),
                child: const Icon(Icons.lock_outline, color: PGColors.accentInk),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$count passwords',
                        style: uiText(
                            size: 20,
                            weight: FontWeight.w700,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('Tap to open vault',
                        style: uiText(size: 13, color: Colors.white70)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                onPressed: () => _goTab(2),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _actionGrid(BuildContext context) {
    Widget tile({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
      bool primary = false,
    }) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primary ? PGColors.ink : PGColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PGColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon,
                    color: primary ? PGColors.accent : PGColors.ink),
                const SizedBox(height: 12),
                Text(label,
                    style: uiText(
                        size: 14,
                        weight: FontWeight.w600,
                        color: primary ? Colors.white : PGColors.ink)),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(children: [
          tile(
              icon: Icons.bolt,
              label: 'Generate',
              primary: true,
              onTap: () => _goTab(1)),
          const SizedBox(width: 12),
          tile(
              icon: Icons.remove_red_eye_outlined,
              label: 'Vault',
              onTap: () => _goTab(2)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          tile(
            icon: Icons.save_outlined,
            label: 'Save manually',
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ManualPassword())),
          ),
          const SizedBox(width: 12),
          tile(
              icon: Icons.refresh, label: 'Update', onTap: () => _goTab(2)),
        ]),
      ],
    );
  }

  Widget _recentRow(String site) {
    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => RevealSheet(site: site),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SiteTile(site: site),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(site,
                      style: uiText(
                          size: 15,
                          weight: FontWeight.w600,
                          color: PGColors.ink)),
                  const SizedBox(height: 2),
                  Text('Tap to reveal',
                      style: uiText(size: 12, color: PGColors.inkMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: PGColors.inkMuted),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final date = '${months[now.month - 1]} ${now.day}';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: uiText(size: 12, color: PGColors.inkMuted)),
              Text('Your vault',
                  style: uiText(
                      size: 22,
                      weight: FontWeight.w700,
                      color: PGColors.ink)),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              color: PGColors.chip, shape: BoxShape.circle),
          child: Text('U',
              style: uiText(
                  size: 16, weight: FontWeight.w600, color: PGColors.ink)),
        ),
      ],
    );
  }
}
