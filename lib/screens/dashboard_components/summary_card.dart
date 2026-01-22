import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final AppColors semantic;
  final IconData icon;

  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.semantic,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: semantic.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label.toUpperCase(),
                  style: TextStyle(
                      fontSize: 10,
                      color: semantic.secondaryText,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1)),
              Icon(icon,
                  size: 16,
                  color: semantic.secondaryText.withValues(alpha: 0.5)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                  letterSpacing: -0.5)),
        ],
      ),
    );
  }
}

class FullWidthSummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final AppColors semantic;

  const FullWidthSummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.semantic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: semantic.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label.toUpperCase(),
              style: TextStyle(
                  fontSize: 12,
                  color: semantic.secondaryText,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1)),
          Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                  letterSpacing: -0.5)),
        ],
      ),
    );
  }
}
