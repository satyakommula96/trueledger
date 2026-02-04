import 'package:trueledger/core/error/failure.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'usecase_base.dart';

class CategoryStability {
  final String category;
  final double variance; // % change from previous year
  final int currentYearTotal;
  final int previousYearTotal;

  CategoryStability({
    required this.category,
    required this.variance,
    required this.currentYearTotal,
    required this.previousYearTotal,
  });

  bool get isStable => variance.abs() < 15; // Stable if change is less than 15%
}

class AnnualReflectionData {
  final int year;
  final int totalSpendCurrentYear;
  final int totalSpendPreviousYear;
  final List<CategoryStability> categoryStability;
  final String topCategory;
  final int mostExpensiveMonth; // 1-12
  final int avgMonthlySpend;

  AnnualReflectionData({
    required this.year,
    required this.totalSpendCurrentYear,
    required this.totalSpendPreviousYear,
    required this.categoryStability,
    required this.topCategory,
    required this.mostExpensiveMonth,
    required this.avgMonthlySpend,
  });
}

class GetAnnualReflectionUseCase extends UseCase<AnnualReflectionData, int> {
  final IFinancialRepository repository;

  GetAnnualReflectionUseCase(this.repository);

  @override
  Future<Result<AnnualReflectionData>> call(int year) async {
    try {
      final currentYearStart = DateTime(year, 1, 1);
      final currentYearEnd = DateTime(year, 12, 31, 23, 59, 59);
      final previousYearStart = DateTime(year - 1, 1, 1);
      final previousYearEnd = DateTime(year - 1, 12, 31, 23, 59, 59);

      // 1. Fetch category spending for both years
      final currentYearCats = await repository.getCategorySpendingForRange(
          currentYearStart, currentYearEnd);
      final previousYearCats = await repository.getCategorySpendingForRange(
          previousYearStart, previousYearEnd);

      // 2. Calculate totals
      final totalCurrent = currentYearCats.fold<int>(
          0, (sum, c) => sum + (c['total'] as num? ?? 0).toInt());
      final totalPrevious = previousYearCats.fold<int>(
          0, (sum, c) => sum + (c['total'] as num? ?? 0).toInt());

      // 3. Category stability analysis
      final stabilityMetrics = <CategoryStability>[];
      final allCategories = {
        ...currentYearCats.map((e) => e['category'] as String),
        ...previousYearCats.map((e) => e['category'] as String),
      };

      for (var cat in allCategories) {
        final currentEntry = currentYearCats.firstWhere(
            (e) => e['category'] == cat,
            orElse: () => <String, dynamic>{'total': 0});
        final previousEntry = previousYearCats.firstWhere(
            (e) => e['category'] == cat,
            orElse: () => <String, dynamic>{'total': 0});

        final currentAmount = (currentEntry['total'] as num? ?? 0).toInt();
        final previousAmount = (previousEntry['total'] as num? ?? 0).toInt();

        if (currentAmount == 0 && previousAmount == 0) continue;

        double variance = 0;
        if (previousAmount > 0) {
          variance = ((currentAmount - previousAmount) / previousAmount) * 100;
        } else {
          variance = 100; // New category
        }

        stabilityMetrics.add(CategoryStability(
          category: cat,
          variance: variance,
          currentYearTotal: currentAmount,
          previousYearTotal: previousAmount,
        ));
      }

      // Sort by variance (absolute) to see most changed or most stable
      stabilityMetrics
          .sort((a, b) => a.variance.abs().compareTo(b.variance.abs()));

      // 4. Find most expensive month
      final history = await repository.getMonthlyHistory(year);
      int maxMonth = 1;
      int maxAmount = -1;
      int totalForAvg = 0;
      int monthsWithData = 0;

      for (var entry in history) {
        final total = entry['expenses'] as int? ?? 0;
        final monthStr = entry['month'] as String? ?? '';
        if (monthStr.length < 7) continue;

        final month = int.tryParse(monthStr.split('-')[1]) ?? 1;

        if (total > maxAmount) {
          maxAmount = total;
          maxMonth = month;
        }
        if (total > 0) {
          totalForAvg += total;
          monthsWithData++;
        }
      }

      final topCategory = currentYearCats.isNotEmpty
          ? (currentYearCats.first['category'] as String?) ?? 'None'
          : 'None';

      return Success(AnnualReflectionData(
        year: year,
        totalSpendCurrentYear: totalCurrent,
        totalSpendPreviousYear: totalPrevious,
        categoryStability: stabilityMetrics,
        topCategory: topCategory,
        mostExpensiveMonth: maxMonth,
        avgMonthlySpend:
            monthsWithData > 0 ? (totalForAvg ~/ monthsWithData) : 0,
      ));
    } catch (e) {
      return Failure(
          DatabaseFailure("Failed to generate annual reflection: $e"));
    }
  }
}
