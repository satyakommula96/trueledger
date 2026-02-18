import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/data/dtos/credit_card_dto.dart';

void main() {
  group('CreditCardDto Tests', () {
    test('fromJson handles full data correctly', () {
      final json = {
        'id': 1,
        'bank': 'HDFC',
        'credit_limit': 500000.0,
        'statement_balance': 10000.0,
        'current_balance': 5000.0,
        'min_due': 500.0,
        'due_date': '2023-12-01',
        'statement_date': 'Day 15',
      };

      final dto = CreditCardDto.fromJson(json);

      expect(dto.id, 1);
      expect(dto.bank, 'HDFC');
      expect(dto.creditLimit, 500000.0);
      expect(dto.statementBalance, 10000.0);
      expect(dto.currentBalance, 5000.0);
      expect(dto.minDue, 500.0);
      expect(dto.dueDate, '2023-12-01');
      expect(dto.statementDate, 'Day 15');
    });

    test('fromJson handles missing fields with default values', () {
      final json = {
        'id': 1,
        'bank': 'HDFC',
        // missing credit_limit, statement_balance, current_balance, min_due, due_date, statement_date
      };

      final dto = CreditCardDto.fromJson(json);

      expect(dto.id, 1);
      expect(dto.bank, 'HDFC');
      expect(dto.creditLimit, 0.0);
      expect(dto.statementBalance, 0.0);
      expect(dto.currentBalance, 0.0);
      expect(dto.minDue, 0.0);
      expect(dto.dueDate, '');
      expect(dto.statementDate, '');
    });

    test('fromJson handles null fields with default values', () {
      final json = {
        'id': 1,
        'bank': null,
        'credit_limit': null,
        'statement_balance': null,
        'current_balance': null,
        'min_due': null,
        'due_date': null,
        'statement_date': null,
      };

      final dto = CreditCardDto.fromJson(json);

      expect(dto.id, 1);
      expect(dto.bank, '');
      expect(dto.creditLimit, 0.0);
      expect(dto.statementBalance, 0.0);
      expect(dto.currentBalance, 0.0);
      expect(dto.minDue, 0.0);
      expect(dto.dueDate, '');
      expect(dto.statementDate, '');
    });
  });
}
