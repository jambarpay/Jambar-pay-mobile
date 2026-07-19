import 'package:flutter/material.dart';

abstract final class AppColors {
  static const brand = Color(0xFFF57C21);
  static const brandDark = Color(0xFF1C1A33);
  static const success = Color(0xFF11B777);
  static const warning = Color(0xFFF5A623);
  static const error = Color(0xFFD32F2F);

  static const lightBackground = Color(0xFFF7F7FB);
  static const lightSurface = Colors.white;
  static const lightSurfaceVariant = Color(0xFFEFEFFF);
  static const lightTile = Color(0xFFF0EEFF);
  static const lightPrimaryText = brandDark;
  static const lightSecondaryText = Color(0xFF6B6884);
  static const lightMutedText = Color(0xFF8A8898);
  static const lightBorder = Color(0xFFCBC9D3);

  static const darkBackground = Color(0xFF17162B);
  static const darkHeader = brandDark;
  static const darkSurface = Color(0xFF22203C);
  static const darkTile = Color(0xFF121123);
  static const darkPrimaryText = Colors.white;
  static const darkSecondaryText = Color(0xFFD5D4DE);
  static const darkMutedText = Color(0xFF787392);
  static const darkBorder = Color(0xFF343254);
}
