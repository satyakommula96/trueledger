class FinancialTrend {
  final String month;
  final double spending;
  final double income;
  final double total;
  final double invested;

  FinancialTrend({
    required this.month,
    required this.spending,
    required this.income,
    required this.total,
    this.invested = 0,
  });

  double get net => income - spending - invested;
}

class CategorySpending {
  final String category;
  final double total;

  CategorySpending({
    required this.category,
    required this.total,
  });
}
