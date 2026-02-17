import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/domain/forecasting/forecasting_models.dart';
import 'package:trueledger/domain/forecasting/linear_regression_forecast_engine.dart';

void main() {
  group('LinearRegressionForecastEngine', () {
    late LinearRegressionForecastEngine engine;
    final referenceDate = DateTime(2025, 3, 15);

    setUp(() {
      engine = LinearRegressionForecastEngine();
    });

    test('forecasts stability with constant data', () {
      final history = CashFlowHistory([
        const MonthlyCashFlow(
            month: YearMonth(2025, 1), income: 50000, expenses: 30000),
        const MonthlyCashFlow(
            month: YearMonth(2025, 2), income: 50000, expenses: 30000),
        const MonthlyCashFlow(
            month: YearMonth(2025, 3), income: 50000, expenses: 30000),
      ]);

      final result = engine.forecastCashFlow(
        history: history,
        horizon: const ForecastHorizon(3),
        referenceDate: referenceDate,
      );

      expect(result.projections.length, 3);
      expect(result.projections[0].projectedIncome, 50000);
      expect(result.projections[0].projectedExpenses, 30000);
      // referenceDate is March, so next is April
      expect(result.projections[0].month, const YearMonth(2025, 4));

      expect(result.projections[2].projectedIncome, 50000);
      expect(result.projections[2].projectedExpenses, 30000);
      expect(result.projections[2].month, const YearMonth(2025, 6));

      expect(result.confidence, ForecastConfidence.medium);
    });

    test('forecasts growth with linear trend', () {
      final history = CashFlowHistory([
        const MonthlyCashFlow(
            month: YearMonth(2025, 1), income: 1000, expenses: 500),
        const MonthlyCashFlow(
            month: YearMonth(2025, 2), income: 2000, expenses: 1000),
        const MonthlyCashFlow(
            month: YearMonth(2025, 3), income: 3000, expenses: 1500),
      ]);

      final result = engine.forecastCashFlow(
        history: history,
        horizon: const ForecastHorizon(1),
        referenceDate: referenceDate,
      );

      expect(result.projections[0].projectedIncome, 4000);
      expect(result.projections[0].projectedExpenses, 2000);
    });

    test('applies scenario adjustments correctly', () {
      final history = CashFlowHistory([
        const MonthlyCashFlow(
            month: YearMonth(2025, 1), income: 1000, expenses: 1000),
      ]);

      final scenario = const ForecastScenario(
        incomeAdjustment: 500,
        expenseAdjustment: -200,
      );

      final result = engine.forecastCashFlow(
        history: history,
        horizon: const ForecastHorizon(1),
        referenceDate: referenceDate,
        scenario: scenario,
      );

      expect(result.projections[0].projectedIncome, 1500);
      expect(result.projections[0].projectedExpenses, 800);
    });

    test('drops confidence when data is volatile', () {
      // Linear regression on this will have high variance/MSE
      final history = CashFlowHistory([
        const MonthlyCashFlow(
            month: YearMonth(2025, 1), income: 1000, expenses: 500),
        const MonthlyCashFlow(
            month: YearMonth(2025, 2), income: 9000, expenses: 1000),
        const MonthlyCashFlow(
            month: YearMonth(2025, 3), income: 2000, expenses: 1500),
        const MonthlyCashFlow(
            month: YearMonth(2025, 4), income: 8000, expenses: 500),
        const MonthlyCashFlow(
            month: YearMonth(2025, 5), income: 1000, expenses: 2000),
        const MonthlyCashFlow(
            month: YearMonth(2025, 6), income: 9000, expenses: 1000),
      ]);

      final result = engine.forecastCashFlow(
        history: history,
        horizon: const ForecastHorizon(1),
        referenceDate: DateTime(2025, 6, 15),
      );

      // Even with 6 months of data, high volatility should drop confidence to low/medium
      expect(result.confidence, isNot(ForecastConfidence.high));
    });

    test('returns empty projections for empty history', () {
      final result = engine.forecastCashFlow(
        history: const CashFlowHistory([]),
        horizon: const ForecastHorizon(12),
        referenceDate: referenceDate,
      );

      expect(result.projections, isEmpty);
      expect(result.confidence, ForecastConfidence.low);
    });
  });
}
