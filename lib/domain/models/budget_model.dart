class Budget {
  final int id;
  final String category;
  final double monthlyLimit;
  final double spent; // Not in DB table, calculated field
  final DateTime? lastReviewedAt;
  final bool isStable; // Calculated field based on history

  Budget({
    required this.id,
    required this.category,
    required this.monthlyLimit,
    this.spent = 0,
    this.lastReviewedAt,
    this.isStable = false,
  });

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as int,
      category: map['category'] as String,
      monthlyLimit: (map['monthly_limit'] as num).toDouble(),
      spent: (map['spent'] as num? ?? 0).toDouble(),
      lastReviewedAt: map['last_reviewed_at'] != null
          ? DateTime.tryParse(map['last_reviewed_at'] as String)
          : null,
      isStable: map['is_stable'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'monthly_limit': monthlyLimit,
      'last_reviewed_at': lastReviewedAt?.toIso8601String(),
      // spent is usually excluded from DB writes
    };
  }
}
