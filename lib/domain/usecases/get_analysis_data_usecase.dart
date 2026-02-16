import 'package:trueledger/core/error/failure.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'usecase_base.dart';

class AnalysisData {
  final List<Budget> budgets;
  final List<FinancialTrend> trendData;
  final List<CategorySpending> categoryData;

  AnalysisData({
    required this.budgets,
    required this.trendData,
    required this.categoryData,
  });
}

class GetAnalysisDataUseCase extends UseCase<AnalysisData, NoParams> {
  final IFinancialRepository repository;

  GetAnalysisDataUseCase(this.repository);

  @override
  Future<Result<AnalysisData>> call(NoParams params) async {
    try {
      final results = await Future.wait([
        repository.getBudgets(),
        repository.getSpendingTrend(),
        repository.getCategorySpending(),
      ]);

      return Success(AnalysisData(
        budgets: (results[0] as List).cast<Budget>(),
        trendData: (results[1] as List).cast<FinancialTrend>(),
        categoryData: (results[2] as List).cast<CategorySpending>(),
      ));
    } catch (e) {
      return Failure(
          DatabaseFailure("Failed to load analysis data: ${e.toString()}"));
    }
  }
}
