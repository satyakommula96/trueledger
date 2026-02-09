import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/providers/analysis_provider.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/budget_section.dart';
import 'package:trueledger/presentation/screens/budget/add_budget.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisAsync = ref.watch(analysisProvider);
    final semantic = Theme.of(context).extension<AppColors>()!;

    return analysisAsync.when(
      loading: () => Scaffold(
        backgroundColor: semantic.surfaceCombined,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: semantic.surfaceCombined,
        body: Center(child: Text("Error: $err")),
      ),
      data: (data) {
        final budgets = data.budgets;

        void reload() {
          ref.invalidate(analysisProvider);
        }

        return Scaffold(
          backgroundColor: semantic.surfaceCombined,
          appBar: AppBar(
            title: const Text("BUDGETS"),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddBudgetScreen()),
              );
              reload();
            },
            backgroundColor: semantic.primary,
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "LIVE TRACKING",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: semantic.secondaryText,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Spending Limits",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: semantic.text,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 32),
                BudgetSection(
                  budgets: budgets,
                  semantic: semantic,
                  onLoad: reload,
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
              ],
            ),
          ),
        );
      },
    );
  }
}
