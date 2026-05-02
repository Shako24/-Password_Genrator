import 'dart:async';
import 'package:flutter/material.dart';
import '../apis/backend.dart';
import '../theme/colors.dart';
import '../utils/strength.dart';
import '../widgets/site_tile.dart';
import '../widgets/status_pill.dart';
import 'reveal_sheet.dart';

class VaultPage extends StatefulWidget {
  const VaultPage({super.key});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  final TextEditingController _search = TextEditingController();
  Timer? _debounce;
  List<String> _sites = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load([String? query]) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final raw = (query == null || query.isEmpty)
          ? await Backend.getSites()
          : await Backend.getSelectedSites(query);
      setState(() {
        _sites = raw.map((e) => e.toString()).toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce =
        Timer(const Duration(milliseconds: 500), () => _load(v.trim()));
  }

  Map<String, List<String>> _grouped() {
    final m = <String, List<String>>{};
    for (final s in _sites) {
      final k = s.isEmpty ? '#' : s[0].toUpperCase();
      m.putIfAbsent(k, () => []).add(s);
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Vault',
              style: uiText(
                  size: 28, weight: FontWeight.w700, color: PGColors.ink)),
          const SizedBox(height: 12),
          TextField(
            controller: _search,
            onChanged: _onSearch,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search sites',
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Text(_error!,
                            style: uiText(color: PGColors.danger)))
                    : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    final groups = _grouped();
    final keys = groups.keys.toList()..sort();
    return ListView.builder(
      itemCount:
          keys.fold<int>(0, (acc, k) => acc + 1 + groups[k]!.length),
      itemBuilder: (_, idx) {
        int running = 0;
        for (final k in keys) {
          if (idx == running) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(k,
                  style: uiText(
                      size: 12,
                      weight: FontWeight.w700,
                      color: PGColors.inkMuted)),
            );
          }
          running += 1;
          final count = groups[k]!.length;
          if (idx < running + count) {
            final site = groups[k]![idx - running];
            return _row(site);
          }
          running += count;
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _row(String site) {
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
              child: Text(site,
                  style: uiText(
                      size: 15,
                      weight: FontWeight.w600,
                      color: PGColors.ink)),
            ),
            const StatusPill(strength: Strength.fair),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: PGColors.inkMuted),
          ],
        ),
      ),
    );
  }
}
