class BillSummary {
  final String id;
  final String name;
  final double amount;
  final DateTime? dueDate;
  final String type;
  final bool isPaid;

  BillSummary({
    required this.id,
    required this.name,
    required this.amount,
    this.dueDate,
    required this.type,
    this.isPaid = false,
  });

  BillSummary copyWith({
    String? id,
    String? name,
    double? amount,
    DateTime? dueDate,
    String? type,
    bool? isPaid,
  }) {
    return BillSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      type: type ?? this.type,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}
