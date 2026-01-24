import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/monthly_summary.dart';
import '../../models/models.dart';
import 'repository_providers.dart';

class DashboardData {
  final MonthlySummary summary;
  final List<Map<String, dynamic>> categorySpending;
  final List<Budget> budgets;
  final List<SavingGoal> savingGoals;
  final List<Map<String, dynamic>> trendData;
  final List<Map<String, dynamic>> upcomingBills;

  DashboardData({
    required this.summary,
    required this.categorySpending,
    required this.budgets,
    required this.savingGoals,
    required this.trendData,
    required this.upcomingBills,
  });
}

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final repo = ref.watch(financialRepositoryProvider);

  final results = await Future.wait([
    repo.getMonthlySummary(),
    repo.getCategorySpending(),
    repo.getBudgets(),
    repo.getSavingGoals(),
    repo.getSpendingTrend(),
    repo.getUpcomingBills(),
  ]);

  return DashboardData(
    summary: results[0] as MonthlySummary,
    categorySpending: (results[1] as List).cast<Map<String, dynamic>>(),
    budgets: (results[2] as List).cast<Budget>(),
    savingGoals: (results[3] as List).cast<SavingGoal>(),
    trendData: (results[4] as List).cast<Map<String, dynamic>>(),
    upcomingBills: (results[5] as List).cast<Map<String, dynamic>>(),
  );
});
