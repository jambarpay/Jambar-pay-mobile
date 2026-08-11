import 'package:flutter/material.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_colors.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_radius.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';

class HistoryFilters extends StatelessWidget {
  const HistoryFilters({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    this.isDarkMode = false,
  });

  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final filters = <List<String>>[
      ['all', loc.filterAll],
      ['today', loc.filterToday],
      ['thisWeek', loc.filterThisWeek],
      ['thisMonth', loc.filterThisMonth],
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var index = 0; index < filters.length; index++) ...[
              HistoryFilterChip(
                label: filters[index][1],
                isSelected: selectedFilter == filters[index][0],
                isDarkMode: isDarkMode,
                onTap: () => onFilterSelected(filters[index][0]),
              ),
              if (index != filters.length - 1) const SizedBox(width: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class HistorySearchField extends StatefulWidget {
  const HistorySearchField({
    super.key,
    required this.query,
    required this.onChanged,
    this.isDarkMode = false,
  });

  final String query;
  final ValueChanged<String> onChanged;
  final bool isDarkMode;

  @override
  State<HistorySearchField> createState() => _HistorySearchFieldState();
}

class _HistorySearchFieldState extends State<HistorySearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(covariant HistorySearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.query,
        selection: TextSelection.collapsed(offset: widget.query.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fillColor = widget.isDarkMode ? AppColors.darkPanel : Colors.white;
    final hintColor = widget.isDarkMode
        ? AppColors.lavenderMuted
        : AppColors.lightHint;
    final loc = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: hintColor),
          hintText: loc.searchTransactions,
          hintStyle: TextStyle(color: hintColor, fontSize: 14),
          filled: true,
          fillColor: fillColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class HistoryFilterChip extends StatelessWidget {
  const HistoryFilterChip({
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
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.brand
              : (isDarkMode ? AppColors.darkPanel : Colors.white),
          border: Border.all(
            color: isSelected
                ? AppColors.brand
                : (isDarkMode ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          borderRadius: BorderRadius.circular(AppRadius.xxxl),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDarkMode
                      ? AppColors.lavenderBorder
                      : AppColors.lightSecondaryText),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
