import 'package:flutter/material.dart';

extension ThemeColors on BuildContext {
  Color get surfaceColor => Theme.of(this).colorScheme.surface;
  Color get scaffoldBgColor => Theme.of(this).scaffoldBackgroundColor;
  Color get onSurfaceColor => Theme.of(this).colorScheme.onSurface;
  Color get cardColor => Theme.of(this).cardTheme.color ?? Theme.of(this).colorScheme.surface;
  Color get textOnSurface => Theme.of(this).colorScheme.onSurface;
  Color get textSecondaryColor => Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.6);
  Color get appBarColor => Theme.of(this).appBarTheme.backgroundColor ?? surfaceColor;
}
