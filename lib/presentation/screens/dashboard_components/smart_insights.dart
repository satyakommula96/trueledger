import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:truecash/domain/services/intelligence_service.dart';

import 'package:truecash/core/theme/theme.dart';

class SmartInsightsCard extends StatelessWidget {
  final List<AIInsight> insights;
  final AppColors semantic;

  const SmartInsightsCard({
    super.key,
    required this.insights,
    required this.semantic,
  });

  @override
  Widget build(BuildContext context) {
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
                Text("AI Powered Forecasts",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome,
                      size: 12, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 4),
                  Text("BETA",
                      style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary)),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(duration: 600.ms),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: insights.length,
            itemBuilder: (context, index) {
              final insight = insights[index];
              return _buildInsightItem(context, insight)
                  .animate()
                  .fadeIn(delay: (100 * index).ms, duration: 600.ms)
                  .slideX(begin: 0.2, end: 0, curve: Curves.easeOutQuint);
            },
          ),
        ),
      ],
    ).animate().fadeIn(duration: 800.ms);
  }

  Widget _buildInsightItem(BuildContext context, AIInsight insight) {
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

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
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
                insight.value,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
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
    );
  }
}
