import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jambar_pay_mobile/app/router/app_router.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_breakpoints.dart';
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
    required this.onLogout,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;
  final AppState appState;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);
    final pages = <Widget>[
      HomeDashboard(
        onTabSelected: onTabSelected,
        isDarkMode: isDarkMode,
        appState: appState,
      ),
      HistoryScreen(
        isDarkMode: isDarkMode,
        userProfile: appState.userProfile,
        wallet: appState.wallet,
        onQrTap: () => context.push(AppRoutes.qr),
      ),
      RestaurantsScreen(
        onBackHome: () => onTabSelected(0),
        isDarkMode: isDarkMode,
        userProfile: appState.userProfile,
        wallet: appState.wallet,
        onQrTap: () => context.push(AppRoutes.qr),
      ),
      ProfileScreen(
        onBackHome: () => onTabSelected(0),
        isDarkMode: isDarkMode,
        onDarkModeChanged: onDarkModeChanged,
        userProfile: appState.userProfile,
        wallet: appState.wallet,
        onLogout: onLogout,
      ),
    ];

    final selectedIndex = currentIndex.clamp(0, pages.length - 1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final content = IndexedStack(index: selectedIndex, children: pages);
        if (constraints.maxWidth < AppBreakpoints.medium) {
          return Scaffold(
            backgroundColor: palette.pageBackground,
            body: content,
            bottomNavigationBar: HomeBottomNavigation(
              currentIndex: selectedIndex,
              onTap: onTabSelected,
              isDarkMode: isDarkMode,
            ),
          );
        }

        return Scaffold(
          backgroundColor: palette.pageBackground,
          body: Row(
            children: [
              HomeNavigationRail(
                currentIndex: selectedIndex,
                onTap: onTabSelected,
                isDarkMode: isDarkMode,
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppBreakpoints.maxContentWidth,
                    ),
                    child: content,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
