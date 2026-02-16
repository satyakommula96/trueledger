class RecurringTransaction {
  final int id;
  final String name;
  final double amount;
  final String category;
  final String type; // INCOME or EXPENSE
  final String frequency; // DAILY, WEEKLY, MONTHLY, YEARLY
  final int? dayOfMonth;
  final int? dayOfWeek;
  final DateTime? lastProcessed;
  final bool isActive;

  RecurringTransaction({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.type,
    required this.frequency,
    this.dayOfMonth,
    this.dayOfWeek,
    this.lastProcessed,
    this.isActive = true,
  });

  RecurringTransaction copyWith({
    int? id,
    String? name,
    double? amount,
    String? category,
    String? type,
    String? frequency,
    int? dayOfMonth,
    int? dayOfWeek,
    DateTime? lastProcessed,
    bool? isActive,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      lastProcessed: lastProcessed ?? this.lastProcessed,
      isActive: isActive ?? this.isActive,
    );
  }
}
