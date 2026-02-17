import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/domain/models/credit_card_model.dart';
import 'package:trueledger/data/dtos/credit_card_dto.dart';

void main() {
  group('CreditCard', () {
    test('CreditCardDto should parse correctly', () {
      final map = {
        'id': 1,
        'bank': 'HDFC',
        'credit_limit': 100000.0,
        'statement_balance': 25000.0,
        'current_balance': 25000.0,
        'min_due': 1000.0,
        'due_date': '15',
        'statement_date': '1st',
      };

      final card = CreditCardDto.fromJson(map).toDomain();

      expect(card.id, 1);
      expect(card.bank, 'HDFC');
      expect(card.creditLimit, 100000);
      expect(card.statementBalance, 25000);
      expect(card.minDue, 1000);
      expect(card.dueDate, '15');
    });

    test('CreditCardDto should work correctly to json', () {
      final card = CreditCard(
        id: 1,
        bank: 'HDFC',
        creditLimit: 100000,
        statementBalance: 25000,
        currentBalance: 25000,
        minDue: 1000,
        dueDate: '15',
        statementDate: '1st',
      );

      final map = CreditCardDto.fromDomain(card).toJson();

      expect(map['id'], 1);
      expect(map['bank'], 'HDFC');
      expect(map['credit_limit'], 100000);
      expect(map['statement_balance'], 25000);
      expect(map['min_due'], 1000);
      expect(map['due_date'], '15');
    });
  });
}
