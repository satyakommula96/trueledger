class YearMonth {
  final int year;
  final int month;

  const YearMonth(this.year, this.month) : assert(month >= 1 && month <= 12);

  factory YearMonth.fromDate(DateTime date) {
    return YearMonth(date.year, date.month);
  }

  YearMonth next() {
    if (month == 12) {
      return YearMonth(year + 1, 1);
    }
    return YearMonth(year, month + 1);
  }

  YearMonth addMonths(int count) {
    var ym = this;
    for (var i = 0; i < count; i++) {
      ym = ym.next();
    }
    return ym;
  }

  DateTime toDateTime() => DateTime(year, month, 1);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YearMonth && year == other.year && month == other.month;

  @override
  int get hashCode => year.hashCode ^ month.hashCode;

  @override
  String toString() => '$year-${month.toString().padLeft(2, '0')}';
}

class MonthlyCashFlow {
  final YearMonth month;
  final int income; // in cents/paise
  final int expenses; // in cents/paise

  const MonthlyCashFlow({
    required this.month,
    required this.income,
    required this.expenses,
  });

  int get net => income - expenses;
}

class CashFlowHistory {
  final List<MonthlyCashFlow> monthlyData;

  const CashFlowHistory(this.monthlyData);

  bool get isEmpty => monthlyData.isEmpty;
  int get length => monthlyData.length;
}

enum ForecastConfidence {
  low,
  medium,
  high,
}

class ForecastPoint {
  final YearMonth month;
  final int projectedIncome;
  final int projectedExpenses;

  const ForecastPoint({
    required this.month,
    required this.projectedIncome,
    required this.projectedExpenses,
  });

  int get projectedNet => projectedIncome - projectedExpenses;
}

class ForecastResult {
  final List<ForecastPoint> projections;
  final ForecastConfidence confidence;
  final double variance; // Mathematical volatility

  const ForecastResult({
    required this.projections,
    required this.confidence,
    this.variance = 0.0,
  });
}

class ForecastHorizon {
  final int months;

  const ForecastHorizon(this.months);
}

class ForecastScenario {
  final int incomeAdjustment;
  final int expenseAdjustment;

  const ForecastScenario({
    this.incomeAdjustment = 0,
    this.expenseAdjustment = 0,
  });
}
