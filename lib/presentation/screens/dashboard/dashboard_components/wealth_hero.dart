import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:trueledger/presentation/components/apple_style.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/config/app_config.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:confetti/confetti.dart';
import 'package:trueledger/presentation/providers/runway_provider.dart';

import 'package:trueledger/l10n/app_localizations.dart';

class WealthHero extends ConsumerStatefulWidget {
  final MonthlySummary summary;
  final int activeStreak;
  final bool hasLoggedToday;
  final VoidCallback? onTapNetWorth;
  final VoidCallback? onTapStreak;

  const WealthHero({
    super.key,
    required this.summary,
    required this.activeStreak,
    required this.hasLoggedToday,
    this.onTapNetWorth,
    this.onTapStreak,
  });

  @override
  ConsumerState<WealthHero> createState() => _WealthHeroState();
}

class _WealthHeroState extends ConsumerState<WealthHero> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(WealthHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeStreak > oldWidget.activeStreak &&
        widget.activeStreak > 0) {
      _confettiController.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPrivate = ref.watch(privacyProvider);
    final semantic = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final isNegative = widget.summary.netWorth < 0;

    // Apple Card Inspired Mesh Gradient
    final displayColor = isNegative ? semantic.overspent : semantic.primary;

    return AppleGlassCard(
      padding: EdgeInsets.zero,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          displayColor,
          displayColor.withValues(alpha: 0.8),
        ],
      ),
      child: Stack(
        children: [
          // Top Right Mesh Sphere
          Positioned(
            right: -60,
            top: -60,
            child: ExcludeSemantics(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.15),
                      Colors.white.withValues(alpha: 0),
                    ],
                  ),
                ),
              )
                  .animate(
                      onPlay: (c) => !AppConfig.isTest
                          ? c.repeat(reverse: true)
                          : c.forward())
                  .move(
                      duration: 8.seconds,
                      begin: const Offset(0, 0),
                      end: const Offset(-30, 30))
                  .scale(
                      duration: 8.seconds,
                      begin: const Offset(1, 1),
                      end: const Offset(1.1, 1.1)),
            ),
          ),
          // Bottom Left Mesh Sphere
          Positioned(
            left: -80,
            bottom: -80,
            child: ExcludeSemantics(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0),
                    ],
                  ),
                ),
              )
                  .animate(
                      onPlay: (c) => !AppConfig.isTest
                          ? c.repeat(reverse: true)
                          : c.forward())
                  .move(
                      duration: 10.seconds,
                      begin: const Offset(0, 0),
                      end: const Offset(40, -20))
                  .scale(
                      duration: 10.seconds,
                      begin: const Offset(1, 1),
                      end: const Offset(0.9, 0.9)),
            ),
          ),
          Positioned(
            top: -100,
            left: -100,
            child: ExcludeSemantics(
              child: Transform.rotate(
                angle: 45 * 3.1415927 / 180,
                child: Container(
                  width: 300,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0),
                        Colors.white.withValues(alpha: 0.05),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTapNetWorth,
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.currentBalance.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0,
                        end: widget.summary.netWorth.toDouble(),
                      ),
                      duration: 1500.ms,
                      curve: Curves.easeOutQuart,
                      builder: (context, value, child) {
                        final text = CurrencyFormatter.format(
                          value,
                          compact: false,
                          isPrivate: isPrivate,
                        );
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 52,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.5,
                              height: 1.0,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    // Dynamic Runway Insight
                    Consumer(
                      builder: (context, ref, child) {
                        final runwayAsync = ref.watch(runwayProvider);
                        return runwayAsync.when(
                          data: (result) {
                            final text = result.isSustainable
                                ? l10n.sustainableRunway
                                : (result.monthsUntilDepletion == 0
                                    ? l10n.deficitRunway
                                    : l10n.runwayMonths(
                                        result.monthsUntilDepletion ?? 0));
                            return Row(
                              children: [
                                Icon(
                                  result.isSustainable
                                      ? CupertinoIcons.sparkles
                                      : CupertinoIcons.info_circle,
                                  color: Colors.white.withValues(alpha: 0.5),
                                  size: 14,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  text.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            );
                          },
                          loading: () => const SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white24),
                          ),
                          error: (_, __) => const SizedBox.shrink(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ],
            gravity: 0.1,
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.5;

    const step = 20.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
