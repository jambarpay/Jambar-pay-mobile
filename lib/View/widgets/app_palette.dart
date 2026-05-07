import 'package:flutter/material.dart';

class AppPalette {
  const AppPalette(this.isDarkMode);

  final bool isDarkMode;

  Color get pageBackground =>
      isDarkMode ? const Color(0xFF17162B) : const Color(0xFFF7F7FB);
  Color get headerBackground => const Color(0xFF1C1A33);
  Color get sectionContainer =>
      isDarkMode ? const Color(0xFF22203C) : Colors.white;
  Color get tileBackground =>
      isDarkMode ? const Color(0xFF121123) : const Color(0xFFEFEFFF);
  Color get primaryText => Colors.white;
  Color get secondaryText =>
      isDarkMode ? const Color(0xFFD5D4DE) : const Color(0xFFD5D4DE);
  Color get mutedText =>
      isDarkMode ? const Color(0xFF787392) : const Color(0xFF1C1A33);
  Color get accent => const Color(0xFFF57C21);
}
