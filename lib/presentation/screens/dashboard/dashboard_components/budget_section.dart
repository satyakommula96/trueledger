import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:trueledger/presentation/screens/budget/edit_budget.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';

class BudgetSection extends ConsumerWidget {
  final List<Budget> budgets;
  final AppColors semantic;
  final VoidCallback onLoad;

  const BudgetSection({
    super.key,
    required this.budgets,
    required this.semantic,
    required this.onLoad,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivate = ref.watch(privacyProvider);
    if (budgets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text("No active budgets",
              style: TextStyle(
                  color: semantic.secondaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
      );
    }

    return Column(
      children: budgets.asMap().entries.map((entry) {
        final index = entry.key;
        final b = entry.value;
        final double progress = (b.spent / b.monthlyLimit).clamp(0.01, 1.0);
        final bool isOver = b.spent > b.monthlyLimit;

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: HoverWrapper(
            borderRadius: 28,
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditBudgetScreen(budget: b)));
              onLoad();
            },
            glowColor: isOver ? semantic.overspent : semantic.primary,
            glowOpacity: 0.1,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: semantic.surfaceCombined.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: semantic.divider, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    b.category.toUpperCase(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                        color: semantic.text,
                                        letterSpacing: 0.5),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (b.isStable) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: semantic.success
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(CupertinoIcons.checkmark_seal_fill,
                                            size: 10, color: semantic.success),
                                        const SizedBox(width: 4),
                                        Text(
                                          "STABLE",
                                          style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.w900,
                                              color: semantic.success),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (b.lastReviewedAt != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  "Analyzed ${DateFormat('dd MMM').format(b.lastReviewedAt!)}",
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: semantic.secondaryText),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                CurrencyFormatter.format(b.spent,
                                    isPrivate: isPrivate),
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: isOver
                                        ? semantic.overspent
                                        : semantic.text),
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "of ${CurrencyFormatter.format(b.monthlyLimit, isPrivate: isPrivate)}",
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: semantic.secondaryText),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(builder: (context, constraints) {
                    return Stack(
                      children: [
                        Container(
                          height: 10,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: semantic.divider,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        AnimatedContainer(
                          duration: 800.ms,
                          curve: Curves.easeOutQuint,
                          height: 10,
                          width: constraints.maxWidth * progress,
                          decoration: BoxDecoration(
                            color:
                                isOver ? semantic.overspent : semantic.primary,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: (isOver
                                        ? semantic.overspent
                                        : semantic.primary)
                                    .withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                        ).animate().shimmer(
                            duration: 2.seconds,
                            color:
                                (isOver ? semantic.overspent : semantic.primary)
                                    .withValues(alpha: 0.2)),
                      ],
                    );
                  }),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(delay: (60 * index).ms, duration: 600.ms)
              .slideY(begin: 0.05, end: 0, curve: Curves.easeOutQuint),
        );
      }).toList(),
    );
  }
}
