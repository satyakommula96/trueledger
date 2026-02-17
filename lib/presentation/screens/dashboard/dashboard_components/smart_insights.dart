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
import 'package:trueledger/l10n/app_localizations.dart';

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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.intelligentInsights,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: semantic.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.aiPoweredAnalysis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: semantic.text,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: semantic.surfaceCombined.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: semantic.divider, width: 1.5),
              ),
              child: Icon(Icons.psychology_rounded,
                  size: 20, color: semantic.primary),
            ),
          ],
        ).animate().fadeIn(duration: 600.ms),
        const SizedBox(height: 24),
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            itemCount: insights.length + 3, // +Score, +Reflection, +Scenario
            itemBuilder: (context, index) {
              Widget child;
              if (index == 0) {
                child = ScoreCard(score: score, semantic: semantic);
              } else if (index > 0 && index <= insights.length) {
                child = InsightItem(
                    insight: insights[index - 1],
                    isPrivate: isPrivate,
                    semantic: semantic);
              } else if (index == insights.length + 1) {
                child = _buildReflectionCard(context, ref);
              } else {
                child = _buildScenarioCard(context);
              }

              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: child
                    .animate()
                    .fadeIn(delay: (40 * index).ms, duration: 600.ms)
                    .slideX(begin: 0.1, end: 0, curve: Curves.easeOutQuint),
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(duration: 800.ms);
  }

  Widget _buildScenarioCard(BuildContext context) {
    return HoverWrapper(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const ScenarioScreen())),
      borderRadius: 28,
      glowColor: semantic.primary,
      glowOpacity: 0.1,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: semantic.primary.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: semantic.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.rocket_launch_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.scenarioModeLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.simulateFuture,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReflectionCard(BuildContext context, WidgetRef ref) {
    final reflections =
        ref.read(personalizationServiceProvider).generateBaselineReflections();
    if (reflections.isEmpty) return const SizedBox.shrink();

    return Container(
      width: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: semantic.surfaceCombined.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: semantic.divider, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: semantic.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.auto_awesome_rounded,
                    size: 16, color: semantic.primary),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.mindset,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: semantic.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Text(
              reflections.first,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: semantic.text,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.basedOnLocalHistory,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: semantic.secondaryText.withValues(alpha: 0.5),
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
      scoreColor = semantic.success;
      label = AppLocalizations.of(context)!.excellentLabel;
      icon = Icons.verified_rounded;
    } else if (score >= 60) {
      scoreColor = semantic.primary;
      label = AppLocalizations.of(context)!.goodLabel;
      icon = Icons.trending_up_rounded;
    } else if (score >= 40) {
      scoreColor = semantic.warning;
      label = AppLocalizations.of(context)!.averageLabel;
      icon = Icons.info_rounded;
    } else if (score == 0) {
      scoreColor = semantic.secondaryText;
      label = AppLocalizations.of(context)!.calibrating;
      icon = Icons.hourglass_empty_rounded;
    } else {
      scoreColor = semantic.overspent;
      label = AppLocalizations.of(context)!.atRisk;
      icon = Icons.warning_rounded;
    }

    return HoverWrapper(
      borderRadius: 28,
      glowColor: scoreColor,
      glowOpacity: 0.1,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: semantic.surfaceCombined.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: semantic.divider, width: 1.5),
        ),
        child: Row(
          children: [
            SizedBox(
              height: 72,
              width: 72,
              child: Stack(
                children: [
                  Center(
                    child: CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 8,
                      backgroundColor: semantic.divider,
                      valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Center(
                    child: Text(
                      score.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: semantic.text,
                        letterSpacing: -0.5,
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
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: scoreColor,
                            letterSpacing: 1.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.healthScore,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: semantic.text,
                        letterSpacing: -0.2),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppLocalizations.of(context)!.aiPoweredAnalysis,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: semantic.secondaryText),
                  ),
                ],
              ),
            ),
          ],
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
        accentColor = semantic.success;
        icon = Icons.check_circle_rounded;
        break;
      case InsightType.prediction:
        accentColor = semantic.primary;
        icon = Icons.auto_awesome_rounded;
        break;
      default:
        accentColor = semantic.primary;
        icon = Icons.lightbulb_rounded;
    }

    return HoverWrapper(
      borderRadius: 28,
      glowColor: accentColor,
      glowOpacity: 0.1,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: semantic.surfaceCombined.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: semantic.divider, width: 1.5),
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: accentColor),
                ),
                Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.access_time_rounded,
                      tooltip: AppLocalizations.of(context)!.snooze7Days,
                      onTap: () async {
                        await ref
                            .read(intelligenceServiceProvider)
                            .snoozeInsight(insight.id, days: 7);
                        ref.invalidate(insightsProvider);
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.close_rounded,
                      tooltip: AppLocalizations.of(context)!.dismiss,
                      onTap: () async {
                        await ref
                            .read(intelligenceServiceProvider)
                            .dismissInsight(insight.id, insight.group);
                        ref.invalidate(insightsProvider);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              insight.title.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: semantic.secondaryText,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                insight.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: semantic.text,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (insight.currencyValue != null)
              Text(
                CurrencyFormatter.format(insight.currencyValue!,
                    isPrivate: isPrivate),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: accentColor,
                ),
              ),
          ],
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
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: semantic.divider.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: semantic.secondaryText),
        ),
      ),
    );
  }
}
