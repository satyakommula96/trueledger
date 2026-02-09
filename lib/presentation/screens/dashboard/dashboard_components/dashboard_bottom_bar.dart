import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/screens/cards/credit_cards.dart';
import 'package:trueledger/presentation/screens/transactions/monthly_history.dart';
import 'package:trueledger/presentation/screens/analysis/analysis_screen.dart';
import 'package:trueledger/presentation/screens/loans/loans.dart';
import 'package:trueledger/presentation/screens/goals/goals_screen.dart';
import 'package:trueledger/presentation/screens/investments/investments_screen.dart';
import 'package:trueledger/presentation/screens/automation/recurring_transactions.dart';
import 'package:trueledger/presentation/screens/budget/budget_screen.dart';

class DashboardBottomBar extends StatelessWidget {
  final VoidCallback onLoad;

  const DashboardBottomBar({
    super.key,
    required this.onLoad,
  });

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final padding = MediaQuery.of(context).padding;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + padding.bottom),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: semantic.surfaceCombined.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: semantic.divider, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildActionIcon(
                  context,
                  Icons.account_balance_rounded,
                  "Accounts",
                  semantic.income,
                  () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LoansScreen())),
                  semantic,
                ),
                _buildActionIcon(
                  context,
                  Icons.credit_card_rounded,
                  "Cards",
                  semantic.primary,
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CreditCardsScreen())),
                  semantic,
                ),
                _buildActionIcon(
                  context,
                  Icons.auto_graph_rounded,
                  "Analysis",
                  const Color(0xFFA855F7),
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AnalysisScreen())),
                  semantic,
                ),
                _buildActionIcon(
                  context,
                  Icons.grid_view_rounded,
                  "More",
                  semantic.warning,
                  () => _showMoreMenu(context, semantic),
                  semantic,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMoreMenu(BuildContext context, AppColors semantic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: semantic.surfaceCombined,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMenuItem(
                context,
                Icons.savings_rounded,
                "Saving Goals",
                "Track your milestones",
                const Color(0xFF10B981),
                () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const GoalsScreen()));
                },
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                context,
                Icons.pie_chart_rounded,
                "Portfolio",
                "Manage asset allocation",
                const Color(0xFF10B981),
                () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const InvestmentsScreen()));
                },
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                context,
                Icons.history_toggle_off_rounded,
                "Monthly History",
                "View past performance",
                semantic.warning,
                () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MonthlyHistoryScreen()));
                },
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                context,
                Icons.auto_awesome_rounded,
                "Automation",
                "Recurring transactions",
                const Color(0xFF10B981),
                () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RecurringTransactionsScreen()));
                },
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                context,
                Icons.account_balance_wallet_rounded,
                "Budgets",
                "Manage spending limits",
                semantic.primary,
                () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const BudgetScreen()));
                },
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title,
      String subtitle, Color color, VoidCallback onTap) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: semantic.divider),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle,
                    style:
                        TextStyle(color: semantic.secondaryText, fontSize: 12)),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: semantic.divider),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon(BuildContext context, IconData icon, String label,
      Color iconColor, VoidCallback onTap, AppColors semantic) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: iconColor.withValues(alpha: 0.9)),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: semantic.secondaryText,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
