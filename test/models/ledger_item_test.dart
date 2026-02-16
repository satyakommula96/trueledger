import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/domain/models/ledger_item_model.dart';
import 'package:trueledger/data/dtos/ledger_item_dto.dart';

void main() {
  group('LedgerItem', () {
    test('LedgerItemDto should parse category correctly', () {
      final map = {
        'id': 1,
        'category': 'Food',
        'amount': 500.0,
        'date': '2026-01-23T00:00:00.000Z',
        'entryType': 'Variable',
        'note': 'Dinner',
      };

      final item = LedgerItemDto.fromJson(map).toDomain();

      expect(item.id, 1);
      expect(item.label, 'Food');
      expect(item.amount, 500);
      expect(item.type, 'Variable');
      expect(item.note, 'Dinner');
    });

    test('LedgerItemDto should fallback to source for Income', () {
      final map = {
        'id': 2,
        'source': 'Salary',
        'amount': 50000.0,
        'date': '2026-01-01T00:00:00.000Z',
        'entryType': 'Income',
      };

      final item = LedgerItemDto.fromJson(map).toDomain();

      expect(item.label, 'Salary');
      expect(item.type, 'Income');
    });

    test('LedgerItemDto should fallback to name', () {
      final map = {
        'id': 3,
        'name': 'Rent',
        'amount': 10000.0,
        'date': '2026-01-05T00:00:00.000Z',
        'entryType': 'Fixed',
      };

      final item = LedgerItemDto.fromJson(map).toDomain();

      expect(item.label, 'Rent');
      expect(item.type, 'Fixed');
    });

    test('LedgerItemDto should reconstruct Income map', () {
      final item = LedgerItem(
        id: 1,
        label: 'Salary',
        amount: 50000,
        date: DateTime(2026, 1, 1),
        type: 'Income',
      );

      final map = LedgerItemDto.fromDomain(item).toJson();

      expect(map['source'], 'Salary');
      expect(map['id'], 1);
    });

    test('LedgerItemDto should reconstruct Variable map', () {
      final item = LedgerItem(
        id: 2,
        label: 'Food',
        amount: 500,
        date: DateTime(2026, 1, 23),
        type: 'Variable',
        note: 'Dinner',
      );

      final map = LedgerItemDto.fromDomain(item).toJson();

      expect(map['category'], 'Food');
      expect(map['note'], 'Dinner');
    });

    test('LedgerItemDto should reconstruct Fixed map', () {
      final item = LedgerItem(
        id: 3,
        label: 'Rent',
        amount: 10000,
        date: DateTime(2026, 1, 5),
        type: 'Fixed',
      );

      final map = LedgerItemDto.fromDomain(item).toJson();

      expect(map['name'], 'Rent');
    });
  });
}
