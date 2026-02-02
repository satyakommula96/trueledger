class TransactionCategory {
  final int? id;
  final String name;
  final String type; // Variable, Fixed, Income, Investment, Subscription

  TransactionCategory({this.id, required this.name, required this.type});

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'type': type,
    };
  }

  factory TransactionCategory.fromMap(Map<String, dynamic> map) {
    return TransactionCategory(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: map['type'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionCategory &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ type.hashCode;
}
