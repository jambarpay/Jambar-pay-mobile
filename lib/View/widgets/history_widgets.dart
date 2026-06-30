import 'package:flutter/material.dart';
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

class HistorySearchField extends StatelessWidget {
  const HistorySearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.isDarkMode = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final fillColor = isDarkMode
        ? const Color(0xFF262342)
        : const Color(0xFFEAE9FF);
    final hintColor = isDarkMode
        ? const Color(0xFF9B97BC)
        : const Color(0xFF88879A);
    final loc = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
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
            borderRadius: BorderRadius.circular(12),
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
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFF57C21)
              : (isDarkMode
                    ? const Color(0xFF262342)
                    : const Color(0xFFEAE9FF)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDarkMode
                      ? const Color(0xFFB5B3D7)
                      : const Color(0xFF6B6884)),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
