class Budget {
  final int id;
  final String category;
  final int monthlyLimit;
  final int spent; // Not in DB table, calculated field

  Budget({
    required this.id,
    required this.category,
    required this.monthlyLimit,
    this.spent = 0,
  });

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as int,
      category: map['category'] as String,
      monthlyLimit: map['monthly_limit'] as int,
      spent: map['spent'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'monthly_limit': monthlyLimit,
      // spent is usually excluded from DB writes
    };
  }
}
