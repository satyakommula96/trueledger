import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/domain/usecases/get_weekly_reflection_usecase.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';
import 'package:trueledger/domain/usecases/usecase_base.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/presentation/components/error_view.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final dataAsync = ref.watch(weeklyReflectionProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: semantic.secondaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Weekly Reflection",
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
          onRetry: () => ref.refresh(weeklyReflectionProvider),
        ),
        data: (data) {
          final daysUnder = data.daysUnderBudget;
          final increaseData = data.largestCategoryIncrease;

          // Insights Logic
          String insight1 =
              "This week you stayed under budget $daysUnder days.";
          if (daysUnder == 7) {
            insight1 = "Perfect week! You stayed under budget every day.";
          } else if (daysUnder == 0) {
            insight1 = "It was a heavy week. Try to track closer next week.";
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  daysUnder > 3 ? "Great work this week." : "Review your week.",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                      color: colorScheme.onSurface,
                      height: 1.1),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 32),

                // Card 1: Days Under Budget
                _ReflectionCard(
                  semantic: semantic,
                  icon: daysUnder > 3
                      ? Icons.check_circle_rounded
                      : Icons.info_rounded,
                  iconColor: daysUnder > 3 ? semantic.income : semantic.warning,
                  title: "Spending Consistency",
                  content: insight1,
                  subContent:
                      "Daily Benchmark: ~${CurrencyFormatter.format(data.budgetDailyAverage, compact: true)}",
                ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1, end: 0),

                const SizedBox(height: 16),

                // Card 2: Highest Increase
                if (increaseData != null) ...[
                  _ReflectionCard(
                    semantic: semantic,
                    icon: Icons.trending_up_rounded,
                    iconColor: semantic.overspent,
                    title: "Spending Spike",
                    content:
                        "${increaseData['category']} spending increased by ${CurrencyFormatter.format(increaseData['increaseAmount'], compact: true)} vs last week.",
                    subContent: increaseData['isNew'] == true
                        ? "You didn't spend on this last week."
                        : "Keep an eye on this category.",
                  ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1, end: 0),
                ] else ...[
                  _ReflectionCard(
                    semantic: semantic,
                    icon: Icons.thumb_up_rounded,
                    iconColor: semantic.income,
                    title: "Stable Spending",
                    content:
                        "No significant spending spikes compared to last week.",
                    subContent: "You are maintaining your habits well.",
                  ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1, end: 0),
                ],

                const SizedBox(height: 16),

                // Card 3: Volume Comparison
                _ReflectionCard(
                  semantic: semantic,
                  icon: Icons.layers_rounded,
                  iconColor: Colors.blue,
                  title: "Volume Comparison",
                  content: data.totalThisWeek < data.totalLastWeek
                      ? "Great! You spent ${CurrencyFormatter.format(data.totalLastWeek - data.totalThisWeek)} less than last week."
                      : "You spent ${CurrencyFormatter.format(data.totalThisWeek - data.totalLastWeek)} more than last week.",
                  subContent:
                      "Last Week: ${CurrencyFormatter.format(data.totalLastWeek)} | This Week: ${CurrencyFormatter.format(data.totalThisWeek)}",
                ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0),

                if (data.topCategory != null) ...[
                  const SizedBox(height: 16),
                  // Card 4: Top Category
                  _ReflectionCard(
                    semantic: semantic,
                    icon: Icons.leaderboard_rounded,
                    iconColor: semantic.warning,
                    title: "Top Category",
                    content:
                        "Most of your money went to ${data.topCategory} this week.",
                    subContent: "Consider if this aligns with your priorities.",
                  ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1, end: 0),
                ],

                const SizedBox(height: 32),

                // Card 5: Gentle Goal
                Text(
                  "NEXT WEEK'S FOCUS",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: semantic.secondaryText,
                  ),
                ),
                const SizedBox(height: 12),
                _ReflectionCard(
                  semantic: semantic,
                  icon: Icons.flag_rounded,
                  iconColor: Colors.deepPurple,
                  title: "Gentle Goal",
                  content: data.topCategory != null
                      ? "Try reducing your ${data.topCategory} spending by 10%."
                      : "Try to stay under budget for 5 days next week.",
                  subContent: "Slow and steady progress is most sustainable.",
                ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.1, end: 0),

                const SizedBox(height: 48),

                Center(
                  child: Text(
                    "Reflection builds self-trust.",
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
