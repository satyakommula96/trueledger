class Asset {
  final int id;
  final String name;
  final double amount;
  final String type;
  final String date;
  final int active;

  Asset({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.date,
    required this.active,
  });

  factory Asset.fromMap(Map<String, dynamic> map) {
    return Asset(
      id: map['id'] is int ? map['id'] as int : 0,
      name: (map['name'] as String?)?.trim().isNotEmpty == true
          ? map['name']
          : 'Unknown Asset',
      amount: map['amount'] is num ? (map['amount'] as num).toDouble() : 0.0,
      type: map['type'] is String ? map['type'] : 'Other',
      date: map['date'] is String
          ? map['date']
          : DateTime.now().toIso8601String(),
      active: map['active'] is num ? (map['active'] as num).toInt() : 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'type': type,
      'date': date,
      'active': active,
    };
  }
}
