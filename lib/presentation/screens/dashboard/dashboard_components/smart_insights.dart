import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/domain/services/intelligence_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';

import 'package:trueledger/presentation/screens/dashboard/scenario_mode.dart';
import 'package:trueledger/presentation/providers/insights_provider.dart';
import 'package:trueledger/domain/services/personalization_service.dart';

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
                color: const Color(0xFF00C853),
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
            itemCount: insights.length + 3, // +Score, +Scenario, +Reflection
            itemBuilder: (context, index) {
              // Always show ScoreCard first
              if (index == 0) {
                return _buildScoreCard(context)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideX(begin: 0.2, end: 0, curve: Curves.easeOutQuint);
              }

              // Show Insights
              if (index > 0 && index <= insights.length) {
                final insight = insights[index - 1];
                return _buildInsightItem(context, insight, isPrivate)
                    .animate()
                    .fadeIn(delay: (100 * index).ms, duration: 600.ms)
                    .slideX(begin: 0.2, end: 0, curve: Curves.easeOutQuint);
              }

              // Show Reflections
              if (index == insights.length + 1) {
                return _buildReflectionCard(context, ref)
                    .animate()
                    .fadeIn(delay: (100 * index).ms, duration: 600.ms)
                    .slideX(begin: 0.2, end: 0, curve: Curves.easeOutQuint);
              }

              // Show Scenario Card at the end
              if (index == insights.length + 2) {
                return _buildScenarioCard(context)
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

  Widget _buildScenarioCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 4, bottom: 4),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ScenarioScreen()));
        },
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.rocket_launch_rounded,
                  color: Colors.white, size: 32),
              const SizedBox(height: 16),
              const Text(
                "SCENARIO MODE",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Simulate your future progress.",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
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

  Widget _buildReflectionCard(BuildContext context, WidgetRef ref) {
    final reflections =
        ref.read(personalizationServiceProvider).generateBaselineReflections();

    if (reflections.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_outlined,
                  size: 16, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                "SELF REFLECTION",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: semantic.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Text(
              reflections.first,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Based on your local history.",
            style: TextStyle(
              fontSize: 11,
              color: semantic.secondaryText,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
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

class InsightItem extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            insight.currencyValue != null
                                ? "${insight.value}: ${CurrencyFormatter.format(insight.currencyValue!, isPrivate: isPrivate)}"
                                : insight.value,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: accentColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: Icons.access_time_rounded,
                          tooltip: "Snooze 7 days",
                          onTap: () async {
                            await ref
                                .read(intelligenceServiceProvider)
                                .snoozeInsight(insight.id, days: 7);
                            ref.invalidate(insightsProvider);
                          },
                        ),
                        const SizedBox(width: 4),
                        _buildActionButton(
                          icon: Icons.close_rounded,
                          tooltip: "Dismiss",
                          onTap: () async {
                            await ref
                                .read(intelligenceServiceProvider)
                                .dismissInsight(insight.id, insight.group);
                            ref.invalidate(insightsProvider);
                          },
                        ),
                      ],
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

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              icon,
              size: 16,
              color: semantic.secondaryText.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
