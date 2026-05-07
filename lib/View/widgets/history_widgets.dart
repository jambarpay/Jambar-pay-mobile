import 'package:flutter/material.dart';

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
    const filters = ['Tous', "Aujourd'hui", 'Cette semaine', 'Ce mois'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var index = 0; index < filters.length; index++) ...[
              HistoryFilterChip(
                label: filters[index],
                isSelected: selectedFilter == filters[index],
                isDarkMode: isDarkMode,
                onTap: () => onFilterSelected(filters[index]),
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: hintColor),
          hintText: 'Rechercher une transaction ou un commerce',
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
