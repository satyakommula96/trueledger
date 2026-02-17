import 'package:trueledger/core/error/failure.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'usecase_base.dart';

class DashboardData {
  final MonthlySummary summary;
  final List<CategorySpending> categorySpending;
  final List<Budget> budgets;
  final List<SavingGoal> savingGoals;
  final List<FinancialTrend> trendData;
  final List<BillSummary> upcomingBills;
  final List<BillSummary> billsDueToday;
  final double todaySpend;
  final double thisWeekSpend;
  final double lastWeekSpend;
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

      final summary = results[0] as MonthlySummary;
      final categorySpending = (results[1] as List).cast<CategorySpending>();
      final budgets = (results[2] as List).cast<Budget>();
      final savingGoals = (results[3] as List).cast<SavingGoal>();
      final trendData = (results[4] as List).cast<FinancialTrend>();
      final upcomingBills = (results[5] as List).cast<BillSummary>();
      final weeklySummary = results[7] as Map<String, double>;

      final now = DateTime.now();
      final billsDueToday = upcomingBills.where((b) {
        if (b.dueDate == null || b.isPaid) return false;
        return b.dueDate!.year == now.year &&
            b.dueDate!.month == now.month &&
            b.dueDate!.day == now.day;
      }).toList();

      return Success(DashboardData(
        summary: summary,
        categorySpending: categorySpending,
        budgets: budgets,
        savingGoals: savingGoals,
        trendData: trendData,
        upcomingBills: upcomingBills,
        billsDueToday: billsDueToday,
        todaySpend: (results[6] as num).toDouble(),
        thisWeekSpend: weeklySummary['thisWeek'] ?? 0.0,
        lastWeekSpend: weeklySummary['lastWeek'] ?? 0.0,
        activeStreak: results[8] as int,
        todayTransactionCount: results[9] as int,
      ));
    } catch (e) {
      return Failure(
          DatabaseFailure("Failed to load dashboard data: ${e.toString()}"));
    }
  }
}
