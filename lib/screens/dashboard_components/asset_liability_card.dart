import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../logic/monthly_calc.dart';
import '../../theme/theme.dart';

class AssetLiabilityCard extends StatelessWidget {
  final MonthlySummary summary;
  final AppColors semantic;

  const AssetLiabilityCard({
    super.key,
    required this.summary,
    required this.semantic,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    semantic.income.withValues(alpha: 0.15),
                    semantic.income.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: semantic.income.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: semantic.income.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]),
            child: Stack(
              children: [
                Positioned(
                    right: -10,
                    bottom: -10,
                    child: Icon(Icons.account_balance,
                        size: 48,
                        color: semantic.income.withValues(alpha: 0.1))),
                _buildMiniStat(
                    "TOTAL ASSETS",
                    "₹${NumberFormat.compact(locale: 'en_IN').format(summary.netWorth + summary.creditCardDebt + summary.loansTotal)}",
                    semantic.income,
                    semantic),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    semantic.overspent.withValues(alpha: 0.15),
                    semantic.overspent.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: semantic.overspent.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: semantic.overspent.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]),
            child: Stack(
              children: [
                Positioned(
                    right: -10,
                    bottom: -10,
                    child: Icon(Icons.remove_circle_outline,
                        size: 48,
                        color: semantic.overspent.withValues(alpha: 0.1))),
                _buildMiniStat(
                    "LIABILITIES",
                    "₹${NumberFormat.compact(locale: 'en_IN').format(summary.creditCardDebt + summary.loansTotal)}",
                    semantic.overspent,
                    semantic),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(
      String label, String val, Color color, AppColors semantic) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: TextStyle(
              color: semantic.secondaryText,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2)),
      const SizedBox(height: 6),
      Text(val,
          style: TextStyle(
              color: color, fontSize: 16, fontWeight: FontWeight.w800)),
    ]);
  }
}
