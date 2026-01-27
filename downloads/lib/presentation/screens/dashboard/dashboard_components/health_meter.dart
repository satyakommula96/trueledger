import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';

class HealthMeter extends StatefulWidget {
  final int score;
  final AppColors semantic;

  const HealthMeter({
    super.key,
    required this.score,
    required this.semantic,
  });

  @override
  State<HealthMeter> createState() => _HealthMeterState();
}

class _HealthMeterState extends State<HealthMeter> {
  @override
  Widget build(BuildContext context) {
    Color scoreColor;
    String label;
    IconData icon;

    if (widget.score >= 80) {
      scoreColor = widget.semantic.income;
      label = "EXCELLENT";
      icon = Icons.verified_rounded;
    } else if (widget.score >= 60) {
      scoreColor = Colors.blue;
      label = "GOOD";
      icon = Icons.trending_up_rounded;
    } else if (widget.score >= 40) {
      scoreColor = widget.semantic.warning;
      label = "AVERAGE";
      icon = Icons.info_rounded;
    } else {
      scoreColor = widget.semantic.overspent;
      label = "AT RISK";
      icon = Icons.warning_rounded;
    }

    return HoverWrapper(
      borderRadius: 24,
      glowColor: scoreColor,
      glowOpacity: 0.15,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border:
              Border.all(color: widget.semantic.divider.withValues(alpha: 0.5)),
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
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: widget.score / 100),
                        duration: 1500.ms,
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) =>
                            CircularProgressIndicator(
                          value: value,
                          strokeWidth: 8,
                          backgroundColor:
                              widget.semantic.divider.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      widget.score.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ).animate().scale(
                        delay: 400.ms,
                        duration: 400.ms,
                        curve: Curves.easeOutBack),
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
                      Icon(icon, size: 14, color: scoreColor)
                          .animate()
                          .fadeIn(delay: 600.ms),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: scoreColor,
                          letterSpacing: 1.5,
                        ),
                      ).animate().fadeIn(delay: 700.ms),
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
                  ).animate().fadeIn(delay: 800.ms),
                  const SizedBox(height: 4),
                  Text(
                    "Based on your savings, debt, and budget habits.",
                    style: TextStyle(
                      fontSize: 11,
                      color: widget.semantic.secondaryText,
                      height: 1.3,
                    ),
                  ).animate().fadeIn(delay: 900.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1, end: 0);
  }
}
