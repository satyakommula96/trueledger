class TransactionCategory {
  final int? id;
  final String name;
  final String type; // Variable, Fixed, Income, Investment, Subscription
  final int orderIndex;

  TransactionCategory({
    this.id,
    required this.name,
    required this.type,
    this.orderIndex = 0,
  });

  TransactionCategory copyWith({
    int? id,
    String? name,
    String? type,
    int? orderIndex,
  }) {
    return TransactionCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionCategory &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type &&
          orderIndex == other.orderIndex;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ type.hashCode ^ orderIndex.hashCode;
}
