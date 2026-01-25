import 'package:flutter/material.dart';
import 'package:truecash/core/theme/theme.dart';

import 'package:truecash/presentation/providers/analysis_provider.dart';
import 'package:truecash/presentation/providers/privacy_provider.dart';
import 'package:truecash/presentation/screens/dashboard/dashboard_components/budget_section.dart';
import 'package:truecash/presentation/screens/dashboard/dashboard_components/trend_chart.dart';
import 'package:truecash/presentation/screens/budget/add_budget.dart';
import 'package:truecash/core/utils/currency_formatter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisAsync = ref.watch(analysisProvider);
    final isPrivate = ref.watch(privacyProvider);
    final semantic = Theme.of(context).extension<AppColors>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return analysisAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text("Error: $err"))),
      data: (data) {
        final budgets = data.budgets;
        final trendData = data.trendData;
        final categoryData = data.categoryData;

        void reload() {
          ref.invalidate(analysisProvider);
        }

        return Scaffold(
          appBar: AppBar(title: const Text("ANALYSIS & BUDGETS")),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddBudgetScreen()));
              reload();
            },
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            child: const Icon(Icons.add),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                20, 20, 20, 100 + MediaQuery.of(context).padding.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (trendData.length >= 2) ...[
                  _buildInsightCard(context, trendData, semantic, isPrivate)
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuint),
                  const SizedBox(height: 32),
                ],
                Text("SPENDING TREND",
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: semantic.secondaryText))
                    .animate()
                    .fadeIn(delay: 200.ms),
                const SizedBox(height: 16),
                TrendChart(
                        trendData: trendData,
                        semantic: semantic,
                        isPrivate: isPrivate)
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms)
                    .slideX(begin: 0.1, end: 0, curve: Curves.easeOutQuint),
                const SizedBox(height: 32),
                Text("SPENDING BY CATEGORY",
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: semantic.secondaryText))
                    .animate()
                    .fadeIn(delay: 600.ms),
                const SizedBox(height: 16),
                _buildCategoryBreakdown(
                    context, categoryData, semantic, isPrivate),
                const SizedBox(height: 32),
                Text("LIVE TRACKING",
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: semantic.secondaryText))
                    .animate()
                    .fadeIn(delay: 800.ms),
                const SizedBox(height: 24),
                BudgetSection(
                        budgets: budgets, semantic: semantic, onLoad: reload)
                    .animate()
                    .fadeIn(delay: 1000.ms),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryBreakdown(BuildContext context,
      List<Map<String, dynamic>> data, AppColors semantic, bool isPrivate) {
    if (data.isEmpty) {
      return const Text("No spending data yet.",
          style: TextStyle(color: Colors.grey));
    }

    // Find max value for progress bar calculation
    final maxVal = data.fold<int>(0,
        (prev, e) => (e['total'] as int) > prev ? (e['total'] as int) : prev);

    return Column(
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final total = item['total'] as int;
        final progress = maxVal == 0 ? 0.0 : total / maxVal;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['category'],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface)),
                  Text(CurrencyFormatter.format(total, isPrivate: isPrivate),
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 8),
              LayoutBuilder(builder: (context, constraints) {
                return Stack(
                  children: [
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: semantic.divider.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      height: 8,
                      width: constraints.maxWidth * progress,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              semantic.expense,
                              semantic.expense.withValues(alpha: 0.7)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: semantic.expense.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ]),
                    )
                        .animate()
                        .shimmer(
                            duration: 1200.ms,
                            color: Colors.white.withValues(alpha: 0.2))
                        .scaleX(
                            begin: 0,
                            end: 1,
                            duration: 800.ms,
                            curve: Curves.easeOutQuint,
                            alignment: Alignment.centerLeft),
                  ],
                );
              })
            ],
          ),
        )
            .animate()
            .fadeIn(delay: (20 * index).clamp(0, 400).ms, duration: 400.ms)
            .slideX(begin: 0.05, end: 0, curve: Curves.easeOutQuint);
      }).toList(),
    );
  }

  Widget _buildInsightCard(BuildContext context,
      List<Map<String, dynamic>> data, AppColors semantic, bool isPrivate) {
    if (data.length < 2) return const SizedBox();
    final current = data[0]['total'] as int;
    final last = data[1]['total'] as int;
    final diff = current - last;
    final isIncrease = diff > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: isIncrease
                ? [
                    semantic.overspent.withValues(alpha: 0.2),
                    semantic.overspent.withValues(alpha: 0.05)
                  ]
                : [
                    semantic.income.withValues(alpha: 0.2),
                    semantic.income.withValues(alpha: 0.05)
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isIncrease
                ? semantic.overspent.withValues(alpha: 0.3)
                : semantic.income.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                  isIncrease
                      ? Icons.warning_amber_rounded
                      : Icons.thumb_up_alt_outlined,
                  color: isIncrease ? semantic.overspent : semantic.income),
              const SizedBox(width: 12),
              Text("MONTHLY INSIGHT",
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: semantic.secondaryText)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
              isIncrease
                  ? "Spending is up by ${CurrencyFormatter.format(diff.abs(), isPrivate: isPrivate)} compared to last month."
                  : "Great job! Spending decreased by ${CurrencyFormatter.format(diff.abs(), isPrivate: isPrivate)}.",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }
}
