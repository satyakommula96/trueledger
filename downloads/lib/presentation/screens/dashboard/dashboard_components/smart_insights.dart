import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/domain/services/intelligence_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';

class SmartInsightsCard extends ConsumerWidget {
  final List<AIInsight> insights;
  final AppColors semantic;
  final int score;

  const SmartInsightsCard({
    super.key,
    required this.insights,
    required this.semantic,
    required this.score,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivate = ref.watch(privacyProvider);
    if (insights.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("INTELLIGENT INSIGHTS",
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: semantic.secondaryText)),
                const SizedBox(height: 4),
                Text("AI Powered Analysis",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853), // Material Green A700
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.psychology_rounded,
                  size: 16, color: Colors.white),
            ),
          ],
        ).animate().fadeIn(duration: 600.ms),
        const SizedBox(height: 16),
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: insights.length + 1,
            itemBuilder: (context, index) {
              // Priority: 1. Wealth Projection, 2. ScoreCard, 3. Other Insights

              // We want: [Wealth Projection] (if exists) -> [ScoreCard] -> [Remaining Insights]

              final hasWealth =
                  insights.any((i) => i.title == "WEALTH PROJECTION");

              if (index == 0 && hasWealth) {
                final wealth =
                    insights.firstWhere((i) => i.title == "WEALTH PROJECTION");
                return _buildInsightItem(context, wealth, isPrivate)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideX(begin: 0.2, end: 0, curve: Curves.easeOutQuint);
              }

              // If index 0 and no wealth, show ScoreCard
              if (index == 0 && !hasWealth) {
                return _buildScoreCard(context)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideX(begin: 0.2, end: 0, curve: Curves.easeOutQuint);
              }

              // If index 1 and has wealth, show ScoreCard
              if (index == 1 && hasWealth) {
                return _buildScoreCard(context)
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 600.ms)
                    .slideX(begin: 0.2, end: 0, curve: Curves.easeOutQuint);
              }

              // Otherwise show remaining insights
              // Adjust offset based on whether wealth exists
              // Skip the wealth projection if we encounter it in the list again
              final dynInsights = insights
                  .where((i) => i.title != "WEALTH PROJECTION")
                  .toList();
              final currentDynIndex = hasWealth ? index - 2 : index - 1;

              if (currentDynIndex >= 0 &&
                  currentDynIndex < dynInsights.length) {
                return _buildInsightItem(
                        context, dynInsights[currentDynIndex], isPrivate)
                    .animate()
                    .fadeIn(delay: (100 * index).ms, duration: 600.ms)
                    .slideX(begin: 0.2, end: 0, curve: Curves.easeOutQuint);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    ).animate().fadeIn(duration: 800.ms);
  }

  Widget _buildScoreCard(BuildContext context) {
    return ScoreCard(
      score: score,
      semantic: semantic,
    );
  }

  Widget _buildInsightItem(
      BuildContext context, AIInsight insight, bool isPrivate) {
    return InsightItem(
      insight: insight,
      isPrivate: isPrivate,
      semantic: semantic,
    );
  }
}

class ScoreCard extends StatelessWidget {
  final int score;
  final AppColors semantic;

  const ScoreCard({
    super.key,
    required this.score,
    required this.semantic,
  });

  @override
  Widget build(BuildContext context) {
    Color scoreColor;
    String label;
    IconData icon;

    if (score >= 80) {
      scoreColor = semantic.income;
      label = "EXCELLENT";
      icon = Icons.verified_rounded;
    } else if (score >= 60) {
      scoreColor = Colors.blue;
      label = "GOOD";
      icon = Icons.trending_up_rounded;
    } else if (score >= 40) {
      scoreColor = semantic.warning;
      label = "AVERAGE";
      icon = Icons.info_rounded;
    } else {
      scoreColor = semantic.overspent;
      label = "AT RISK";
      icon = Icons.warning_rounded;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 4, bottom: 4),
      child: HoverWrapper(
        borderRadius: 24,
        glowColor: scoreColor,
        glowOpacity: 0.15,
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: scoreColor.withValues(alpha: 0.1)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scoreColor.withValues(alpha: 0.05),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                height: 70,
                width: 70,
                child: Stack(
                  children: [
                    Center(
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 6,
                        backgroundColor:
                            semantic.divider.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Center(
                      child: Text(
                        score.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 12, color: scoreColor),
                        const SizedBox(width: 4),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: scoreColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Health Score",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "AI Analysis of your habits.",
                      style: TextStyle(
                        fontSize: 10,
                        color: semantic.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InsightItem extends StatelessWidget {
  final AIInsight insight;
  final bool isPrivate;
  final AppColors semantic;

  const InsightItem({
    super.key,
    required this.insight,
    required this.isPrivate,
    required this.semantic,
  });

  @override
  Widget build(BuildContext context) {
    Color accentColor;
    IconData icon;

    switch (insight.type) {
      case InsightType.warning:
        accentColor = semantic.overspent;
        icon = Icons.warning_rounded;
        break;
      case InsightType.success:
        accentColor = semantic.income;
        icon = Icons.check_circle_rounded;
        break;
      case InsightType.prediction:
        accentColor = Colors.blue;
        icon = Icons.trending_up_rounded;
        break;
      default:
        accentColor = Theme.of(context).colorScheme.primary;
        icon = Icons.lightbulb_rounded;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 4, bottom: 4),
      child: HoverWrapper(
        borderRadius: 24,
        glowColor: accentColor,
        glowOpacity: 0.15,
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: accentColor.withValues(alpha: 0.1)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentColor.withValues(alpha: 0.05),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 18, color: accentColor),
                  ),
                  Text(
                    insight.currencyValue != null
                        ? "${insight.value}: ${CurrencyFormatter.format(insight.currencyValue!, isPrivate: isPrivate)}"
                        : insight.value,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                insight.title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  insight.body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: semantic.secondaryText,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
