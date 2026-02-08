import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';

class WeeklySummary extends ConsumerWidget {
  final double thisWeekSpend;
  final double lastWeekSpend;
  final AppColors semantic;
  final VoidCallback? onTap;

  const WeeklySummary({
    super.key,
    required this.thisWeekSpend,
    required this.lastWeekSpend,
    required this.semantic,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivacy = ref.watch(privacyProvider);

    final diff = thisWeekSpend - lastWeekSpend;
    final percentChange =
        lastWeekSpend > 0 ? ((diff / lastWeekSpend) * 100).round().abs() : 0;
    final isUp = diff > 0;
    final isDown = diff < 0;

    Color changeColor;
    IconData changeStatusIcon;

    if (isUp) {
      changeColor = semantic.overspent;
      changeStatusIcon = Icons.trending_up_rounded;
    } else if (isDown) {
      changeColor = semantic.income;
      changeStatusIcon = Icons.trending_down_rounded;
    } else {
      changeColor = semantic.secondaryText;
      changeStatusIcon = Icons.trending_flat_rounded;
    }

    return HoverWrapper(
      onTap: onTap,
      borderRadius: 24,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: semantic.surfaceCombined.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: semantic.divider, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: semantic.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.view_week_rounded,
                    size: 12,
                    color: semantic.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "WEEK",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: semantic.secondaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                CurrencyFormatter.format(thisWeekSpend, isPrivate: isPrivacy),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: semantic.text,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(changeStatusIcon, size: 14, color: changeColor),
                const SizedBox(width: 4),
                Text(
                  isUp
                      ? "+$percentChange%"
                      : isDown
                          ? "-$percentChange%"
                          : "Stable",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: changeColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }
}
