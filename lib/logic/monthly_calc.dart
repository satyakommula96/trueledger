class MonthlySummary {
  final int totalIncome;
  final int totalFixed;
  final int totalVariable;
  final int totalSubscriptions;
  final int totalInvestments;

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

  final int netWorth;
  final int creditCardDebt;
  final int loansTotal;
  final int totalMonthlyEMI;

  int get net =>
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
}
