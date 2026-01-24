import 'package:flutter/material.dart';
import 'package:truecash/core/theme/theme.dart';

class MonthDetailHeader extends StatelessWidget {
  final String searchQuery;
  final String typeFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;
  final AppColors semantic;

  const MonthDetailHeader({
    super.key,
    required this.searchQuery,
    required this.typeFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.semantic,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
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
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: semantic.divider)),
            child: DropdownButton<String>(
              value: typeFilter,
              underline: const SizedBox(),
              icon: Icon(Icons.filter_list,
                  size: 14, color: semantic.secondaryText),
              items: ['All', 'Variable', 'Income', 'Fixed', 'Investment']
                  .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1))))
                  .toList(),
              onChanged: (v) => onFilterChanged(v!),
            ),
          )
        ],
      ),
    );
  }
}
