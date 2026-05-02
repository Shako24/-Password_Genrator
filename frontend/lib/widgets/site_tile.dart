import 'package:flutter/material.dart';
import '../theme/colors.dart';

class SiteTile extends StatelessWidget {
  final String site;
  final double size;

  const SiteTile({super.key, required this.site, this.size = 36});

  int _hash(String s) {
    int h = 0;
    for (final code in s.toLowerCase().codeUnits) {
      h = (h * 31 + code) & 0x7fffffff;
    }
    return h;
  }

  Color _bgColor() {
    final hue = (_hash(site) % 360).toDouble();
    return HSLColor.fromAHSL(1, hue, 0.55, 0.72).toColor();
  }

  String _initials() {
    final trimmed = site.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return (trimmed.length >= 2 ? trimmed.substring(0, 2) : trimmed).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _bgColor(),
          borderRadius: BorderRadius.circular(size / 4),
        ),
        child: Text(
          _initials(),
          style: uiText(
            size: size * 0.35,
            weight: FontWeight.w700,
            color: PGColors.ink,
          ),
        ),
      ),
    );
  }
}
