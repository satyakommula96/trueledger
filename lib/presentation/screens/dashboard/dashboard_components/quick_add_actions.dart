import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/screens/transactions/add_expense.dart';
import 'package:trueledger/presentation/screens/loans/add_loan.dart';
import 'package:trueledger/presentation/screens/cards/add_card.dart';
import 'package:trueledger/presentation/components/apple_style.dart';

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
        Text(
          "QUICK ADD",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: semantic.secondaryText,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildAction(
              context,
              "Income",
              CupertinoIcons.checkmark_circle_fill,
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
              CupertinoIcons.minus_circle_fill,
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
              CupertinoIcons.graph_circle_fill,
              semantic.primary,
              () => _navigate(
                  context,
                  const AddExpense(
                      initialType: 'Investment', allowedTypes: ['Investment'])),
            ),
            const SizedBox(width: 12),
            _buildAction(
              context,
              "Liability",
              CupertinoIcons.building_2_fill,
              semantic.warning,
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
      builder: (context) => AppleGlassCard(
        borderRadius: 32,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: semantic.secondaryText.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Icon(CupertinoIcons.chevron_right,
                  size: 14, color: semantic.secondaryText),
            ),
            const SizedBox(height: 24),
            Text(
              "ADD LIABILITY",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: semantic.text,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading:
                  Icon(CupertinoIcons.creditcard_fill, color: semantic.warning),
              title: Text("Credit Card",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: semantic.text)),
              subtitle: Text("Add a new card with balance",
                  style: TextStyle(color: semantic.secondaryText)),
              onTap: () {
                Navigator.pop(context);
                _navigate(context, const AddCreditCardScreen());
              },
            ),
            ListTile(
              leading:
                  Icon(CupertinoIcons.person_2_fill, color: semantic.warning),
              title: Text("Bank/Personal Loan",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: semantic.text)),
              subtitle: Text("Add a new loan or borrowing",
                  style: TextStyle(color: semantic.secondaryText)),
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
      child: AppleGlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 24,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
                    color: semantic.text,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
