import 'package:flutter/material.dart';

abstract final class AppTypography {
  static TextTheme from(TextTheme base) {
    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      headlineSmall: base.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}
