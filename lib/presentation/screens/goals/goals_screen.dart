import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:trueledger/presentation/screens/goals/add_goal.dart';
import 'package:trueledger/presentation/screens/goals/edit_goal.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';
import 'package:confetti/confetti.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  List<SavingGoal> goals = [];
  bool _isLoading = true;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _loadGoals();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadGoals() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(financialRepositoryProvider);
      final data = await repo.getSavingGoals();
      if (mounted) {
        setState(() {
          goals = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading goals: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load goals: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final isPrivate = ref.watch(privacyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("SAVING GOALS"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: semantic.primary,
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddGoalScreen()),
          );
          _loadGoals();
        },
        child: const Icon(Icons.add_rounded, size: 32),
      ),
      body: Stack(
        children: [
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(color: semantic.primary))
              : _buildBody(semantic, isPrivate),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [
                semantic.primary,
                semantic.income,
                semantic.warning,
                Colors.blue,
                Colors.pink
              ],
              createParticlePath: _drawStar,
            ),
          ),
        ],
      ),
    );
  }

  Path _drawStar(Size size) {
    double degToRad(double deg) => deg * (3.1415926535897932 / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * math.cos(step),
          halfWidth + externalRadius * math.sin(step));
      path.lineTo(
          halfWidth + internalRadius * math.cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * math.sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  Widget _buildBody(AppColors semantic, bool isPrivate) {
    if (goals.isEmpty) {
      return _buildEmptyState(semantic);
    }

    final totalTarget = goals.fold(0.0, (sum, g) => sum + g.targetAmount);
    final totalSaved = goals.fold(0.0, (sum, g) => sum + g.currentAmount);
    final overallProgress = totalTarget > 0 ? (totalSaved / totalTarget) : 0.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, 100 + MediaQuery.of(context).padding.bottom),
      children: [
        _buildOverallSummaryCard(
            semantic, isPrivate, totalTarget, totalSaved, overallProgress),
        const SizedBox(height: 32),
        Text(
          "YOUR GOALS",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: semantic.secondaryText,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        ...goals.asMap().entries.map((entry) {
          final i = entry.key;
          final goal = entry.value;
          return _buildGoalCard(goal, i, semantic, isPrivate);
        }),
      ],
    );
  }

  Widget _buildEmptyState(AppColors semantic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: semantic.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.flag_rounded,
              size: 64,
              color: semantic.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "NO GOALS YET",
            style: TextStyle(
              color: semantic.text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              "Set your first saving goal and start building your future!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: semantic.secondaryText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      )
          .animate()
          .fadeIn(duration: 600.ms)
          .scale(duration: 600.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildOverallSummaryCard(AppColors semantic, bool isPrivate,
      double totalTarget, double totalSaved, double overallProgress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            semantic.primary.withValues(alpha: 0.15),
            semantic.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: semantic.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: semantic.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.savings_rounded,
                    size: 24, color: semantic.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TOTAL PROGRESS",
                      style: TextStyle(
                        color: semantic.secondaryText,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${(overallProgress * 100).toStringAsFixed(1)}%",
                      style: TextStyle(
                        color: semantic.primary,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildSummaryMetric(
                  "SAVED",
                  CurrencyFormatter.format(totalSaved, isPrivate: isPrivate),
                  semantic.income,
                  semantic,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryMetric(
                  "TARGET",
                  CurrencyFormatter.format(totalTarget, isPrivate: isPrivate),
                  semantic.text,
                  semantic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: semantic.divider.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              AnimatedContainer(
                duration: 1200.ms,
                curve: Curves.easeOutCubic,
                height: 12,
                width: MediaQuery.of(context).size.width *
                    overallProgress.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      semantic.primary,
                      semantic.primary.withValues(alpha: 0.7)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: semantic.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart);
  }

  Widget _buildSummaryMetric(
      String label, String value, Color valueColor, AppColors semantic) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: semantic.surfaceCombined.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: semantic.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: semantic.secondaryText,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: valueColor,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(
      SavingGoal goal, int index, AppColors semantic, bool isPrivate) {
    final progress = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final remaining = goal.targetAmount - goal.currentAmount;
    final isCompleted = progress >= 1.0;

    final progressColor = isCompleted
        ? semantic.income
        : progress > 0.75
            ? semantic.primary
            : progress > 0.5
                ? semantic.warning
                : semantic.secondaryText;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: HoverWrapper(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditGoalScreen(goal: goal.toMap()),
            ),
          );
          final oldProgress = progress;
          await _loadGoals();

          // Check if newly completed
          final updatedGoal = goals.where((g) => g.id == goal.id).firstOrNull;
          if (updatedGoal != null) {
            final newProgress = updatedGoal.targetAmount > 0
                ? (updatedGoal.currentAmount / updatedGoal.targetAmount)
                : 0.0;
            if (oldProgress < 1.0 && newProgress >= 1.0) {
              _confettiController.play();
            }
          }
        },
        borderRadius: 28,
        glowColor: progressColor.withValues(alpha: 0.3),
        glowOpacity: 0.05,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: semantic.surfaceCombined.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isCompleted
                  ? semantic.income.withValues(alpha: 0.3)
                  : semantic.divider,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: progressColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.flag_rounded,
                      size: 20,
                      color: progressColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: semantic.text,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isCompleted
                              ? "GOAL ACHIEVED! 🎉"
                              : "${CurrencyFormatter.format(remaining, isPrivate: isPrivate, compact: true)} TO GO",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: isCompleted
                                ? semantic.income
                                : semantic.secondaryText,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "${(progress * 100).toStringAsFixed(0)}%",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: progressColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Stack(
                children: [
                  Container(
                    height: 10,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: semantic.divider.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  AnimatedContainer(
                    duration: 1200.ms,
                    curve: Curves.easeOutCubic,
                    height: 10,
                    width: (MediaQuery.of(context).size.width - 88) * progress,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          progressColor,
                          progressColor.withValues(alpha: 0.6)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: progressColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SAVED",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: semantic.secondaryText,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(goal.currentAmount,
                            isPrivate: isPrivate, compact: true),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: semantic.income,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "TARGET",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: semantic.secondaryText,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(goal.targetAmount,
                            isPrivate: isPrivate, compact: true),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: semantic.text,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (100 * index).ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart);
  }
}
