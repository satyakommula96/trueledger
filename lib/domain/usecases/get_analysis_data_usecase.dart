import 'package:truecash/core/error/failure.dart';
import 'package:truecash/core/utils/result.dart';
import 'package:truecash/domain/models/models.dart';
import 'package:truecash/domain/repositories/i_financial_repository.dart';
import 'usecase_base.dart';

class AnalysisData {
  final List<Budget> budgets;
  final List<Map<String, dynamic>> trendData;
  final List<Map<String, dynamic>> categoryData;

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
        trendData: (results[1] as List).cast<Map<String, dynamic>>(),
        categoryData: (results[2] as List).cast<Map<String, dynamic>>(),
      ));
    } catch (e) {
      return Failure(
          DatabaseFailure("Failed to load analysis data: ${e.toString()}"));
    }
  }
}
