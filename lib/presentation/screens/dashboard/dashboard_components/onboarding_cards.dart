import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/l10n/app_localizations.dart';
import 'package:trueledger/presentation/components/apple_style.dart';

class OnboardingActionCards extends StatelessWidget {
  final AppColors semantic;
  final VoidCallback onAddTransaction;
  final VoidCallback onAddBudget;
  final VoidCallback onCheckAnalysis;

  const OnboardingActionCards({
    super.key,
    required this.semantic,
    required this.onAddTransaction,
    required this.onAddBudget,
    required this.onCheckAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            AppLocalizations.of(context)!.getStarted,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: semantic.secondaryText,
              letterSpacing: 1.5,
            ),
          ),
        ),
        LayoutBuilder(builder: (context, constraints) {
          final useWrap = constraints.maxWidth > 400;
          return useWrap
              ? Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildActionCard(
                      context,
                      AppLocalizations.of(context)!.logFirstExpense,
                      AppLocalizations.of(context)!.logFirstExpenseDesc,
                      CupertinoIcons.cart_badge_plus,
                      semantic.overspent,
                      onAddTransaction,
                      constraints.maxWidth,
                    ),
                    _buildActionCard(
                      context,
                      AppLocalizations.of(context)!.setABudget,
                      AppLocalizations.of(context)!.setABudgetDesc,
                      CupertinoIcons.house_fill,
                      semantic.income,
                      onAddBudget,
                      constraints.maxWidth,
                    ),
                    _buildActionCard(
                      context,
                      AppLocalizations.of(context)!.seeAnalysis,
                      AppLocalizations.of(context)!.seeAnalysisDesc,
                      CupertinoIcons.sparkles,
                      semantic.primary,
                      onCheckAnalysis,
                      constraints.maxWidth,
                    ),
                  ],
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: [
                      _buildActionCard(
                        context,
                        AppLocalizations.of(context)!.logFirstExpense,
                        AppLocalizations.of(context)!.logFirstExpenseDesc,
                        CupertinoIcons.cart_badge_plus,
                        semantic.overspent,
                        onAddTransaction,
                        constraints.maxWidth,
                      ),
                      const SizedBox(width: 16),
                      _buildActionCard(
                        context,
                        AppLocalizations.of(context)!.setABudget,
                        AppLocalizations.of(context)!.setABudgetDesc,
                        CupertinoIcons.house_fill,
                        semantic.income,
                        onAddBudget,
                        constraints.maxWidth,
                      ),
                      const SizedBox(width: 16),
                      _buildActionCard(
                        context,
                        AppLocalizations.of(context)!.seeAnalysis,
                        AppLocalizations.of(context)!.seeAnalysisDesc,
                        CupertinoIcons.sparkles,
                        semantic.primary,
                        onCheckAnalysis,
                        constraints.maxWidth,
                      ),
                    ],
                  ),
                );
        }),
      ],
    ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
    double parentWidth,
  ) {
    // Adapt width based on available space
    final cardWidth = parentWidth > 600 ? 240.0 : 200.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppleGlassCard(
      onTap: onTap,
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      color: color.withValues(alpha: isDark ? 0.1 : 0.05),
      border: Border.all(
          color: color.withValues(alpha: isDark ? 0.25 : 0.35), width: 1.0),
      child: SizedBox(
        width: cardWidth - 40, // Subtract padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: semantic.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: semantic.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
