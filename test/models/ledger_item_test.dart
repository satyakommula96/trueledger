
import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/domain/models/ledger_item_model.dart';

void main() {
  group('LedgerItem', () {
    test('fromMap should parse category correctly', () {
      final map = {
        'id': 1,
        'category': 'Food',
        'amount': 500,
        'date': '2026-01-23',
        'entryType': 'Variable',
        'note': 'Dinner',
      };

      final item = LedgerItem.fromMap(map);

      expect(item.id, 1);
      expect(item.label, 'Food');
      expect(item.amount, 500);
      expect(item.type, 'Variable');
      expect(item.note, 'Dinner');
    });

    test('fromMap should fallback to source for Income', () {
      final map = {
        'id': 2,
        'source': 'Salary',
        'amount': 50000,
        'date': '2026-01-01',
        'entryType': 'Income',
      };

      final item = LedgerItem.fromMap(map);

      expect(item.label, 'Salary');
      expect(item.type, 'Income');
    });

    test('fromMap should fallback to name', () {
      final map = {
        'id': 3,
        'name': 'Rent',
        'amount': 10000,
        'date': '2026-01-05',
        'entryType': 'Fixed',
      };

      final item = LedgerItem.fromMap(map);

      expect(item.label, 'Rent');
      expect(item.type, 'Fixed');
    });

    test('toOriginalMap should reconstruct Income map', () {
      final item = LedgerItem(
        id: 1,
        label: 'Salary',
        amount: 50000,
        date: '2026-01-01',
        type: 'Income',
      );

      final map = item.toOriginalMap();

      expect(map['source'], 'Salary');
      expect(map['id'], 1);
    });

    test('toOriginalMap should reconstruct Variable map', () {
      final item = LedgerItem(
        id: 2,
        label: 'Food',
        amount: 500,
        date: '2026-01-23',
        type: 'Variable',
        note: 'Dinner',
      );

      final map = item.toOriginalMap();

      expect(map['category'], 'Food');
      expect(map['note'], 'Dinner');
    });

    test('toOriginalMap should reconstruct Fixed map', () {
      final item = LedgerItem(
        id: 3,
        label: 'Rent',
        amount: 10000,
        date: '2026-01-05',
        type: 'Fixed',
      );

      final map = item.toOriginalMap();

      expect(map['name'], 'Rent');
    });
  });
}
