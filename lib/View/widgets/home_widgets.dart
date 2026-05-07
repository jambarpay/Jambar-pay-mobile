import 'package:flutter/material.dart';
import 'app_palette.dart';

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
    final items = <({IconData icon, String label})>[
      (icon: Icons.home_outlined, label: 'Accueil'),
      (icon: Icons.history, label: 'Historique'),
      (icon: Icons.storefront_outlined, label: 'restaurants'),
      (icon: Icons.person_outline, label: 'Profil'),
    ];

    return Container(
      color: palette.headerBackground,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = index == currentIndex;

            return Expanded(
              child: InkWell(
                onTap: () => onTap(index),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        color: isSelected
                            ? palette.accent
                            : palette.primaryText,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected
                              ? palette.accent
                              : palette.primaryText,
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

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.isDarkMode = false,
  });

  final String title;
  final String? actionLabel;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDarkMode
                    ? const Color(0xFFB6AEF0)
                    : const Color(0xFF2E2C42),
              ),
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: () {},
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
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
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
                            color: palette.primaryText,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Retour',
                          style: TextStyle(
                            color: palette.secondaryText,
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
                                  color: palette.primaryText,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 24),
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
                      if (trailing != null) trailing!,
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
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF343254) : Colors.transparent,
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
      borderRadius: BorderRadius.circular(26),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? Colors.white : const Color(0xFF05062D))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (isDarkMode ? const Color(0xFF1C1A33) : Colors.white)
                : (isDarkMode
                      ? palette.secondaryText
                      : const Color(0xFF9A99A7)),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
