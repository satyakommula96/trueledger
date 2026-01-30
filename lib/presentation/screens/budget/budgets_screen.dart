import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:trueledger/presentation/screens/budget/add_budget.dart';
import 'package:trueledger/presentation/screens/budget/edit_budget.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppColors>()!;
    final isPrivacy = ref.watch(privacyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("BUDGETS"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddBudgetScreen()),
              );
              ref.invalidate(dashboardProvider);
            },
          ),
        ],
      ),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (data) {
          final budgets = data.budgets;

          if (budgets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pie_chart_outline_rounded,
                    size: 80,
                    color: semantic.secondaryText.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "No budgets yet",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Create category budgets to track spending",
                    style: TextStyle(
                      fontSize: 14,
                      color: semantic.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddBudgetScreen()),
                      );
                      ref.invalidate(dashboardProvider);
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text("ADD BUDGET"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              return _BudgetCard(
                budget: budget,
                semantic: semantic,
                colorScheme: colorScheme,
                isPrivacy: isPrivacy,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EditBudgetScreen(budget: budget)),
                  );
                  ref.invalidate(dashboardProvider);
                },
              ).animate(delay: (index * 100).ms).fadeIn().slideX(begin: 0.1);
            },
          );
        },
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final Budget budget;
  final AppColors semantic;
  final ColorScheme colorScheme;
  final bool isPrivacy;
  final VoidCallback onTap;

  const _BudgetCard({
    required this.budget,
    required this.semantic,
    required this.colorScheme,
    required this.isPrivacy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final limit = budget.monthlyLimit;
    final spent = budget.spent;
    final progress = limit > 0 ? (spent / limit).clamp(0.0, 1.5) : 0.0;
    final remaining = limit - spent;

    Color statusColor;
    String statusText;
    if (progress >= 1.0) {
      statusColor = semantic.overspent;
      statusText = "OVER BUDGET";
    } else if (progress >= 0.75) {
      statusColor = semantic.warning;
      statusText = "ALMOST THERE";
    } else {
      statusColor = semantic.income;
      statusText = "ON TRACK";
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: semantic.surfaceCombined,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      budget.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: semantic.secondaryText,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(spent, isPrivate: isPrivacy),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        "of ${CurrencyFormatter.format(limit, isPrivate: isPrivacy)}",
                        style: TextStyle(
                          fontSize: 14,
                          color: semantic.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor:
                        colorScheme.onSurface.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  remaining >= 0
                      ? "${CurrencyFormatter.format(remaining, isPrivate: isPrivacy)} remaining"
                      : "${CurrencyFormatter.format(-remaining, isPrivate: isPrivacy)} over budget",
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        remaining >= 0 ? semantic.income : semantic.overspent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
