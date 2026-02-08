import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';

class DailySummary extends ConsumerWidget {
  final double todaySpend;
  final double? totalBudgetRemaining;
  final AppColors semantic;
  final VoidCallback? onTap;

  const DailySummary({
    super.key,
    required this.todaySpend,
    this.totalBudgetRemaining,
    required this.semantic,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivacy = ref.watch(privacyProvider);
    final spendStr = CurrencyFormatter.format(todaySpend, isPrivate: isPrivacy);

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
                    Icons.calendar_today_rounded,
                    size: 12,
                    color: semantic.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "TODAY",
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
                spendStr,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: semantic.text,
                ),
              ),
            ),
            if (totalBudgetRemaining != null) ...[
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  "${CurrencyFormatter.format(totalBudgetRemaining!, isPrivate: isPrivacy)} left",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: totalBudgetRemaining! < 0
                        ? semantic.overspent
                        : semantic.income,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }
}
