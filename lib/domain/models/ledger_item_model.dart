import 'transaction_tag.dart';

class LedgerItem {
  final int id;
  final String label; // Unifies name, category, source
  final double amount;
  final DateTime date;
  final String type; // 'Variable', 'Income', 'Fixed', 'Investment'
  final String? note;
  final Set<TransactionTag> tags;

  LedgerItem({
    required this.id,
    required this.label,
    required this.amount,
    required this.date,
    required this.type,
    this.note,
    this.tags = const {},
  });

  LedgerItem copyWith({
    int? id,
    String? label,
    double? amount,
    DateTime? date,
    String? type,
    String? note,
    Set<TransactionTag>? tags,
  }) {
    return LedgerItem(
      id: id ?? this.id,
      label: label ?? this.label,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      note: note ?? this.note,
      tags: tags ?? this.tags,
    );
  }
}
