import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PGColors {
  static const Color bg = Color(0xFFF7F7F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF1A1A1E);
  static const Color inkMuted = Color(0xFF6B6B7A);
  static const Color accent = Color(0xFFD4F06A);
  static const Color accentInk = Color(0xFF3A5A10);
  static const Color chip = Color(0xFFF0F0EC);
  static const Color line = Color(0xFFE4E4E0);
  static const Color danger = Color(0xFFD94F2B);
}

TextStyle uiText({
  double size = 14,
  FontWeight weight = FontWeight.w400,
  Color color = PGColors.ink,
}) {
  return GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color);
}

TextStyle monoText({
  double size = 14,
  FontWeight weight = FontWeight.w400,
  Color color = PGColors.ink,
}) {
  return GoogleFonts.jetBrainsMono(fontSize: size, fontWeight: weight, color: color);
}
