import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class HealthMeter extends StatelessWidget {
  final int score;
  final AppColors semantic;

  const HealthMeter({
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

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: semantic.divider.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 80,
            width: 80,
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    height: 80,
                    width: 80,
                    child: CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 8,
                      backgroundColor: semantic.divider.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    score.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 14, color: scoreColor),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: scoreColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Financial Health Score",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Based on your savings, debt, and budget habits.",
                  style: TextStyle(
                    fontSize: 11,
                    color: semantic.secondaryText,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
