import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/screens/loans/loans.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';

import 'package:trueledger/presentation/components/hover_wrapper.dart';

class BorrowingSummary extends StatelessWidget {
  final MonthlySummary summary;
  final AppColors semantic;
  final VoidCallback onLoad;

  const BorrowingSummary({
    super.key,
    required this.summary,
    required this.semantic,
    required this.onLoad,
  });

  @override
  Widget build(BuildContext context) {
    return HoverWrapper(
      onTap: () async {
        await Navigator.push(
            context, MaterialPageRoute(builder: (_) => const LoansScreen()));
        onLoad();
      },
      borderRadius: 24,
      glowColor: semantic.overspent,
      glowOpacity: 0.1,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: semantic.divider.withValues(alpha: 0.5)),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surface,
              semantic.surfaceCombined.withValues(alpha: 0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: semantic.overspent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.account_balance_rounded,
                  size: 20, color: semantic.overspent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("BORROWINGS",
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: semantic.secondaryText,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  Text(CurrencyFormatter.format(summary.loansTotal),
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: semantic.overspent,
                          letterSpacing: -1)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: semantic.secondaryText),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }
}
