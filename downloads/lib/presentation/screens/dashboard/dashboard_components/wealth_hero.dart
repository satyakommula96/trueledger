import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';

class WealthHero extends ConsumerStatefulWidget {
  final MonthlySummary summary;

  const WealthHero({super.key, required this.summary});

  @override
  ConsumerState<WealthHero> createState() => _WealthHeroState();
}

class _WealthHeroState extends ConsumerState<WealthHero> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isPrivate = ref.watch(privacyProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final appColors = Theme.of(context).extension<AppColors>();
    final isNegative = widget.summary.netWorth < 0;
    final displayColor = isNegative
        ? (appColors?.overspent ?? colorScheme.error)
        : colorScheme.primary;

    final isTouch = Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.android;

    final mainContent = AnimatedContainer(
      duration: 300.ms,
      curve: Curves.easeOutQuint,
      // ignore: deprecated_member_use
      transform: Matrix4.identity()
        // ignore: deprecated_member_use
        ..scale(_isHovered ? 1.02 : 1.0)
        // ignore: deprecated_member_use
        ..translate(0.0, _isHovered ? -4.0 : 0.0),
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            displayColor.withValues(alpha: 0.95),
            displayColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: _isHovered
              ? Colors.white.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
              color: displayColor.withValues(alpha: _isHovered ? 0.4 : 0.3),
              blurRadius: _isHovered ? 40 : 24,
              offset: Offset(0, _isHovered ? 20 : 12)),
        ],
      ),
      child: Stack(
        children: [
          // Abstract Background Shapes
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildHeaderPill(context, "NET WORTH",
                        Icons.account_balance_wallet_rounded),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        CurrencyFormatter.format(widget.summary.netWorth,
                            compact: false, isPrivate: isPrivate),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -2,
                            height: 1.0)),
                  ],
                ).animate().fadeIn(duration: 600.ms).moveY(begin: 20, end: 0),
              ],
            ),
          ),
        ],
      ),
    );

    if (isTouch) {
      return mainContent
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .shimmer(
              duration: 3.seconds,
              delay: 2.seconds,
              color: Colors.white.withValues(alpha: 0.1));
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: mainContent,
    ).animate(onPlay: (controller) => controller.repeat(reverse: true)).shimmer(
        duration: 3.seconds,
        delay: 2.seconds,
        color: Colors.white.withValues(alpha: 0.1));
  }

  Widget _buildHeaderPill(BuildContext context, String text, IconData icon,
      {bool isAlt = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: isAlt
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(width: 6),
          Text(text,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 1.2)),
        ],
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }
}
