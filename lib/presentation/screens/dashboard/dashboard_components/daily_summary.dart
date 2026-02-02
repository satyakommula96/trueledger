import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';

class DailySummary extends ConsumerWidget {
  final int todaySpend;
  final int? totalBudgetRemaining;
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
    final colorScheme = Theme.of(context).colorScheme;
    final spendStr = CurrencyFormatter.format(todaySpend, isPrivate: isPrivacy);

    return HoverWrapper(
      onTap: onTap,
      borderRadius: 24,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              semantic.surfaceCombined,
              semantic.surfaceCombined.withValues(alpha: 0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: semantic.divider.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Icon(
                Icons.today_rounded,
                size: 64,
                color: colorScheme.primary.withValues(alpha: 0.04),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "TODAY",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: semantic.secondaryText,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 16),
                Semantics(
                  container: true,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      spendStr,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                        color: colorScheme.onSurface,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 100.ms)
                        .slideX(begin: -0.1, end: 0, curve: Curves.easeOut),
                  ),
                ),
                if (totalBudgetRemaining != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (totalBudgetRemaining! < 0
                              ? semantic.overspent
                              : semantic.income)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Semantics(
                      container: true,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "${CurrencyFormatter.format(totalBudgetRemaining!, isPrivate: isPrivacy)} left",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: totalBudgetRemaining! < 0
                                ? semantic.overspent
                                : semantic.income,
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
