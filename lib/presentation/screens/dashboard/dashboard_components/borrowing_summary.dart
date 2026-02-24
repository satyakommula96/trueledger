import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
      borderRadius: 28,
      glowColor: semantic.overspent,
      glowOpacity: 0.1,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: semantic.surfaceCombined.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: semantic.divider, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: semantic.overspent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(CupertinoIcons.building_2_fill,
                  size: 22, color: semantic.overspent),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "BORROWINGS",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: semantic.secondaryText,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyFormatter.format(summary.loansTotal),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: semantic.overspent,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
            ),
            Icon(CupertinoIcons.chevron_right,
                size: 16, color: semantic.secondaryText.withValues(alpha: 0.5)),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }
}
