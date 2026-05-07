import 'package:flutter/material.dart';
import '../models/mobile_employee_space.dart';
import '../widgets/app_palette.dart';
import '../widgets/home_widgets.dart';
import 'home_dashboard.dart';
import 'history_screen.dart';
import 'restaurants_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.isDarkMode,
    required this.onDarkModeChanged,
    required this.appState,
    required this.onChangeSecretCode,
    required this.onPaymentCompleted,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;
  final AppState appState;
  final String? Function(String currentPin, String newPin) onChangeSecretCode;
  final void Function(QRScanResultModel, PaymentResultModel) onPaymentCompleted;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);

    return Scaffold(
      backgroundColor: palette.pageBackground,
      body: switch (currentIndex) {
        0 => HomeDashboard(
            onTabSelected: onTabSelected,
            isDarkMode: isDarkMode,
            appState: appState,
            onPaymentCompleted: onPaymentCompleted,
          ),
        1 => HistoryScreen(
            isDarkMode: isDarkMode,
          ),
        2 => RestaurantsScreen(
            onBackHome: () => onTabSelected(0),
            isDarkMode: isDarkMode,
            restaurants: appState.restaurants,
          ),
        3 => ProfileScreen(
            onBackHome: () => onTabSelected(0),
            isDarkMode: isDarkMode,
            onDarkModeChanged: onDarkModeChanged,
            userProfile: appState.userProfile,
            onChangeSecretCode: onChangeSecretCode,
          ),
        _ => HomeDashboard(
            onTabSelected: onTabSelected,
            isDarkMode: isDarkMode,
            appState: appState,
            onPaymentCompleted: onPaymentCompleted,
          ),
      },
      bottomNavigationBar: HomeBottomNavigation(
        currentIndex: currentIndex,
        onTap: onTabSelected,
        isDarkMode: isDarkMode,
      ),
    );
  }
}
