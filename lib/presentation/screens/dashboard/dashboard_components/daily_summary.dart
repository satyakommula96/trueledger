import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';

class DailySummary extends ConsumerWidget {
  final int todaySpend;
  final int? totalBudgetRemaining;
  final AppColors semantic;

  const DailySummary({
    super.key,
    required this.todaySpend,
    this.totalBudgetRemaining,
    required this.semantic,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivacy = ref.watch(privacyProvider);
    final spendStr = CurrencyFormatter.format(todaySpend, isPrivate: isPrivacy);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: semantic.surfaceCombined,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: semantic.divider.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TODAY",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: semantic.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              spendStr,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          if (totalBudgetRemaining != null) ...[
            const SizedBox(height: 4),
            Text(
              "${CurrencyFormatter.format(totalBudgetRemaining!, isPrivate: isPrivacy)} left",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: totalBudgetRemaining! < 0
                    ? semantic.overspent
                    : semantic.income,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
