// Extensions on BuildContext for concise access to common theme properties.
import 'package:flutter/material.dart';

extension ContextX on BuildContext {
  // ── Theme ─────────────────────────────────────────────────────────────────
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  // ── MediaQuery ────────────────────────────────────────────────────────────
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  // ── Navigation ────────────────────────────────────────────────────────────
  bool get canPop => Navigator.canPop(this);
  void pop<T>([T? result]) => Navigator.pop(this, result);
}
