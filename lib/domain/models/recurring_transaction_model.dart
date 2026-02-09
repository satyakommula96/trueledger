class RecurringTransaction {
  final int id;
  final String name;
  final double amount;
  final String category;
  final String type; // INCOME or EXPENSE
  final String frequency; // DAILY, WEEKLY, MONTHLY, YEARLY
  final int? dayOfMonth;
  final int? dayOfWeek;
  final String? lastProcessed;
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

  factory RecurringTransaction.fromMap(Map<String, dynamic> map) {
    return RecurringTransaction(
      id: map['id'] as int,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      type: map['type'] as String,
      frequency: map['frequency'] as String,
      dayOfMonth: map['day_of_month'] as int?,
      dayOfWeek: map['day_of_week'] as int?,
      lastProcessed: map['last_processed'] as String?,
      isActive: (map['active'] as int? ?? 1) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category,
      'type': type,
      'frequency': frequency,
      'day_of_month': dayOfMonth,
      'day_of_week': dayOfWeek,
      'last_processed': lastProcessed,
      'active': isActive ? 1 : 0,
    };
  }
}
