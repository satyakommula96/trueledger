
import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/domain/models/credit_card_model.dart';

void main() {
  group('CreditCard', () {
    test('fromMap should parse correctly', () {
      final map = {
        'id': 1,
        'bank': 'HDFC',
        'credit_limit': 100000,
        'statement_balance': 25000,
        'min_due': 1000,
        'due_date': '15',
      };

      final card = CreditCard.fromMap(map);

      expect(card.id, 1);
      expect(card.bank, 'HDFC');
      expect(card.creditLimit, 100000);
      expect(card.statementBalance, 25000);
      expect(card.minDue, 1000);
      expect(card.dueDate, '15');
    });

    test('toMap should work correctly', () {
      final card = CreditCard(
        id: 1,
        bank: 'HDFC',
        creditLimit: 100000,
        statementBalance: 25000,
        minDue: 1000,
        dueDate: '15',
      );

      final map = card.toMap();

      expect(map['id'], 1);
      expect(map['bank'], 'HDFC');
      expect(map['credit_limit'], 100000);
      expect(map['statement_balance'], 25000);
      expect(map['min_due'], 1000);
      expect(map['due_date'], '15');
    });
  });
}
