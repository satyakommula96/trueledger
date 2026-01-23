import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../logic/monthly_calc.dart';

class WealthHero extends StatelessWidget {
  final MonthlySummary summary;

  const WealthHero({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 12)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(Icons.account_balance_wallet,
                size: 200, color: Colors.white.withValues(alpha: 0.1)),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1))),
                      child: Row(
                        children: [
                          Icon(Icons.verified_user_outlined,
                              size: 14,
                              color:
                                  colorScheme.onPrimary.withValues(alpha: 0.8)),
                          const SizedBox(width: 6),
                          Text("TOTAL NET WORTH",
                              style: TextStyle(
                                  color: colorScheme.onPrimary
                                      .withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                  letterSpacing: 1)),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "₹${NumberFormat.decimalPattern('en_IN').format(summary.netWorth)}",
                        style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                            height: 1.0)),
                    const SizedBox(height: 8),
                    Text("AFTER LIABILITIES",
                        style: TextStyle(
                            color: colorScheme.onPrimary.withValues(alpha: 0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
