import 'package:flutter/material.dart';
import 'package:trueledger/core/theme/theme.dart';

class MonthDetailHeader extends StatelessWidget {
  final String searchQuery;
  final String typeFilter;
  final bool showFilters;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;
  final AppColors semantic;

  const MonthDetailHeader({
    super.key,
    required this.searchQuery,
    required this.typeFilter,
    this.showFilters = true,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.semantic,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: TextField(
            onChanged: onSearchChanged,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: "SEARCH LEDGER...",
              hintStyle: TextStyle(
                  color: semantic.secondaryText.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1),
              prefixIcon:
                  Icon(Icons.search, size: 16, color: semantic.secondaryText),
              filled: true,
              fillColor: colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: semantic.divider)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: semantic.divider)),
            ),
          ),
        ),
        if (showFilters)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip(
                    context, "All", Icons.apps_rounded, Colors.blue),
                const SizedBox(width: 8),
                _buildFilterChip(context, "Expenses",
                    Icons.trending_down_rounded, semantic.overspent),
                const SizedBox(width: 8),
                _buildFilterChip(context, "Income", Icons.trending_up_rounded,
                    semantic.income),
                const SizedBox(width: 8),
                _buildFilterChip(
                    context, "Fixed", Icons.lock_clock_rounded, Colors.orange),
                const SizedBox(width: 8),
                _buildFilterChip(context, "Variable",
                    Icons.shopping_bag_rounded, Colors.purple),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChip(
      BuildContext context, String label, IconData icon, Color color) {
    final isSelected = typeFilter == label;
    final isTouch = Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.android;

    final child = GestureDetector(
      onTap: () => onFilterChanged(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.1),
            width: 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : color),
            const SizedBox(width: 8),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.white : color,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );

    if (isTouch) return child;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: child,
    );
  }
}
