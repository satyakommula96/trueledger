import 'package:flutter/material.dart';
import 'package:trueledger/core/theme/theme.dart';

import 'package:trueledger/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: TextField(
            onChanged: onSearchChanged,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: semantic.text,
              letterSpacing: 0,
            ),
            decoration: InputDecoration(
              hintText: l10n.searchLedger,
              hintStyle: TextStyle(
                color: semantic.secondaryText.withValues(alpha: 0.4),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 18,
                color: semantic.secondaryText.withValues(alpha: 0.6),
              ),
              filled: true,
              fillColor: semantic.surfaceCombined.withValues(alpha: 0.3),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: semantic.divider, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: semantic.divider, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                    color: semantic.primary.withValues(alpha: 0.5), width: 1.5),
              ),
            ),
          ),
        ),
        if (showFilters)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip(context, "All", l10n.all, Icons.apps_rounded,
                    semantic.primary),
                const SizedBox(width: 10),
                _buildFilterChip(context, "Expenses", l10n.expenses,
                    Icons.trending_down_rounded, semantic.overspent),
                const SizedBox(width: 10),
                _buildFilterChip(context, "Income", l10n.income,
                    Icons.trending_up_rounded, semantic.income),
                const SizedBox(width: 10),
                _buildFilterChip(context, "Fixed", l10n.fixed,
                    Icons.lock_clock_rounded, Colors.orange),
                const SizedBox(width: 10),
                _buildFilterChip(context, "Variable", l10n.variable,
                    Icons.shopping_bag_rounded, Colors.purple),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChip(BuildContext context, String value, String label,
      IconData icon, Color color) {
    final isSelected = typeFilter == value;
    final isTouch = Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.android;

    final child = GestureDetector(
      onTap: () => onFilterChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuart,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : semantic.surfaceCombined.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.transparent : semantic.divider,
            width: 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 8),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.white : color,
                letterSpacing: 1.2,
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
