import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/core/config/app_config.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/components/apple_style.dart';
import 'package:trueledger/l10n/app_localizations.dart';

class StreakCard extends StatelessWidget {
  final int activeStreak;
  final bool hasLoggedToday;

  const StreakCard({
    super.key,
    required this.activeStreak,
    required this.hasLoggedToday,
  });

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return AppleGlassCard(
      padding: const EdgeInsets.all(24),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFFF9500).withValues(alpha: 0.15),
          const Color(0xFFFF2D55).withValues(alpha: 0.05),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
            ),
            child: const Icon(
              CupertinoIcons.flame_fill,
              color: Colors.orange,
              size: 32,
            )
                .animate(
                    onPlay: (c) => !AppConfig.isTest
                        ? c.repeat(reverse: true)
                        : c.forward())
                .scale(
                    duration: 1.seconds,
                    begin: const Offset(1, 1),
                    end: const Offset(1.15, 1.15),
                    curve: Curves.easeInOut),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dailyStreak.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: semantic.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$activeStreak ${activeStreak == 1 ? 'Day' : 'Days'}",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: semantic.text,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasLoggedToday ? "STREAK SECURED" : "LOG TODAY TO CONTINUE",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color:
                        hasLoggedToday ? semantic.income : semantic.overspent,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}
