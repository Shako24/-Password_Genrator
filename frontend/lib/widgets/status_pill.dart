import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../utils/strength.dart';

class StatusPill extends StatelessWidget {
  final Strength strength;
  const StatusPill({super.key, required this.strength});

  Color _bg() {
    switch (strength) {
      case Strength.strong: return PGColors.accent;
      case Strength.fair:   return PGColors.chip;
      case Strength.weak:   return const Color(0xFFFBDDD2);
    }
  }

  Color _fg() {
    switch (strength) {
      case Strength.strong: return PGColors.accentInk;
      case Strength.fair:   return PGColors.ink;
      case Strength.weak:   return PGColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg(),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        strengthLabel(strength),
        style: uiText(size: 12, weight: FontWeight.w600, color: _fg()),
      ),
    );
  }
}
