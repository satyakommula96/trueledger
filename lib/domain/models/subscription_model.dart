class Subscription {
  final int id;
  final String name;
  final double amount;
  final String billingDate;
  final int active;
  final String? date;

  Subscription({
    required this.id,
    required this.name,
    required this.amount,
    required this.billingDate,
    required this.active,
    this.date,
  });

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'] as int,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      billingDate: map['billing_date'] as String,
      active: map['active'] as int,
      date: map['date'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'billing_date': billingDate,
      'active': active,
      'date': date,
    };
  }
}
