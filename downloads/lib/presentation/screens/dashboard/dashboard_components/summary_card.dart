import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';

class SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final AppColors semantic;
  final IconData icon;
  final VoidCallback? onTap;

  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.semantic,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return HoverWrapper(
      onTap: onTap,
      borderRadius: 24,
      glowColor: valueColor,
      glowOpacity: 0.15,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              valueColor.withValues(alpha: 0.1),
              valueColor.withValues(alpha: 0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: valueColor.withValues(alpha: 0.2)),
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
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: valueColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 14, color: valueColor),
                ),
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
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }
}

class FullWidthSummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final AppColors semantic;
  final VoidCallback? onTap;

  const FullWidthSummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.semantic,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return HoverWrapper(
      onTap: onTap,
      borderRadius: 24,
      glowColor: valueColor,
      glowOpacity: 0.15,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              valueColor.withValues(alpha: 0.1),
              valueColor.withValues(alpha: 0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: valueColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: valueColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    valueColor == semantic.income
                        ? Icons.account_balance_wallet_outlined
                        : Icons.receipt_long_outlined,
                    size: 16,
                    color: valueColor,
                  ),
                ),
                const SizedBox(width: 12),
                Text(label.toUpperCase(),
                    style: TextStyle(
                        fontSize: 12,
                        color: semantic.secondaryText,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1)),
              ],
            ),
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: valueColor,
                    letterSpacing: -0.5)),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.1, end: 0);
  }
}
