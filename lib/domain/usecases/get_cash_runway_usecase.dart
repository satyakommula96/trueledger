import 'package:trueledger/core/error/failure.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/domain/forecasting/forecasting.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'usecase_base.dart';

class GetCashRunwayUseCase extends UseCase<CashRunwayResult, NoParams> {
  final IFinancialRepository repository;
  final ForecastingEngine forecastingEngine;
  final CashRunwayEngine runwayEngine;

  GetCashRunwayUseCase(
    this.repository,
    this.forecastingEngine,
    this.runwayEngine,
  );

  @override
  Future<Result<CashRunwayResult>> call(NoParams params) async {
    try {
      final summary = await repository.getMonthlySummary();
      final trendData = await repository.getMonthlyHistory();

      if (trendData.isEmpty) {
        return Success(CashRunwayResult(
          isSustainable: true,
          monthsUntilDepletion: null,
          depletionDate: null,
          endingBalanceAfterProjection: Money.fromDouble(summary.netWorth),
        ));
      }

      final monthlyCashFlows = trendData.map((d) {
        return MonthlyCashFlow(
          month: _parseYearMonth(d.month),
          income: (d.income * 100).round(),
          expenses: (d.spending * 100).round(),
        );
      }).toList();

      final history = CashFlowHistory(monthlyCashFlows);

      // Generate Forecast (36 months ahead for a long runway check)
      final forecast = forecastingEngine.forecastCashFlow(
        history: history,
        horizon: const ForecastHorizon(36),
        referenceDate: DateTime.now(),
      );

      // Calculate Runway
      final result = runwayEngine.calculate(
        currentBalance: Money.fromDouble(summary.netWorth),
        projections: forecast.projections,
        referenceDate: DateTime.now(),
      );

      return Success(result);
    } catch (e) {
      return Failure(DatabaseFailure("Failed to calculate cash runway: $e"));
    }
  }

  YearMonth _parseYearMonth(String monthStr) {
    try {
      // Expected format: "Jan 2024" or "2024-01"
      if (monthStr.contains('-')) {
        final parts = monthStr.split('-');
        return YearMonth(int.parse(parts[0]), int.parse(parts[1]));
      }

      final parts = monthStr.split(' ');
      if (parts.length == 2) {
        final year = int.tryParse(parts[1]) ?? DateTime.now().year;
        final month = _monthToIndex(parts[0]);
        return YearMonth(year, month);
      }
    } catch (_) {}
    return YearMonth.fromDate(DateTime.now());
  }

  int _monthToIndex(String month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final index = months.indexOf(month);
    return index != -1 ? index + 1 : 1;
  }
}
