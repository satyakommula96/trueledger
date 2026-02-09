import 'transaction_tag.dart';

class LedgerItem {
  final int id;
  final String label; // Unifies name, category, source
  final double amount;
  final String date;
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

  factory LedgerItem.fromMap(Map<String, dynamic> map) {
    // Logic to determine label based on available fields
    String label = "Unknown";
    if (map['name'] != null) {
      label = map['name'];
    } else if (map['category'] != null) {
      label = map['category'];
    } else if (map['source'] != null) {
      label = map['source'];
    }

    final tagStr = map['tags'] as String? ?? '';
    final tags = tagStr.isEmpty
        ? <TransactionTag>{}
        : tagStr
            .split(',')
            .map((s) => TransactionTagHelper.fromString(s.trim()))
            .toSet();

    return LedgerItem(
      id: map['id'] as int,
      label: label,
      amount: (map['amount'] as num).toDouble(),
      date: map['date'] as String? ?? '',
      type: map['entryType'] as String? ?? 'Unknown',
      note: map['note'] as String?,
      tags: tags,
    );
  }

  // Helper to convert back to map if needed for editing logic that expects specific keys
  Map<String, dynamic> toOriginalMap() {
    final map = <String, dynamic>{
      'id': id,
      'amount': amount,
      'date': date,
      'entryType': type,
      'note': note,
      'tags': tags.map((t) => t.name).join(','),
    };
    // Reconstruct specific keys based on type
    if (type == 'Income') {
      map['source'] = label;
    } else if (type == 'Variable') {
      map['category'] = label;
    } else {
      map['name'] = label;
    }

    return map;
  }
}
