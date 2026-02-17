import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/domain/usecases/get_weekly_reflection_usecase.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';
import 'package:trueledger/domain/usecases/usecase_base.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/presentation/components/error_view.dart';
import 'package:trueledger/core/config/app_config.dart';
import 'package:trueledger/l10n/app_localizations.dart';

final weeklyReflectionProvider =
    FutureProvider<WeeklyReflectionData>((ref) async {
  final usecase = ref.watch(getWeeklyReflectionUseCaseProvider);
  final result = await usecase(NoParams());
  if (result.isFailure) {
    throw Exception(result.failureOrThrow.message);
  }
  return result.getOrThrow;
});

class WeeklyReflectionScreen extends ConsumerWidget {
  const WeeklyReflectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final dataAsync = ref.watch(weeklyReflectionProvider);

    return Scaffold(
      backgroundColor: semantic.surfaceCombined,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: Icon(Icons.close_rounded, color: semantic.text),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Mesh Background for Weekly Context
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    semantic.primary.withValues(alpha: 0.12),
                    semantic.primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ).animate(onPlay: (c) {
              if (!AppConfig.isTest) c.repeat(reverse: true);
            }).move(duration: 6.seconds, end: const Offset(30, 20)),
          ),
          dataAsync.when(
            loading: () => Center(
                child: CircularProgressIndicator(color: semantic.primary)),
            error: (err, stack) => AppErrorView(
              error: err,
              stackTrace: stack,
              onRetry: () => ref.refresh(weeklyReflectionProvider),
            ),
            data: (data) {
              final l10n = AppLocalizations.of(context)!;
              final daysUnder = data.daysUnderBudget;
              final increaseData = data.largestCategoryIncrease;

              String insightTitle =
                  daysUnder > 3 ? l10n.greatWorkWeek : l10n.reviewYourWeek;
              String insight1 = l10n.underBudgetDays(daysUnder);
              if (daysUnder == 7) {
                insight1 = l10n.perfectWeek;
              } else if (daysUnder == 0) {
                insight1 = l10n.heavyWeek;
              }

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                    24, MediaQuery.of(context).padding.top + 80, 24, 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.weeklySummary,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            color: semantic.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          insightTitle,
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: semantic.text,
                            height: 1.0,
                            letterSpacing: -1.5,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 800.ms).slideX(
                        begin: -0.05, end: 0, curve: Curves.easeOutQuart),
                    const SizedBox(height: 56),
                    _ReflectionCard(
                      semantic: semantic,
                      icon: daysUnder > 3
                          ? Icons.verified_rounded
                          : Icons.info_outline_rounded,
                      iconColor:
                          daysUnder > 3 ? semantic.income : semantic.warning,
                      title: l10n.spendingConsistency,
                      content: insight1,
                      subContent: l10n.dailyBenchmark(CurrencyFormatter.format(
                          data.budgetDailyAverage,
                          compact: true)),
                      index: 0,
                    ),
                    const SizedBox(height: 20),
                    if (increaseData != null) ...[
                      _ReflectionCard(
                        semantic: semantic,
                        icon: Icons.trending_up_rounded,
                        iconColor: semantic.overspent,
                        title: l10n.spendingSpike,
                        content: l10n.spikeMessage(
                            increaseData['category'].toString().toUpperCase(),
                            CurrencyFormatter.format(
                                increaseData['increaseAmount'],
                                compact: true)),
                        subContent: increaseData['isNew'] == true
                            ? l10n.newCategoryExpenditure
                            : l10n.eyeOnCategoryTrend,
                        index: 1,
                      ),
                    ] else ...[
                      _ReflectionCard(
                        semantic: semantic,
                        icon: Icons.shield_rounded,
                        iconColor: semantic.income,
                        title: l10n.stableSpending,
                        content: l10n.noSpikesDetected,
                        subContent: l10n.spendingStabilizing,
                        index: 1,
                      ),
                    ],
                    const SizedBox(height: 20),
                    _ReflectionCard(
                      semantic: semantic,
                      icon: Icons.compare_arrows_rounded,
                      iconColor: semantic.primary,
                      title: l10n.volumeComparison,
                      content: data.totalThisWeek < data.totalLastWeek
                          ? l10n.reducedSpendingSuccess(
                              CurrencyFormatter.format(
                                  data.totalLastWeek - data.totalThisWeek))
                          : l10n.increasedSpendingMessage(
                              CurrencyFormatter.format(
                                  data.totalThisWeek - data.totalLastWeek)),
                      subContent: l10n.lastWeekVsThisWeek(
                          CurrencyFormatter.format(data.totalLastWeek),
                          CurrencyFormatter.format(data.totalThisWeek)),
                      index: 2,
                    ),
                    if (data.topCategory != null) ...[
                      const SizedBox(height: 20),
                      _ReflectionCard(
                        semantic: semantic,
                        icon: Icons.leaderboard_rounded,
                        iconColor: semantic.warning,
                        title: l10n.primaryCategory,
                        content: l10n.largestExpenditureArea(
                            data.topCategory!.toUpperCase()),
                        subContent: l10n.alignWithPriorities,
                        index: 3,
                      ),
                    ],
                    const SizedBox(height: 64),
                    Text(
                      l10n.weeklyFocus,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
                        color: semantic.secondaryText,
                      ),
                    ).animate(delay: 500.ms).fadeIn(),
                    const SizedBox(height: 24),
                    _ReflectionCard(
                      semantic: semantic,
                      icon: Icons.flag_rounded,
                      iconColor: Colors.deepPurple,
                      title: l10n.gentleGoal,
                      content: data.topCategory != null
                          ? l10n
                              .reductionTarget(data.topCategory!.toUpperCase())
                          : l10n.stayUnderBudgetGoal,
                      subContent: l10n.sustainableProgress,
                      index: 4,
                    ),
                    const SizedBox(height: 80),
                    Center(
                      child: Text(
                        l10n.reflectionFinancialIntuition,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: semantic.secondaryText.withValues(alpha: 0.4),
                          letterSpacing: 1,
                        ),
                      ),
                    ).animate(delay: 800.ms).fadeIn(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
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
