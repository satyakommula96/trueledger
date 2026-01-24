import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:truecash/domain/models/models.dart';
import 'package:truecash/core/theme/theme.dart';
import 'package:truecash/core/utils/currency_helper.dart';

class WealthHero extends StatelessWidget {
  final MonthlySummary summary;

  const WealthHero({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appColors = Theme.of(context).extension<AppColors>();
    final isNegative = summary.netWorth < 0;
    final displayColor = isNegative
        ? (appColors?.overspent ?? colorScheme.error)
        : colorScheme.primary;

    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [displayColor, displayColor.withValues(alpha: 0.8)],
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
              color: displayColor.withValues(alpha: 0.3),
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
                          Text("NET WORTH",
                              style: TextStyle(
                                  color: colorScheme.onPrimary
                                      .withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                  letterSpacing: 1)),
                        ],
                      ),
                    )
                        .animate()
                        .scale(duration: 400.ms, curve: Curves.easeOutBack),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        CurrencyHelper.format(summary.netWorth, compact: false),
                        style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                            height: 1.0)),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .moveY(begin: 10, end: 0, curve: Curves.easeOutQuint),
              ],
            ),
          ),
        ],
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true)).shimmer(
        duration: 3.seconds,
        delay: 2.seconds,
        color: Colors.white.withValues(alpha: 0.1));
  }
}
