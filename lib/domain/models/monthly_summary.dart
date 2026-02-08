class MonthlySummary {
  final double totalIncome;
  final double totalFixed;
  final double totalVariable;
  final double totalSubscriptions;
  final double totalInvestments;

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

  final double netWorth;
  final double creditCardDebt;
  final double loansTotal;
  final double totalMonthlyEMI;

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
}
