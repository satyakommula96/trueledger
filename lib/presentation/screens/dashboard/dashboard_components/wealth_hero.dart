import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:confetti/confetti.dart';

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
  bool _isHovered = false;
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
    final colorScheme = Theme.of(context).colorScheme;
    final appColors = Theme.of(context).extension<AppColors>();
    final isNegative = widget.summary.netWorth < 0;
    final displayColor = isNegative
        ? (appColors?.overspent ?? colorScheme.error)
        : colorScheme.primary;

    final isTouch = Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.android;

    final mainContent = Stack(
      alignment: Alignment.topCenter,
      children: [
        AnimatedContainer(
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
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: widget.onTapNetWorth,
                              child: _buildHeaderPill(context, "NET WORTH",
                                  Icons.account_balance_wallet_rounded),
                            ),
                          ),
                        ),
                        if (widget.activeStreak > 0) ...[
                          const SizedBox(width: 12),
                          Flexible(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Builder(builder: (context) {
                                final pillContent = _buildHeaderPill(
                                  context,
                                  widget.hasLoggedToday
                                      ? "${widget.activeStreak} DAY STREAK"
                                      : "${widget.activeStreak} DAY STREAK",
                                  Icons.whatshot_rounded,
                                  isAlt: true,
                                  color: widget.hasLoggedToday
                                      ? Colors.orange
                                      : Colors.blueGrey.shade300,
                                );

                                Widget pill;
                                if (!widget.hasLoggedToday) {
                                  pill = pillContent;
                                } else {
                                  pill = pillContent.animate();
                                }
                                return pill;
                              }),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                              begin: 0,
                              end: widget.summary.netWorth.toDouble()),
                          duration: 1500.ms,
                          curve: Curves.easeOutExpo,
                          builder: (context, value, child) {
                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                  CurrencyFormatter.format(value.toInt(),
                                      compact: false, isPrivate: isPrivate),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -1.5,
                                      height: 1.0),
                                  maxLines: 1),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ],
                ),
              ),
            ],
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
    );

    if (isTouch) {
      return mainContent.animate();
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: mainContent,
    ).animate();
  }

  Widget _buildHeaderPill(BuildContext context, String text, IconData icon,
      {bool isAlt = false, Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
          color: color != null
              ? color.withValues(alpha: 0.2)
              : (isAlt
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: color != null
                  ? color.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.1))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 14, color: color ?? Colors.white.withValues(alpha: 0.9)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(text,
                style: TextStyle(
                    color: color ?? Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 0),
                overflow: TextOverflow.ellipsis,
                maxLines: 1),
          ),
        ],
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }
}
