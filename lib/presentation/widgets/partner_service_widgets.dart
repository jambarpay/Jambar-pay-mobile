import 'package:flutter/material.dart';
import '../../design_system/tokens/app_colors.dart';
import '../../domain/entities/partner_category.dart';
import '../../l10n/app_localizations.dart';
import 'app_palette.dart';

extension PartnerCategoryPresentation on PartnerCategory {
  String label(AppLocalizations loc) => switch (this) {
    PartnerCategory.restaurant => loc.serviceRestaurant,
    PartnerCategory.shop => loc.serviceShop,
    PartnerCategory.supermarket => loc.serviceSupermarket,
    PartnerCategory.market => loc.serviceMarket,
    PartnerCategory.other => loc.serviceOther,
  };

  String description(AppLocalizations loc) => switch (this) {
    PartnerCategory.restaurant => loc.serviceRestaurantDescription,
    PartnerCategory.shop => loc.serviceShopDescription,
    PartnerCategory.supermarket => loc.serviceSupermarketDescription,
    PartnerCategory.market => loc.serviceMarketDescription,
    PartnerCategory.other => loc.serviceOther,
  };

  IconData get icon => switch (this) {
    PartnerCategory.restaurant => Icons.restaurant_rounded,
    PartnerCategory.shop => Icons.shopping_bag_outlined,
    PartnerCategory.supermarket => Icons.shopping_cart_outlined,
    PartnerCategory.market => Icons.storefront_outlined,
    PartnerCategory.other => Icons.local_mall_outlined,
  };
}

class PartnerServicePicker extends StatelessWidget {
  const PartnerServicePicker({
    super.key,
    required this.isDarkMode,
    required this.selectedCategory,
    required this.onSelected,
    required this.onContinue,
    required this.onShowAll,
  });

  final bool isDarkMode;
  final PartnerCategory? selectedCategory;
  final ValueChanged<PartnerCategory> onSelected;
  final VoidCallback onContinue;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final palette = AppPalette(isDarkMode);
    return SingleChildScrollView(
      key: const PageStorageKey('service-picker-scroll'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.storefront_rounded,
                size: 48,
                color: AppColors.brand,
              ),
              const SizedBox(height: 16),
              Text(
                loc.chooseService,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.primaryText,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.chooseServiceDescription,
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.secondaryText, fontSize: 15),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final singleColumn =
                      constraints.maxWidth < 300 ||
                      MediaQuery.textScalerOf(context).scale(16) > 23;
                  final width = singleColumn
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 14) / 2;
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      for (final category in PartnerCategory.selectable)
                        SizedBox(
                          width: width,
                          child: _ServiceCard(
                            category: category,
                            isSelected: category == selectedCategory,
                            isDarkMode: isDarkMode,
                            onTap: () => onSelected(category),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: palette.tileBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDarkMode
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline, color: AppColors.brand),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        loc.serviceFilterInfo,
                        style: TextStyle(
                          color: palette.secondaryText,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                key: const ValueKey('service-continue'),
                onPressed: selectedCategory == null ? null : onContinue,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(loc.continueLabel),
              ),
              const SizedBox(height: 8),
              TextButton(
                key: const ValueKey('service-show-all'),
                onPressed: onShowAll,
                child: Text(loc.viewAllPartners),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.category,
    required this.isSelected,
    required this.isDarkMode,
    required this.onTap,
  });

  final PartnerCategory category;
  final bool isSelected;
  final bool isDarkMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final palette = AppPalette(isDarkMode);
    return Semantics(
      selected: isSelected,
      child: Material(
        color: isSelected ? AppColors.brandDark : palette.tileBackground,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: ValueKey('service-${category.name}'),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 185),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                width: isSelected ? 2 : 1,
                color: isSelected
                    ? AppColors.brand
                    : (isDarkMode
                          ? AppColors.darkBorder
                          : AppColors.lightBorder),
              ),
            ),
            child: Column(
              children: [
                Icon(category.icon, size: 36, color: AppColors.brand),
                const SizedBox(height: 14),
                Text(
                  category.label(loc),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : palette.primaryText,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  category.description(loc),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.darkSecondaryText
                        : palette.secondaryText,
                    fontSize: 12,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brand,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '✓ ${loc.serviceSelected}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PartnerCategoryFilters extends StatelessWidget {
  const PartnerCategoryFilters({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
    required this.isDarkMode,
  });

  final PartnerCategory? selectedCategory;
  final ValueChanged<PartnerCategory?> onSelected;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final palette = AppPalette(isDarkMode);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Semantics(
        container: true,
        label: loc.filterByCategory,
        child: Row(
          children: [
            for (final category in [null, ...PartnerCategory.selectable])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  key: ValueKey('filter-${category?.name ?? 'all'}'),
                  label: Text(category?.label(loc) ?? loc.filterAll),
                  avatar: Icon(
                    category?.icon ?? Icons.apps_rounded,
                    size: 18,
                    color: selectedCategory == category
                        ? Colors.white
                        : palette.accent,
                  ),
                  selected: selectedCategory == category,
                  onSelected: (_) => onSelected(category),
                  selectedColor: AppColors.brand,
                  backgroundColor: palette.tileBackground,
                  labelStyle: TextStyle(
                    color: selectedCategory == category
                        ? Colors.white
                        : palette.primaryText,
                  ),
                  showCheckmark: false,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
