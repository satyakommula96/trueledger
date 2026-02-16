class Asset {
  final int id;
  final String name;
  final double amount;
  final String type;
  final DateTime date;
  final bool isActive;

  Asset({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.date,
    required this.isActive,
  });

  Asset copyWith({
    int? id,
    String? name,
    double? amount,
    String? type,
    DateTime? date,
    bool? isActive,
  }) {
    return Asset(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      isActive: isActive ?? this.isActive,
    );
  }
}
