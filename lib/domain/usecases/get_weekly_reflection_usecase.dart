import 'package:trueledger/core/error/failure.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'usecase_base.dart';

class WeeklyReflectionData {
  final int daysUnderBudget;
  final double budgetDailyAverage;
  final Map<String, dynamic>?
      largestCategoryIncrease; // {category, increaseAmount, isNew}
  final double totalThisWeek;
  final double totalLastWeek;
  final String? topCategory;

  WeeklyReflectionData({
    required this.daysUnderBudget,
    required this.budgetDailyAverage,
    this.largestCategoryIncrease,
    required this.totalThisWeek,
    required this.totalLastWeek,
    this.topCategory,
  });
}

class GetWeeklyReflectionUseCase
    extends UseCase<WeeklyReflectionData, NoParams> {
  final IFinancialRepository repository;

  GetWeeklyReflectionUseCase(this.repository);

  @override
  Future<Result<WeeklyReflectionData>> call(NoParams params) async {
    try {
      final now = DateTime.now();

      // Calculate date ranges
      final thisMondayOffset = now.weekday - 1;
      final thisWeekStart =
          DateTime(now.year, now.month, now.day - thisMondayOffset);
      final thisWeekEnd = now;

      final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
      final lastWeekEnd = thisWeekStart.subtract(const Duration(days: 1));

      // 1. Calculate Daily Spending for this week to find "Days Under Budget"
      // We need daily breakdown. The repo has helper for monthly history but not daily for range.
      // We can fetch all transactions for this week and process in memory (efficient enough for local db).
      final thisWeekTransactions =
          await repository.getTransactionsForRange(thisWeekStart, thisWeekEnd);

      // Group by day (YYYY-MM-DD)
      final dailySpend = <String, double>{};
      for (var tx in thisWeekTransactions) {
        if (tx.type != 'Variable') {
          continue; // Only count variable spend against budget
        }
        final day = tx.date.substring(0, 10);
        dailySpend[day] = (dailySpend[day] ?? 0.0) + tx.amount;
      }

      // Calculate "Daily Budget" from budgets
      // We assume Monthly / 30 for simplicity or sum of all budget limits
      final budgets = await repository.getBudgets();
      final totalMonthlyBudget =
          budgets.fold(0.0, (sum, b) => sum + b.monthlyLimit);
      final double dailyBudgetLimit = totalMonthlyBudget > 0
          ? (totalMonthlyBudget / 30)
          : 500.0; // Fallback or strict 0? Let's use a sane default or 0 makes it hard to be "under".
      // If user hasn't set budget, this metric is meaningless.
      // Let's assume a default "spend" if 0? Or maybe skip.
      // Requirement: "This week you stayed under budget 4 days."

      double limitToCheck = dailyBudgetLimit > 0
          ? dailyBudgetLimit
          : 2000.0; // Default 2k/day if no budget set?

      // Count days under budget
      // We check each day from Monday to Today
      int daysUnder = 0;
      DateTime checkDate = thisWeekStart;
      while (checkDate.isBefore(now) || checkDate.isAtSameMomentAs(now)) {
        // Stop if future (though isBefore(now) handles it mostly, need to be careful with time components)
        if (checkDate.difference(now).inDays > 0) break;

        final dayStr = checkDate.toIso8601String().substring(0, 10);
        final spend = dailySpend[dayStr] ?? 0;

        if (spend <= limitToCheck) {
          daysUnder++;
        }
        checkDate = checkDate.add(const Duration(days: 1));
      }

      // 2. Category Analysis
      final thisWeekCats = await repository.getCategorySpendingForRange(
          thisWeekStart, thisWeekEnd);
      final lastWeekCats = await repository.getCategorySpendingForRange(
          lastWeekStart, lastWeekEnd);

      // Find largest increase
      Map<String, dynamic>? significantIncrease;

      for (var cat in thisWeekCats) {
        final name = cat['category'];
        final currentAmount = (cat['total'] as num).toDouble();

        // Find in last week
        final lastWeekEntry = lastWeekCats.firstWhere(
            (e) => e['category'] == name,
            orElse: () => <String, Object>{'total': 0});
        final lastAmount = (lastWeekEntry['total'] as num).toDouble();

        if (currentAmount > lastAmount) {
          final diff = currentAmount - lastAmount;
          if (significantIncrease == null ||
              diff > significantIncrease['increaseAmount']) {
            significantIncrease = {
              'category': name,
              'increaseAmount': diff,
              'isNew': lastAmount == 0,
            };
          }
        }
      }

      // 3. Totals and Top Category
      final totalThisWeek = thisWeekCats.fold(
          0.0, (sum, c) => sum + (c['total'] as num).toDouble());
      final totalLastWeek = lastWeekCats.fold(
          0.0, (sum, c) => sum + (c['total'] as num).toDouble());
      final topCategory = thisWeekCats.isNotEmpty
          ? thisWeekCats.first['category'] as String
          : null;

      return Success(WeeklyReflectionData(
        daysUnderBudget: daysUnder,
        budgetDailyAverage: limitToCheck,
        largestCategoryIncrease: significantIncrease,
        totalThisWeek: totalThisWeek,
        totalLastWeek: totalLastWeek,
        topCategory: topCategory,
      ));
    } catch (e) {
      return Failure(
          DatabaseFailure("Failed to calculate weekly reflection: $e"));
    }
  }
}
