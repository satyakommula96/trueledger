import 'package:trueledger/core/error/failure.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'usecase_base.dart';

class DashboardData {
  final MonthlySummary summary;
  final List<Map<String, dynamic>> categorySpending;
  final List<Budget> budgets;
  final List<SavingGoal> savingGoals;
  final List<Map<String, dynamic>> trendData;
  final List<Map<String, dynamic>> upcomingBills;
  final List<BillSummary> billsDueToday;
  final int todaySpend;
  final int thisWeekSpend;
  final int lastWeekSpend;
  final int activeStreak;
  final int todayTransactionCount;

  DashboardData({
    required this.summary,
    required this.categorySpending,
    required this.budgets,
    required this.savingGoals,
    required this.trendData,
    required this.upcomingBills,
    required this.billsDueToday,
    required this.todaySpend,
    required this.thisWeekSpend,
    required this.lastWeekSpend,
    required this.activeStreak,
    required this.todayTransactionCount,
  });
}

class GetDashboardDataUseCase extends UseCase<DashboardData, NoParams> {
  final IFinancialRepository repository;

  GetDashboardDataUseCase(this.repository);

  @override
  Future<Result<DashboardData>> call(NoParams params) async {
    try {
      final results = await Future.wait([
        repository.getMonthlySummary(),
        repository.getCategorySpending(),
        repository.getBudgets(),
        repository.getSavingGoals(),
        repository.getSpendingTrend(),
        repository.getUpcomingBills(),
        repository.getTodaySpend(),
        repository.getWeeklySummary(),
        repository.getActiveStreak(),
        repository.getTodayTransactionCount(),
      ]);

      final weeklySummary = results[7] as Map<String, int>;

      final summary = results[0] as MonthlySummary;
      final upcomingBills = (results[5] as List).cast<Map<String, dynamic>>();

      return Success(DashboardData(
        summary: summary,
        categorySpending: (results[1] as List).cast<Map<String, dynamic>>(),
        budgets: (results[2] as List).cast<Budget>(),
        savingGoals: (results[3] as List).cast<SavingGoal>(),
        trendData: (results[4] as List).cast<Map<String, dynamic>>(),
        upcomingBills: upcomingBills,
        billsDueToday:
            BillSummary.filterDueEntries(results[5] as List, DateTime.now()),
        todaySpend: results[6] as int,
        thisWeekSpend: weeklySummary['thisWeek'] ?? 0,
        lastWeekSpend: weeklySummary['lastWeek'] ?? 0,
        activeStreak: results[8] as int,
        todayTransactionCount: results[9] as int,
      ));
    } catch (e) {
      return Failure(
          DatabaseFailure("Failed to load dashboard data: ${e.toString()}"));
    }
  }
}
