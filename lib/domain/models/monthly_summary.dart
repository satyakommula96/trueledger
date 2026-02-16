class MonthlySummary {
  final double totalIncome;
  final double totalFixed;
  final double totalVariable;
  final double totalSubscriptions;
  final double totalInvestments;
  final double netWorth;
  final double creditCardDebt;
  final double loansTotal;
  final double totalMonthlyEMI;

  MonthlySummary({
    required this.totalIncome,
    required this.totalFixed,
    required this.totalVariable,
    required this.totalSubscriptions,
    required this.totalInvestments,
    this.netWorth = 0,
    this.creditCardDebt = 0,
    this.loansTotal = 0,
    this.totalMonthlyEMI = 0,
  });

  double get net =>
      totalIncome -
      totalFixed -
      totalVariable -
      totalSubscriptions -
      totalInvestments;

  double get savingsRate => totalIncome == 0
      ? 0
      : ((totalIncome - (totalFixed + totalVariable + totalSubscriptions)) /
              totalIncome) *
          100;

  String get status {
    if (net > 25000) return "PROSPEROUS";
    if (net > 10000) return "STABLE";
    if (net > 0) return "TIGHT";
    return "OVERSPENT";
  }

  MonthlySummary copyWith({
    double? totalIncome,
    double? totalFixed,
    double? totalVariable,
    double? totalSubscriptions,
    double? totalInvestments,
    double? netWorth,
    double? creditCardDebt,
    double? loansTotal,
    double? totalMonthlyEMI,
  }) {
    return MonthlySummary(
      totalIncome: totalIncome ?? this.totalIncome,
      totalFixed: totalFixed ?? this.totalFixed,
      totalVariable: totalVariable ?? this.totalVariable,
      totalSubscriptions: totalSubscriptions ?? this.totalSubscriptions,
      totalInvestments: totalInvestments ?? this.totalInvestments,
      netWorth: netWorth ?? this.netWorth,
      creditCardDebt: creditCardDebt ?? this.creditCardDebt,
      loansTotal: loansTotal ?? this.loansTotal,
      totalMonthlyEMI: totalMonthlyEMI ?? this.totalMonthlyEMI,
    );
  }
}
