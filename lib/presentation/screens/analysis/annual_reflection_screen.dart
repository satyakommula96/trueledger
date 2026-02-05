import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/domain/usecases/get_annual_reflection_usecase.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/presentation/components/error_view.dart';

final annualReflectionProvider =
    FutureProvider.family<AnnualReflectionData, int>((ref, year) async {
  final usecase = ref.watch(getAnnualReflectionUseCaseProvider);
  final result = await usecase(year);
  if (result.isFailure) {
    throw Exception(result.failureOrThrow.message);
  }
  return result.getOrThrow;
});

class AnnualReflectionScreen extends ConsumerWidget {
  final int year;
  const AnnualReflectionScreen({super.key, required this.year});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final dataAsync = ref.watch(annualReflectionProvider(year));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: semantic.secondaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "$year Year-in-Review",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: semantic.secondaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => AppErrorView(
          error: err,
          stackTrace: stack,
          onRetry: () => ref.refresh(annualReflectionProvider(year)),
        ),
        data: (data) {
          final diff = data.totalSpendCurrentYear - data.totalSpendPreviousYear;
          final pctChange = data.totalSpendPreviousYear > 0
              ? (diff / data.totalSpendPreviousYear * 100).toStringAsFixed(1)
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Annual Reflection",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                      color: colorScheme.onSurface,
                      height: 1.1),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 32),

                // Card 1: Total Spending Comparison
                _ReflectionCard(
                  semantic: semantic,
                  icon: Icons.summarize_rounded,
                  iconColor: Colors.blue,
                  title: "Annual Volume",
                  content:
                      "Total spending in $year reached ${CurrencyFormatter.format(data.totalSpendCurrentYear)}.",
                  subContent: pctChange != null
                      ? "This is a ${diff > 0 ? 'increase' : 'decrease'} of ${diff.abs()} ($pctChange%) compared to ${year - 1}."
                      : "No data available for ${year - 1} to compare.",
                ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1, end: 0),

                const SizedBox(height: 16),

                // Card 2: Most Expensive Month
                _ReflectionCard(
                  semantic: semantic,
                  icon: Icons.calendar_month_rounded,
                  iconColor: semantic.warning,
                  title: "Peak Spending",
                  content: data.mostExpensiveMonth != null
                      ? "${_getMonthName(data.mostExpensiveMonth!)} was the year's highest spending month."
                      : "No significant spending peaks found.",
                  subContent: data.mostExpensiveMonth != null
                      ? "Monthly average: ${CurrencyFormatter.format(data.avgMonthlySpend)}."
                      : "Record more transactions to see trends.",
                ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1, end: 0),

                const SizedBox(height: 16),

                // Card 3: Top Category
                _ReflectionCard(
                  semantic: semantic,
                  icon: Icons.category_rounded,
                  iconColor: semantic.income,
                  title: "Major Category",
                  content:
                      "${data.topCategory} was the largest area of expenditure this year.",
                  subContent:
                      "Consider reviewing this category for potential adjustments.",
                ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0),

                const SizedBox(height: 32),

                Text(
                  "CATEGORY STABILITY",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: semantic.secondaryText,
                  ),
                ),
                const SizedBox(height: 12),

                // Stability Grid or List
                ...data.categoryStability.take(3).map((stability) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ReflectionCard(
                      semantic: semantic,
                      icon: stability.isStable
                          ? Icons.balance_rounded
                          : Icons.swap_vert_rounded,
                      iconColor:
                          stability.isStable ? Colors.teal : Colors.deepOrange,
                      title: "Stability: ${stability.category}",
                      content: stability.isStable
                          ? "Spending on ${stability.category} remained stable."
                          : "Spending on ${stability.category} showed significant variance.",
                      subContent:
                          "${year - 1}: ${CurrencyFormatter.format(stability.previousYearTotal)} → $year: ${CurrencyFormatter.format(stability.currentYearTotal)}",
                    ),
                  ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1, end: 0);
                }),

                const SizedBox(height: 48),

                Center(
                  child: Text(
                    "Annual data provides long-term clarity.",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: semantic.secondaryText.withValues(alpha: 0.5),
                      letterSpacing: 1,
                    ),
                  ),
                ).animate(delay: 600.ms).fadeIn(),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    if (month < 1 || month > 12) return 'Unknown';
    return months[month - 1];
  }
}

class _ReflectionCard extends StatelessWidget {
  final AppColors semantic;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;
  final String subContent;

  const _ReflectionCard({
    required this.semantic,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
    required this.subContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: semantic.surfaceCombined,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: semantic.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: semantic.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: semantic.text,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subContent,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: semantic.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
