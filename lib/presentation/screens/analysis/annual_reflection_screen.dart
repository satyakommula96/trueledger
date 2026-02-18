import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/domain/usecases/get_annual_reflection_usecase.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/presentation/components/error_view.dart';
import 'package:trueledger/core/config/app_config.dart';
import 'package:trueledger/l10n/app_localizations.dart';

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
    final dataAsync = ref.watch(annualReflectionProvider(year));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: semantic.surfaceCombined,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: semantic.text, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Mesh Effects
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    semantic.primary.withValues(alpha: 0.1),
                    semantic.primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ).animate(onPlay: (c) {
              if (!AppConfig.isTest) c.repeat(reverse: true);
            }).move(duration: 10.seconds, end: const Offset(-50, 50)),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    semantic.income.withValues(alpha: 0.08),
                    semantic.income.withValues(alpha: 0),
                  ],
                ),
              ),
            ).animate(onPlay: (c) {
              if (!AppConfig.isTest) c.repeat(reverse: true);
            }).move(duration: 8.seconds, end: const Offset(40, -40)),
          ),
          dataAsync.when(
            loading: () => Center(
                child: CircularProgressIndicator(color: semantic.primary)),
            error: (err, stack) => AppErrorView(
              error: err,
              stackTrace: stack,
              onRetry: () => ref.refresh(annualReflectionProvider(year)),
            ),
            data: (data) {
              final diff =
                  data.totalSpendCurrentYear - data.totalSpendPreviousYear;
              final pctChange = data.totalSpendPreviousYear > 0
                  ? (diff / data.totalSpendPreviousYear * 100)
                      .toStringAsFixed(1)
                  : null;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                    24, MediaQuery.of(context).padding.top + 80, 24, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.yearReview(year).toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            color: semantic.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.annualReflection,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: semantic.text,
                            height: 0.95,
                            letterSpacing: -2,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 800.ms).slideX(
                        begin: -0.05, end: 0, curve: Curves.easeOutQuart),
                    const SizedBox(height: 56),
                    _ReflectionCard(
                      semantic: semantic,
                      icon: Icons.auto_graph_rounded,
                      iconColor: semantic.primary,
                      title: l10n.annualVolume,
                      content: l10n.totalSpendingReached(
                          CurrencyFormatter.format(data.totalSpendCurrentYear)),
                      subContent: pctChange != null
                          ? (diff > 0
                              ? l10n.spendingIncrease(
                                  CurrencyFormatter.format(diff.abs()),
                                  pctChange,
                                  (year - 1).toString())
                              : l10n.spendingDecrease(
                                  CurrencyFormatter.format(diff.abs()),
                                  pctChange,
                                  (year - 1).toString()))
                          : l10n.noDataForPreviousYear((year - 1).toString()),
                      index: 0,
                    ),
                    const SizedBox(height: 20),
                    _ReflectionCard(
                      semantic: semantic,
                      icon: Icons.calendar_today_rounded,
                      iconColor: semantic.warning,
                      title: l10n.peakSpending,
                      content: data.mostExpensiveMonth != null
                          ? l10n.highestSpendingMonth(
                              _getMonthName(context, data.mostExpensiveMonth!))
                          : l10n.noSignificantPeaks,
                      subContent: data.mostExpensiveMonth != null
                          ? l10n.averageMonthlySpendStabilized(
                              CurrencyFormatter.format(data.avgMonthlySpend))
                          : l10n.keepTrackingTrends,
                      index: 1,
                    ),
                    const SizedBox(height: 20),
                    _ReflectionCard(
                      semantic: semantic,
                      icon: Icons.pie_chart_outline_rounded,
                      iconColor: semantic.income,
                      title: l10n.topCategory,
                      content: l10n.primaryExpenditureCategory(
                          data.topCategory.toUpperCase()),
                      subContent: l10n.categoryHabitNote,
                      index: 2,
                    ),
                    const SizedBox(height: 64),
                    Text(
                      l10n.categoryStability,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
                        color: semantic.secondaryText,
                      ),
                    ).animate(delay: 500.ms).fadeIn(),
                    const SizedBox(height: 24),
                    ...data.categoryStability
                        .take(3)
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                      final i = entry.key;
                      final stability = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _ReflectionCard(
                          semantic: semantic,
                          icon: stability.isStable
                              ? Icons.verified_rounded
                              : Icons.warning_amber_rounded,
                          iconColor: stability.isStable
                              ? semantic.success
                              : semantic.warning,
                          title: l10n.stabilityCategory(stability.category),
                          content: stability.isStable
                              ? l10n.spendingStable(
                                  stability.category, year.toString())
                              : l10n.spendingFluctuated(stability.category),
                          subContent:
                              "${year - 1}: ${CurrencyFormatter.format(stability.previousYearTotal)} → $year: ${CurrencyFormatter.format(stability.currentYearTotal)}",
                          index: 3 + i,
                        ),
                      );
                    }),
                    const SizedBox(height: 100),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: semantic.divider.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.verified_user_rounded,
                                color: semantic.secondaryText
                                    .withValues(alpha: 0.3),
                                size: 24),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.annualReflectionOnDevice,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color:
                                  semantic.secondaryText.withValues(alpha: 0.4),
                              letterSpacing: 0.5,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 800.ms).fadeIn(duration: 1.seconds),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getMonthName(BuildContext context, int month) {
    final l10n = AppLocalizations.of(context)!;
    final months = [
      l10n.january,
      l10n.february,
      l10n.march,
      l10n.april,
      l10n.may,
      l10n.june,
      l10n.july,
      l10n.august,
      l10n.september,
      l10n.october,
      l10n.november,
      l10n.december
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
  final int index;

  const _ReflectionCard({
    required this.semantic,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
    required this.subContent,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: semantic.surfaceCombined.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: semantic.divider, width: 1.5),
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
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: semantic.secondaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            content,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: semantic.text,
              height: 1.25,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            subContent,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: semantic.secondaryText,
              height: 1.5,
            ),
          ),
        ],
      ),
    )
        .animate(delay: (100 + (index * 80)).ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart);
  }
}
