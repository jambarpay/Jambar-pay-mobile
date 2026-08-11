import 'package:flutter/material.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_colors.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_durations.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_radius.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import '../models/mobile_employee_space.dart';
import 'balance_card.dart';
import 'app_palette.dart';

class EmployeeHeroHeader extends StatelessWidget {
  const EmployeeHeroHeader({
    super.key,
    required this.userProfile,
    required this.wallet,
    required this.onQrTap,
    this.isDarkMode = false,
    this.showBalanceCard = true,
  });

  final UserProfileModel userProfile;
  final WalletSummaryModel? wallet;
  final VoidCallback onQrTap;
  final bool isDarkMode;
  final bool showBalanceCard;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 42, 22, 18),
      color: palette.headerBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour',
                      style: TextStyle(
                        color: palette.onHeaderMuted,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userProfile.name,
                      style: TextStyle(
                        color: palette.onHeader,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.brand,
                child: Text(
                  userProfile.name.isEmpty
                      ? '?'
                      : userProfile.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (showBalanceCard) ...[
            const SizedBox(height: 16),
            BalanceCard(
              isDarkMode: isDarkMode,
              wallet: wallet,
              onQrTap: onQrTap,
            ),
          ],
        ],
      ),
    );
  }
}

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({
    super.key,
    required this.scanLabel,
    required this.restaurantsLabel,
    required this.historyLabel,
    required this.statementLabel,
    required this.onScan,
    required this.onRestaurants,
    required this.onHistory,
    required this.onStatement,
    this.isDarkMode = false,
  });

  final String scanLabel;
  final String restaurantsLabel;
  final String historyLabel;
  final String statementLabel;
  final VoidCallback onScan;
  final VoidCallback onRestaurants;
  final VoidCallback onHistory;
  final VoidCallback onStatement;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);
    final actions =
        <({IconData icon, String title, String subtitle, VoidCallback onTap})>[
          (
            icon: Icons.photo_camera_outlined,
            title: scanLabel,
            subtitle: 'Payer au restaurant',
            onTap: onScan,
          ),
          (
            icon: Icons.restaurant_outlined,
            title: restaurantsLabel,
            subtitle: 'Près de moi',
            onTap: onRestaurants,
          ),
          (
            icon: Icons.bar_chart_rounded,
            title: 'Ce mois',
            subtitle: 'Voir mes repas',
            onTap: onHistory,
          ),
          (
            icon: Icons.description_outlined,
            title: statementLabel,
            subtitle: 'Exporter PDF',
            onTap: onStatement,
          ),
        ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 4),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: actions.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.55,
        ),
        itemBuilder: (context, index) {
          final action = actions[index];
          return Material(
            color: isDarkMode ? palette.tileBackground : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            elevation: 0,
            child: InkWell(
              onTap: action.onTap,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDarkMode
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowSubtle,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(action.icon, color: AppColors.brand, size: 27),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          action.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.primaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          action.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.mutedText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isDarkMode = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);
    final loc = AppLocalizations.of(context);
    final items = <({IconData icon, String label})>[
      (icon: Icons.home_rounded, label: loc.home),
      (icon: Icons.history_rounded, label: loc.history),
      (icon: Icons.restaurant_rounded, label: loc.restaurants),
      (icon: Icons.person_rounded, label: loc.profile),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : Colors.white,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSubtle,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = index == currentIndex;

            return Expanded(
              child: InkWell(
                onTap: () => onTap(index),
                borderRadius: BorderRadius.circular(AppRadius.navigation),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        color: isSelected
                            ? palette.accent
                            : (isDarkMode
                                  ? palette.onHeader
                                  : AppColors.lightMutedText),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected
                              ? palette.accent
                              : (isDarkMode
                                    ? palette.onHeader
                                    : AppColors.lightMutedText),
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class HomeNavigationRail extends StatelessWidget {
  const HomeNavigationRail({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isDarkMode = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);
    final loc = AppLocalizations.of(context);
    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: isDarkMode ? palette.headerBackground : Colors.white,
      indicatorColor: palette.accent.withValues(alpha: 0.18),
      selectedIconTheme: IconThemeData(color: palette.accent),
      unselectedIconTheme: IconThemeData(
        color: isDarkMode ? palette.onHeader : AppColors.lightMutedText,
      ),
      selectedLabelTextStyle: TextStyle(
        color: palette.accent,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: isDarkMode ? palette.onHeader : AppColors.lightMutedText,
      ),
      labelType: NavigationRailLabelType.all,
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.home_outlined),
          label: Text(loc.home),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.history),
          label: Text(loc.history),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.storefront_outlined),
          label: Text(loc.restaurants),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.person_outline),
          label: Text(loc.profile),
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
    this.isDarkMode = false,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDarkMode
                    ? AppColors.lavenderText
                    : AppColors.lightPrimaryText,
              ),
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onActionTap,
              style: TextButton.styleFrom(foregroundColor: palette.accent),
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SubPageHeader extends StatelessWidget {
  const SubPageHeader({
    super.key,
    required this.title,
    this.onBack,
    this.onBackEnabled = true,
    this.trailing,
    this.subtitle,
    this.customContent,
    this.isDarkMode = false,
  });

  final String title;
  final VoidCallback? onBack;
  final bool onBackEnabled;
  final Widget? trailing;
  final String? subtitle;
  final Widget? customContent;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);

    return Container(
      width: double.infinity,
      color: palette.headerBackground,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child:
              customContent ??
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (onBackEnabled)
                    Row(
                      children: [
                        IconButton(
                          onPressed: onBack,
                          icon: Icon(
                            Icons.arrow_back,
                            color: palette.onHeader,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context).back,
                          style: TextStyle(
                            color: palette.onHeaderMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  if (onBackEnabled) const SizedBox(height: 22),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title.isNotEmpty)
                              Text(
                                title,
                                style: TextStyle(
                                  color: palette.onHeader,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                subtitle!,
                                style: TextStyle(
                                  color: palette.accent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      ?trailing,
                    ],
                  ),
                ],
              ),
        ),
      ),
    );
  }
}

class TogglePill extends StatelessWidget {
  const TogglePill({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.isLeftSelected,
    required this.onLeftTap,
    required this.onRightTap,
    this.isDarkMode = false,
  });

  final String leftLabel;
  final String rightLabel;
  final bool isLeftSelected;
  final VoidCallback onLeftTap;
  final VoidCallback onRightTap;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isDarkMode ? palette.sectionContainer : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xxxl),
        border: Border.all(
          color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ToggleChip(
            label: leftLabel,
            isSelected: isLeftSelected,
            onTap: onLeftTap,
            isDarkMode: isDarkMode,
          ),
          ToggleChip(
            label: rightLabel,
            isSelected: !isLeftSelected,
            onTap: onRightTap,
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }
}

class ToggleChip extends StatelessWidget {
  const ToggleChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isDarkMode = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sheet),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? Colors.white : AppColors.brand)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sheet),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (isDarkMode ? AppColors.lightPrimaryText : Colors.white)
                : (isDarkMode
                      ? palette.secondaryText
                      : AppColors.neutralAvatar),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
