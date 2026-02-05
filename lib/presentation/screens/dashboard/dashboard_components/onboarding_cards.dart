import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/core/theme/theme.dart';

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
            "GET STARTED",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: semantic.secondaryText,
              letterSpacing: 1.5,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              _buildActionCard(
                context,
                "Log First Expense",
                "Track where your money goes",
                Icons.add_shopping_cart_rounded,
                semantic.overspent,
                onAddTransaction,
              ),
              const SizedBox(width: 16),
              _buildActionCard(
                context,
                "Set a Budget",
                "Keep your spending in check",
                Icons.account_balance_rounded,
                semantic.income,
                onAddBudget,
              ),
              const SizedBox(width: 16),
              _buildActionCard(
                context,
                "See Analysis",
                "Identity spending patterns",
                Icons.insights_rounded,
                Colors.purpleAccent,
                onCheckAnalysis,
              ),
            ],
          ),
        ),
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
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 200,
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
