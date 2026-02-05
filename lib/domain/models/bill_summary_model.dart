import 'package:trueledger/core/utils/date_helper.dart';

class BillSummary {
  final String id;
  final String name;
  final int amount;
  final DateTime? dueDate;
  final String type;

  BillSummary({
    required this.id,
    required this.name,
    required this.amount,
    this.dueDate,
    required this.type,
  });

  factory BillSummary.fromMap(Map<String, dynamic> map) {
    return BillSummary(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? map['title'] ?? 'Bill').toString(),
      amount: _parseAmount(map['amount']),
      dueDate: DateHelper.parseDue(map['due']?.toString() ?? ''),
      type: map['type']?.toString() ?? 'BILL',
    );
  }

  static int _parseAmount(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) {
      if (value.trim().isEmpty) return 0;
      return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
    }
    return 0;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'due': dueDate?.toIso8601String(),
        'type': type,
      };
}
