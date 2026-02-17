import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/domain/models/transaction_tag.dart';
import 'package:trueledger/domain/models/ledger_item_model.dart';
import 'package:trueledger/data/dtos/ledger_item_dto.dart';

void main() {
  group('TransactionTag', () {
    test('name property returns string representation without enum prefix', () {
      expect(TransactionTag.loanEmi.name, 'loanEmi');
      expect(TransactionTag.transfer.name, 'transfer');
    });

    test('fromString correctly parses valid tags', () {
      expect(
          TransactionTagHelper.fromString('loanEmi'), TransactionTag.loanEmi);
      expect(TransactionTagHelper.fromString('income'), TransactionTag.income);
    });

    test('fromString defaults to transfer for invalid tags', () {
      expect(TransactionTagHelper.fromString('invalid_tag'),
          TransactionTag.transfer);
      expect(TransactionTagHelper.fromString(''), TransactionTag.transfer);
    });
  });

  group('LedgerItem Tag Parsing', () {
    test('LedgerItemDto correctly parses tags from comma-separated string', () {
      final map = {
        'id': 1,
        'name': 'Test',
        'amount': 100.0,
        'date': '2024-01-01T00:00:00.000Z',
        'entryType': 'Fixed',
        'tags': 'loanEmi,loanPrepayment'
      };

      final item = LedgerItemDto.fromJson(map).toDomain();
      expect(item.tags, contains(TransactionTag.loanEmi));
      expect(item.tags, contains(TransactionTag.loanPrepayment));
      expect(item.tags.length, 2);
    });

    test('LedgerItemDto handles empty or null tags', () {
      final mapNoTags = {
        'id': 1,
        'name': 'Test',
        'amount': 100.0,
        'date': '2024-01-01T00:00:00.000Z',
        'entryType': 'Fixed',
        'tags': null
      };

      expect(LedgerItemDto.fromJson(mapNoTags).toDomain().tags, isEmpty);

      final mapEmptyTags = {
        'id': 1,
        'name': 'Test',
        'amount': 100.0,
        'date': '2024-01-01T00:00:00.000Z',
        'entryType': 'Fixed',
        'tags': ''
      };
      expect(LedgerItemDto.fromJson(mapEmptyTags).toDomain().tags, isEmpty);
    });

    test('LedgerItemDto serializes tags correctly', () {
      final item = LedgerItem(
        id: 1,
        label: 'Test',
        amount: 100.0,
        date: DateTime(2024, 1, 1),
        type: 'Fixed',
        tags: {TransactionTag.loanEmi, TransactionTag.income},
      );

      final map = LedgerItemDto.fromDomain(item).toJson();
      expect(map['tags'], 'loanEmi,income');
    });
  });
}
