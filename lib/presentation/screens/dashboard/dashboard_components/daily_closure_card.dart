import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:trueledger/presentation/providers/day_closure_provider.dart';

class DailyClosureCard extends ConsumerStatefulWidget {
  final int transactionCount;
  final int todaySpend;
  final int dailyBudget;
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

    // If day is already closed ritualistically, show a smaller "Success" state or shrink
    if (isClosed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: widget.semantic.surfaceCombined.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
          border:
              Border.all(color: widget.semantic.divider.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: widget.semantic.success, size: 20),
            const SizedBox(width: 12),
            Text(
              "Day ritual complete. See you tomorrow!",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: widget.semantic.secondaryText,
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
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: widget.semantic.surfaceCombined,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: widget.semantic.divider),
            boxShadow: [
              BoxShadow(
                color: widget.semantic.success.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (widget.transactionCount > 0
                                  ? widget.semantic.success
                                  : widget.semantic.warning)
                              .withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.nightlight_round,
                          size: 16,
                          color: widget.transactionCount > 0
                              ? widget.semantic.success
                              : widget.semantic.warning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "DAY CLOSURE",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: widget.semantic.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (widget.transactionCount > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Review your day",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: widget.semantic.text,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "You logged ${widget.transactionCount} expenses today.",
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.semantic.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (widget.dailyBudget > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: (isUnderBudget
                                  ? widget.semantic.success
                                  : widget.semantic.overspent)
                              .withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isUnderBudget
                                  ? Icons.check_circle_outline
                                  : Icons.warning_amber_rounded,
                              size: 14,
                              color: isUnderBudget
                                  ? widget.semantic.success
                                  : widget.semantic.overspent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isUnderBudget
                                  ? "${CurrencyFormatter.format(diff)} under daily budget"
                                  : "${CurrencyFormatter.format(diff)} over daily budget",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isUnderBudget
                                    ? widget.semantic.success
                                    : widget.semantic.overspent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          _confettiController.play();
                          await Future.delayed(500.ms);
                          ref.read(dayClosureProvider.notifier).closeDay();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.semantic.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Mark day as complete",
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 14),
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
                      "No expenses today?",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: widget.semantic.text,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Did you forget to log something? If not, you've mastered your spend today!",
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.semantic.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          ref.read(dayClosureProvider.notifier).closeDay();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: widget.semantic.divider),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          "Confident. Close day.",
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: widget.semantic.text),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(
              begin: 0.1,
              end: 0,
              curve: Curves.easeOutQuint,
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
        ),
      ],
    );
  }
}
