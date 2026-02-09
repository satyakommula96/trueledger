import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:confetti/confetti.dart';
import 'package:trueledger/core/config/app_config.dart';

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
    final semantic = Theme.of(context).extension<AppColors>()!;
    final isNegative = widget.summary.netWorth < 0;

    // Premium Mesh Gradient logic
    final displayColor = isNegative ? semantic.overspent : semantic.primary;

    final isTouch = Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.android;

    final mainContent = Stack(
      alignment: Alignment.topCenter,
      children: [
        AnimatedContainer(
          duration: 400.ms,
          curve: Curves.easeOutQuart,
          // ignore: deprecated_member_use
          transform: Matrix4.identity()
            // ignore: deprecated_member_use
            ..scale(_isHovered ? 1.015 : 1.0)
            // ignore: deprecated_member_use
            ..translate(0.0, _isHovered ? -2.0 : 0.0),
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                displayColor.withValues(alpha: 0.9),
                displayColor.withValues(alpha: 0.7),
                displayColor.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: displayColor.withValues(alpha: _isHovered ? 0.25 : 0.15),
                blurRadius: _isHovered ? 40 : 20,
                offset: Offset(0, _isHovered ? 15 : 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                // Organic background shapes for mesh effect
                Positioned(
                  right: -80,
                  top: -80,
                  child: Container(
                    width: 280,
                    height: 280,
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
                      .animate(onPlay: (controller) {
                        if (!AppConfig.isTest) {
                          controller.repeat(reverse: true);
                        }
                      })
                      .move(
                          duration: 4.seconds,
                          begin: const Offset(0, 0),
                          end: const Offset(-20, 20))
                      .scale(
                          duration: 4.seconds,
                          begin: const Offset(1, 1),
                          end: const Offset(1.1, 1.1)),
                ),
                Positioned(
                  left: -50,
                  bottom: -50,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.08),
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  )
                      .animate(onPlay: (controller) {
                        if (!AppConfig.isTest) {
                          controller.repeat(reverse: true);
                        }
                      })
                      .move(
                          duration: 5.seconds,
                          begin: const Offset(0, 0),
                          end: const Offset(30, -10))
                      .scale(
                          duration: 5.seconds,
                          begin: const Offset(1.1, 1.1),
                          end: const Offset(0.9, 0.9)),
                ),
                // Gloss / Shine Effect Overlay
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.1),
                            Colors.white.withValues(alpha: 0),
                            Colors.white.withValues(alpha: 0.05),
                            Colors.white.withValues(alpha: 0),
                          ],
                          stops: const [0.1, 0.4, 0.5, 0.8],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: _buildHeaderPill(
                              context,
                              "NET WORTH",
                              Icons.account_balance_wallet_rounded,
                              onTap: widget.onTapNetWorth,
                              semantic: semantic,
                            ),
                          ),
                          Flexible(
                            child: _buildHeaderPill(
                              context,
                              "${widget.activeStreak} DAY STREAK",
                              Icons.whatshot_rounded,
                              onTap: widget.onTapStreak,
                              isAlt: true,
                              semantic: semantic,
                              color: widget.hasLoggedToday
                                  ? Colors.orange
                                  : Colors.white.withValues(alpha: 0.5),
                              showPulse: !widget.hasLoggedToday,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        "CURRENT BALANCE",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 0,
                          end: widget.summary.netWorth.toDouble(),
                        ),
                        duration: 2.seconds,
                        curve: Curves.easeOutExpo,
                        builder: (context, value, child) {
                          final text = CurrencyFormatter.format(
                            value,
                            compact: false,
                            isPrivate: isPrivate,
                          );
                          return FittedBox(
                            fit: BoxFit.scaleDown,
                            child: ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Colors.white, Colors.white70],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ).createShader(bounds),
                              child: Text(
                                text,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 52,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -2,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
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
    );

    if (isTouch) return mainContent.animate().fadeIn(duration: 600.ms);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: mainContent.animate().fadeIn(duration: 600.ms),
    );
  }

  Widget _buildHeaderPill(
    BuildContext context,
    String text,
    IconData icon, {
    VoidCallback? onTap,
    bool isAlt = false,
    Color? color,
    required AppColors semantic,
    bool showPulse = false,
  }) {
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color != null
            ? color.withValues(alpha: 0.15)
            : Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color?.withValues(alpha: 0.3) ??
              Colors.white.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color ?? Colors.white.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color ?? Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: showPulse
          ? pill.animate(onPlay: (controller) {
              if (!AppConfig.isTest) controller.repeat(reverse: true);
            }).scale(
              duration: 800.ms,
              begin: const Offset(1, 1),
              end: const Offset(1.05, 1.05))
          : pill.animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
    );
  }
}
