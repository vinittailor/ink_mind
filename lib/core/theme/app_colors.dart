// InkMind color palette.
//
// All raw color values live here. Feature code and widgets reference these
// constants (or the ColorScheme produced by AppTheme) — never hard-coded
// hex values inline.
import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // prevent instantiation

  // ── Brand / Primary ────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF7C6FD8);       // soft indigo-violet
  static const Color primaryLight = Color(0xFFAFA4EE);
  static const Color primaryDark = Color(0xFF4B3FC0);

  // ── Secondary ─────────────────────────────────────────────────────────────
  static const Color secondary = Color(0xFF63C5C2);     // teal-mint accent
  static const Color secondaryLight = Color(0xFF98DED9);
  static const Color secondaryDark = Color(0xFF3A9B98);

  // ── Neutrals (dark-mode background scale) ─────────────────────────────────
  static const Color surface = Color(0xFF1A1A2E);       // deep navy background
  static const Color surfaceVariant = Color(0xFF16213E);
  static const Color card = Color(0xFF212144);          // card / sheet background

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color onSurface = Color(0xFFEAEAF4);     // primary text
  static const Color onSurfaceMuted = Color(0xFF8888AA); // secondary / hint text

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF4CAF82);
  static const Color warning = Color(0xFFFFB347);
}
