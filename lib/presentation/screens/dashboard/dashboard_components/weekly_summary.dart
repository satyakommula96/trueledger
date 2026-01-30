import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';

class WeeklySummary extends ConsumerWidget {
  final int thisWeekSpend;
  final int lastWeekSpend;
  final AppColors semantic;

  const WeeklySummary({
    super.key,
    required this.thisWeekSpend,
    required this.lastWeekSpend,
    required this.semantic,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivacy = ref.watch(privacyProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final diff = thisWeekSpend - lastWeekSpend;
    final percentChange =
        lastWeekSpend > 0 ? ((diff / lastWeekSpend) * 100).round() : 0;
    final isUp = diff > 0;
    final isDown = diff < 0;

    Color changeColor;
    IconData changeIcon;
    String changeText;

    if (isUp) {
      changeColor = semantic.overspent;
      changeIcon = Icons.trending_up_rounded;
      changeText = "+$percentChange% vs last week";
    } else if (isDown) {
      changeColor = semantic.income;
      changeIcon = Icons.trending_down_rounded;
      changeText = "$percentChange% vs last week";
    } else {
      changeColor = semantic.secondaryText;
      changeIcon = Icons.trending_flat_rounded;
      changeText = "Same as last week";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: semantic.surfaceCombined,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: semantic.divider.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "THIS WEEK",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: semantic.secondaryText,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: changeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(changeIcon, size: 14, color: changeColor),
                    const SizedBox(width: 4),
                    Text(
                      changeText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: changeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            CurrencyFormatter.format(thisWeekSpend, isPrivate: isPrivacy),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Last week: ${CurrencyFormatter.format(lastWeekSpend, isPrivate: isPrivacy)}",
            style: TextStyle(
              fontSize: 13,
              color: semantic.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
