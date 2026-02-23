import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/screens/cards/credit_cards.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';

class CreditCardSummary extends StatelessWidget {
  final MonthlySummary summary;
  final AppColors semantic;
  final VoidCallback onLoad;

  const CreditCardSummary({
    super.key,
    required this.summary,
    required this.semantic,
    required this.onLoad,
  });

  @override
  Widget build(BuildContext context) {
    return HoverWrapper(
      onTap: () async {
        await Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CreditCardsScreen()));
        onLoad();
      },
      borderRadius: 28,
      glowColor: semantic.primary,
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
                color: semantic.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(CupertinoIcons.creditcard_fill,
                  size: 22, color: semantic.primary),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "CREDIT CARDS",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: semantic.secondaryText,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyFormatter.format(summary.creditCardDebt),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: semantic.text,
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
