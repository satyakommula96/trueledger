import 'package:truecash/core/error/failure.dart';
import 'package:truecash/core/utils/result.dart';
import 'package:truecash/domain/models/models.dart';
import 'package:truecash/domain/repositories/i_financial_repository.dart';
import 'usecase_base.dart';

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
      ]);

      return Success(DashboardData(
        summary: results[0] as MonthlySummary,
        categorySpending: (results[1] as List).cast<Map<String, dynamic>>(),
        budgets: (results[2] as List).cast<Budget>(),
        savingGoals: (results[3] as List).cast<SavingGoal>(),
        trendData: (results[4] as List).cast<Map<String, dynamic>>(),
        upcomingBills: (results[5] as List).cast<Map<String, dynamic>>(),
      ));
    } catch (e) {
      return Failure(
          DatabaseFailure("Failed to load dashboard data: ${e.toString()}"));
    }
  }
}
