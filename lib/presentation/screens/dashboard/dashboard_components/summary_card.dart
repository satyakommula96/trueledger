import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';
import 'package:trueledger/presentation/components/apple_style.dart';

class SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final AppColors semantic;
  final IconData icon;
  final VoidCallback? onTap;

  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.semantic,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return HoverWrapper(
      onTap: onTap,
      borderRadius: 24,
      glowColor: valueColor,
      glowOpacity: 0.05,
      child: AppleGlassCard(
        borderRadius: 24,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: valueColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: valueColor),
            ),
            const SizedBox(height: 16),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                color: semantic.secondaryText,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: semantic.text,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }
}

class FullWidthSummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final AppColors semantic;
  final VoidCallback? onTap;

  const FullWidthSummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.semantic,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return HoverWrapper(
      onTap: onTap,
      borderRadius: 24,
      glowColor: valueColor,
      glowOpacity: 0.05,
      child: AppleGlassCard(
        borderRadius: 24,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: valueColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                valueColor == semantic.income
                    ? CupertinoIcons.square_stack_3d_up_fill
                    : CupertinoIcons.doc_text_fill,
                size: 20,
                color: valueColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: semantic.secondaryText,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: semantic.text,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 14,
              color: semantic.secondaryText.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.1, end: 0);
  }
}
