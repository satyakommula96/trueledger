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
              final daysUnder = data.daysUnderBudget;
              final increaseData = data.largestCategoryIncrease;

              String insightTitle =
                  daysUnder > 3 ? "Great work this week." : "Review your week.";
              String insight1 = "You stayed under budget $daysUnder days.";
              if (daysUnder == 7) {
                insight1 = "Perfect week! You stayed under budget every day.";
              } else if (daysUnder == 0) {
                insight1 =
                    "It was a heavy week. Try to track closer next week.";
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
                          "WEEKLY SUMMARY",
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
                      title: "Spending Consistency",
                      content: insight1,
                      subContent:
                          "Daily Benchmark: ~${CurrencyFormatter.format(data.budgetDailyAverage, compact: true)}",
                      index: 0,
                    ),
                    const SizedBox(height: 20),
                    if (increaseData != null) ...[
                      _ReflectionCard(
                        semantic: semantic,
                        icon: Icons.trending_up_rounded,
                        iconColor: semantic.overspent,
                        title: "Spending Spike",
                        content:
                            "${increaseData['category'].toString().toUpperCase()} increased by ${CurrencyFormatter.format(increaseData['increaseAmount'], compact: true)} vs last week.",
                        subContent: increaseData['isNew'] == true
                            ? "This is a new expenditure category for you."
                            : "Keep an eye on this category trend.",
                        index: 1,
                      ),
                    ] else ...[
                      _ReflectionCard(
                        semantic: semantic,
                        icon: Icons.shield_rounded,
                        iconColor: semantic.income,
                        title: "Stable Spending",
                        content:
                            "Zero significant spending spikes detected compared to last week.",
                        subContent:
                            "Your spending habits are stabilizing well.",
                        index: 1,
                      ),
                    ],
                    const SizedBox(height: 20),
                    _ReflectionCard(
                      semantic: semantic,
                      icon: Icons.compare_arrows_rounded,
                      iconColor: semantic.primary,
                      title: "Volume Comparison",
                      content: data.totalThisWeek < data.totalLastWeek
                          ? "Success! You reduced spending by ${CurrencyFormatter.format(data.totalLastWeek - data.totalThisWeek)}."
                          : "Spending increased by ${CurrencyFormatter.format(data.totalThisWeek - data.totalLastWeek)} vs last week.",
                      subContent:
                          "Last Week: ${CurrencyFormatter.format(data.totalLastWeek)} | This Week: ${CurrencyFormatter.format(data.totalThisWeek)}",
                      index: 2,
                    ),
                    if (data.topCategory != null) ...[
                      const SizedBox(height: 20),
                      _ReflectionCard(
                        semantic: semantic,
                        icon: Icons.leaderboard_rounded,
                        iconColor: semantic.warning,
                        title: "Primary Category",
                        content:
                            "${data.topCategory!.toUpperCase()} was your largest expenditure area.",
                        subContent:
                            "Evaluate if this aligns with your current priorities.",
                        index: 3,
                      ),
                    ],
                    const SizedBox(height: 64),
                    Text(
                      "WEEKLY FOCUS",
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
                      title: "Gentle Goal",
                      content: data.topCategory != null
                          ? "Target a 10% reduction in ${data.topCategory!.toUpperCase()} spending."
                          : "Attempt to stay under budget for 5 days next week.",
                      subContent:
                          "Sustainable progress comes from consistent, small adjustments.",
                      index: 4,
                    ),
                    const SizedBox(height: 80),
                    Center(
                      child: Text(
                        "Reflection builds financial intuition.",
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
