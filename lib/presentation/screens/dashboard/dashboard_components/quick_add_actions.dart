import 'package:flutter/material.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/screens/transactions/add_expense.dart';
import 'package:trueledger/presentation/screens/loans/add_loan.dart';
import 'package:trueledger/presentation/screens/cards/add_card.dart';

class QuickAddActions extends StatelessWidget {
  final AppColors semantic;
  final VoidCallback onActionComplete;

  const QuickAddActions({
    super.key,
    required this.semantic,
    required this.onActionComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("QUICK ADD",
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.grey,
                letterSpacing: 2)),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildAction(
              context,
              "Income",
              Icons.add_chart_rounded,
              semantic.income,
              () => _navigate(
                  context,
                  const AddExpense(
                      initialType: 'Income', allowedTypes: ['Income'])),
            ),
            const SizedBox(width: 12),
            _buildAction(
              context,
              "Expense",
              Icons.shopping_cart_checkout_rounded,
              semantic.overspent,
              () => _navigate(
                  context,
                  const AddExpense(
                      initialType: 'Variable',
                      allowedTypes: ['Variable', 'Fixed', 'Subscription'])),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildAction(
              context,
              "Asset",
              Icons.trending_up_rounded,
              Colors.blue,
              () => _navigate(
                  context,
                  const AddExpense(
                      initialType: 'Investment', allowedTypes: ['Investment'])),
            ),
            const SizedBox(width: 12),
            _buildAction(
              context,
              "Liability",
              Icons.account_balance_rounded,
              Colors.orange,
              () => _showLiabilityOptions(context),
            ),
          ],
        ),
      ],
    );
  }

  void _navigate(BuildContext context, Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    onActionComplete();
  }

  void _showLiabilityOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text("ADD LIABILITY",
                style:
                    TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
            const SizedBox(height: 24),
            ListTile(
              leading:
                  const Icon(Icons.credit_card_rounded, color: Colors.orange),
              title: const Text("Credit Card",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Add a new card with balance"),
              onTap: () {
                Navigator.pop(context);
                _navigate(context, const AddCreditCardScreen());
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.handshake_rounded, color: Colors.orange),
              title: const Text("Bank/Personal Loan",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Add a new loan or borrowing"),
              onTap: () {
                Navigator.pop(context);
                _navigate(context, const AddLoanScreen());
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAction(BuildContext context, String label, IconData icon,
      Color color, VoidCallback onTap) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          child: RepaintBoundary(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.08),
                      color.withValues(alpha: 0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withValues(alpha: 0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(icon, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
