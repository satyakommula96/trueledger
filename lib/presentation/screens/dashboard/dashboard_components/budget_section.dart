import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:truecash/domain/models/models.dart';
import 'package:truecash/core/theme/theme.dart';
import 'package:truecash/core/utils/currency_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truecash/presentation/providers/privacy_provider.dart';
import 'package:truecash/presentation/screens/budget/edit_budget.dart';

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
      return const Text("No active budgets",
          style: TextStyle(color: Colors.grey));
    }
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
        children: budgets.asMap().entries.map((entry) {
      final index = entry.key;
      final b = entry.value;
      final double progress = (b.spent / b.monthlyLimit).clamp(0.0, 1.0);
      final bool isOver = b.spent > b.monthlyLimit;

      return InkWell(
        onTap: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => EditBudgetScreen(budget: b)));
          onLoad();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.surface.withValues(alpha: 0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: semantic.divider.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(b.category.toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(
                      "${CurrencyFormatter.format(b.spent, isPrivate: isPrivate)} / ${CurrencyFormatter.format(b.monthlyLimit, isPrivate: isPrivate)}",
                      style: TextStyle(
                          fontSize: 12,
                          color: isOver
                              ? semantic.overspent
                              : semantic.secondaryText,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              LayoutBuilder(builder: (context, constraints) {
                return Stack(
                  children: [
                    Container(
                      height: 10,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: semantic.divider.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    Container(
                      height: 10,
                      width: constraints.maxWidth * progress,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isOver
                                ? [
                                    semantic.overspent,
                                    semantic.overspent.withValues(alpha: 0.7)
                                  ]
                                : [
                                    colorScheme.primary,
                                    colorScheme.primary.withValues(alpha: 0.7)
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: (isOver
                                      ? semantic.overspent
                                      : colorScheme.primary)
                                  .withValues(alpha: 0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ]),
                    )
                        .animate()
                        .shimmer(
                            duration: 2.seconds,
                            color: Colors.white.withValues(alpha: 0.2))
                        .scaleX(
                            begin: 0,
                            end: 1,
                            duration: 1.seconds,
                            curve: Curves.easeOutQuint,
                            alignment: Alignment.centerLeft),
                  ],
                );
              }),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(delay: (100 * index).ms, duration: 600.ms)
          .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuint);
    }).toList());
  }
}
