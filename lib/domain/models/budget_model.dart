class Budget {
  final int id;
  final String category;
  final double monthlyLimit;
  final double spent;
  final DateTime? lastReviewedAt;
  final bool isStable;

  Budget({
    required this.id,
    required this.category,
    required this.monthlyLimit,
    this.spent = 0,
    this.lastReviewedAt,
    this.isStable = false,
  });

  Budget copyWith({
    int? id,
    String? category,
    double? monthlyLimit,
    double? spent,
    DateTime? lastReviewedAt,
    bool? isStable,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      spent: spent ?? this.spent,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      isStable: isStable ?? this.isStable,
    );
  }
}
