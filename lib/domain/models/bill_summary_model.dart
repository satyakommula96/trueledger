import 'package:trueledger/core/utils/date_helper.dart';

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

  factory BillSummary.fromMap(Map<String, dynamic> map) {
    return BillSummary(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? map['title'] ?? 'Bill').toString(),
      amount: _parseAmount(map['amount']),
      dueDate: DateHelper.parseDue(map['due']?.toString() ?? ''),
      type: map['type']?.toString() ?? 'BILL',
      isPaid: map['isPaid'] == true || map['isPaid'] == 1,
    );
  }

  static double _parseAmount(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) {
      if (value.trim().isEmpty) return 0.0;
      return double.tryParse(value) ?? 0.0;
    }
    return 0;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'due': dueDate?.toIso8601String(),
        'type': type,
        'isPaid': isPaid,
      };

  /// Shared logic to identify unpaid bills due on a specific day from raw database maps.
  static List<BillSummary> filterDueEntries(
      List<dynamic> entries, DateTime date) {
    return entries
        .map((e) => BillSummary.fromMap(Map<String, dynamic>.from(e)))
        .where((b) =>
            b.dueDate != null &&
            DateHelper.isSameDay(b.dueDate!, date) &&
            !b.isPaid)
        .toList();
  }
}
