import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:trueledger/presentation/providers/day_closure_provider.dart';

class DailyClosureCard extends ConsumerStatefulWidget {
  final int transactionCount;
  final double todaySpend;
  final double dailyBudget;
  final AppColors semantic;
  final bool forceShow;

  const DailyClosureCard({
    super.key,
    required this.transactionCount,
    required this.todaySpend,
    required this.dailyBudget,
    required this.semantic,
    this.forceShow = false,
  });

  @override
  ConsumerState<DailyClosureCard> createState() => _DailyClosureCardState();
}

class _DailyClosureCardState extends ConsumerState<DailyClosureCard> {
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
  Widget build(BuildContext context) {
    final isClosed = ref.watch(dayClosureProvider);
    final now = DateTime.now();
    final isNight = now.hour >= 18 || now.hour < 4; // 6 PM to 4 AM

    if (!isNight && !widget.forceShow) return const SizedBox.shrink();

    if (isClosed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: widget.semantic.surfaceCombined.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: widget.semantic.divider, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: widget.semantic.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.check_circle_rounded,
                  color: widget.semantic.success, size: 16),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                "Ritual complete. Rest well.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: widget.semantic.secondaryText,
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn();
    }

    final isUnderBudget = widget.todaySpend <= widget.dailyBudget;
    final diff = (widget.dailyBudget - widget.todaySpend).abs();

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: widget.semantic.surfaceCombined.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: widget.semantic.divider, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.semantic.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.nightlight_round,
                        size: 12, color: widget.semantic.primary),
                    const SizedBox(width: 8),
                    Text(
                      "DAY RITUAL",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: widget.semantic.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (widget.transactionCount > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Daily Review",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: widget.semantic.text,
                        height: 1.1,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "You've logged ${widget.transactionCount} entries today.",
                      style: TextStyle(
                        fontSize: 15,
                        color: widget.semantic.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.dailyBudget > 0) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: (isUnderBudget
                                  ? widget.semantic.success
                                  : widget.semantic.overspent)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isUnderBudget
                                  ? Icons.check_circle_rounded
                                  : Icons.warning_rounded,
                              size: 16,
                              color: isUnderBudget
                                  ? widget.semantic.success
                                  : widget.semantic.overspent,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              isUnderBudget
                                  ? "${CurrencyFormatter.format(diff)} under target"
                                  : "${CurrencyFormatter.format(diff)} over target",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: isUnderBudget
                                    ? widget.semantic.success
                                    : widget.semantic.overspent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          _confettiController.play();
                          await Future.delayed(500.ms);
                          ref.read(dayClosureProvider.notifier).closeDay();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.semantic.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Finish Daily Review",
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Still Day?",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: widget.semantic.text,
                        height: 1.1,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "No transactions logged today. If you're all set, we'll see you tomorrow.",
                      style: TextStyle(
                        fontSize: 15,
                        color: widget.semantic.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () =>
                            ref.read(dayClosureProvider.notifier).closeDay(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                                color: widget.semantic.divider, width: 1.5),
                          ),
                        ),
                        child: Text(
                          "Close Day",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: widget.semantic.text),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuint),
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
        ),
      ],
    );
  }
}
