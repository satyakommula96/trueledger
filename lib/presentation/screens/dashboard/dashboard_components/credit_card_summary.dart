import 'package:flutter/material.dart';
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
      borderRadius: 24,
      glowColor: Colors.blue,
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
                color: Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.credit_card_rounded,
                  size: 20, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("CREDIT CARDS",
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.blue,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  Text(CurrencyFormatter.format(summary.creditCardDebt),
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
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
