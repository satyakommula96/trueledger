import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/components/apple_style.dart';
import 'package:trueledger/presentation/providers/analysis_provider.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/budget_section.dart';
import 'package:trueledger/presentation/screens/budget/add_budget.dart';
import 'package:trueledger/l10n/app_localizations.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisAsync = ref.watch(analysisProvider);
    final semantic = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return analysisAsync.when(
      loading: () => Scaffold(
        backgroundColor: semantic.surfaceCombined,
        body: Center(child: CircularProgressIndicator(color: semantic.primary)),
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

        return AppleScaffold(
          title: l10n.budgets,
          subtitle: "Spending Limits",
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddBudgetScreen()),
              );
              reload();
            },
            backgroundColor: semantic.primary,
            elevation: 4,
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppleSectionHeader(
                      title: l10n.liveTracking,
                      subtitle: "Current Progress",
                    ),
                    const SizedBox(height: 16),
                    BudgetSection(
                      budgets: budgets,
                      semantic: semantic,
                      onLoad: reload,
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.1, end: 0),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
