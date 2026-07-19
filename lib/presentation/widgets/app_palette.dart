import 'package:flutter/material.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_colors.dart';

class AppPalette {
  const AppPalette(this.isDarkMode);

  final bool isDarkMode;

  Color get pageBackground =>
      isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
  Color get headerBackground => AppColors.darkHeader;
  Color get sectionContainer =>
      isDarkMode ? AppColors.darkSurface : AppColors.lightSurface;
  Color get tileBackground =>
      isDarkMode ? AppColors.darkTile : AppColors.lightSurfaceVariant;
  Color get primaryText =>
      isDarkMode ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
  Color get onHeader => AppColors.darkPrimaryText;
  Color get onHeaderMuted => AppColors.darkSecondaryText;
  Color get secondaryText =>
      isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
  Color get mutedText =>
      isDarkMode ? AppColors.darkMutedText : AppColors.lightMutedText;
  Color get accent => AppColors.brand;
}
