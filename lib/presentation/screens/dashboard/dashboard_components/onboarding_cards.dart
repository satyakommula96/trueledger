import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/l10n/app_localizations.dart';

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
                      Icons.add_shopping_cart_rounded,
                      semantic.overspent,
                      onAddTransaction,
                      constraints.maxWidth,
                    ),
                    _buildActionCard(
                      context,
                      AppLocalizations.of(context)!.setABudget,
                      AppLocalizations.of(context)!.setABudgetDesc,
                      Icons.account_balance_rounded,
                      semantic.income,
                      onAddBudget,
                      constraints.maxWidth,
                    ),
                    _buildActionCard(
                      context,
                      AppLocalizations.of(context)!.seeAnalysis,
                      AppLocalizations.of(context)!.seeAnalysisDesc,
                      Icons.insights_rounded,
                      Colors.purpleAccent,
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
                        Icons.add_shopping_cart_rounded,
                        semantic.overspent,
                        onAddTransaction,
                        constraints.maxWidth,
                      ),
                      const SizedBox(width: 16),
                      _buildActionCard(
                        context,
                        AppLocalizations.of(context)!.setABudget,
                        AppLocalizations.of(context)!.setABudgetDesc,
                        Icons.account_balance_rounded,
                        semantic.income,
                        onAddBudget,
                        constraints.maxWidth,
                      ),
                      const SizedBox(width: 16),
                      _buildActionCard(
                        context,
                        AppLocalizations.of(context)!.seeAnalysis,
                        AppLocalizations.of(context)!.seeAnalysisDesc,
                        Icons.insights_rounded,
                        Colors.purpleAccent,
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
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
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
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
