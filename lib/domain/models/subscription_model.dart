class Subscription {
  final int id;
  final String name;
  final double amount;
  final String billingDate;
  final bool isActive;
  final String? date;

  Subscription({
    required this.id,
    required this.name,
    required this.amount,
    required this.billingDate,
    required this.isActive,
    this.date,
  });

  Subscription copyWith({
    int? id,
    String? name,
    double? amount,
    String? billingDate,
    bool? isActive,
    String? date,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      billingDate: billingDate ?? this.billingDate,
      isActive: isActive ?? this.isActive,
      date: date ?? this.date,
    );
  }
}
