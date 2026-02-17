import 'package:trueledger/domain/forecasting/forecasting.dart';

class LinearRegressionForecastEngine implements ForecastingEngine {
  @override
  ForecastResult forecastCashFlow({
    required CashFlowHistory history,
    required ForecastHorizon horizon,
    required DateTime referenceDate,
    ForecastScenario? scenario,
  }) {
    if (history.isEmpty) {
      return const ForecastResult(
        projections: [],
        confidence: ForecastConfidence.low,
      );
    }

    final n = history.length;
    final incomeTrend = _calculateTrend(
        history.monthlyData.map((e) => e.income.toDouble()).toList());
    final expenseTrend = _calculateTrend(
        history.monthlyData.map((e) => e.expenses.toDouble()).toList());

    // Calculate total variance (MSE) for both trends to reflect volatility
    final totalVariance = incomeTrend.mse + expenseTrend.mse;

    final projections = <ForecastPoint>[];
    // Start from reference date's month or the last month in history
    var currentMonth = YearMonth.fromDate(referenceDate);

    for (var i = 1; i <= horizon.months; i++) {
      currentMonth = currentMonth.next();

      // Calculate basic projection using linear regression
      double projectedIncomeValue = incomeTrend.predict(n + i - 1);
      double projectedExpensesValue = expenseTrend.predict(n + i - 1);

      // Apply scenario adjustments
      if (scenario != null) {
        projectedIncomeValue += scenario.incomeAdjustment;
        projectedExpensesValue += scenario.expenseAdjustment;
      }

      // Ensure no negative values for income/expenses in forecast
      final int finalIncome =
          projectedIncomeValue < 0 ? 0 : projectedIncomeValue.round();
      final int finalExpenses =
          projectedExpensesValue < 0 ? 0 : projectedExpensesValue.round();

      projections.add(ForecastPoint(
        month: currentMonth,
        projectedIncome: finalIncome,
        projectedExpenses: finalExpenses,
      ));
    }

    return ForecastResult(
      projections: projections,
      confidence: _calculateConfidence(n, totalVariance),
      variance: totalVariance,
    );
  }

  _Trend _calculateTrend(List<double> values) {
    final n = values.length;
    if (n < 2) {
      return _Trend(0, values.isNotEmpty ? values.last : 0, 0);
    }

    double sumX = 0;
    double sumY = 0;
    double sumXY = 0;
    double sumX2 = 0;

    for (var i = 0; i < n; i++) {
      sumX += i;
      sumY += values[i];
      sumXY += i * values[i];
      sumX2 += i * i;
    }

    final denominator = (n * sumX2) - (sumX * sumX);
    if (denominator == 0) {
      return _Trend(0, values.last, 0);
    }

    final m = (n * sumXY - sumX * sumY) / denominator;
    final b = (sumY - m * sumX) / n;

    // Calculate Mean Squared Error (MSE) as a measure of variance/volatility
    double sumErrorSquared = 0;
    for (var i = 0; i < n; i++) {
      final prediction = m * i + b;
      final error = values[i] - prediction;
      sumErrorSquared += error * error;
    }
    final mse = sumErrorSquared / n;

    return _Trend(m, b, mse);
  }

  ForecastConfidence _calculateConfidence(
      int historyLength, double totalVariance) {
    if (historyLength < 3) return ForecastConfidence.low;

    // High variance indicator
    if (totalVariance > 50000000) return ForecastConfidence.low;

    if (historyLength < 6 || totalVariance > 5000000) {
      return ForecastConfidence.medium;
    }

    return ForecastConfidence.high;
  }
}

class _Trend {
  final double m;
  final double b;
  final double mse; // Mean Squared Error

  _Trend(this.m, this.b, this.mse);

  double predict(int x) => m * x + b;
}
