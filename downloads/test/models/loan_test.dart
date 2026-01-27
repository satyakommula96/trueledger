import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/domain/models/loan_model.dart';

void main() {
  group('Loan', () {
    test('fromMap should parse correctly', () {
      final map = {
        'id': 1,
        'name': 'Home Loan',
        'loan_type': 'Home',
        'total_amount': 5000000,
        'remaining_amount': 4000000,
        'emi': 45000,
        'interest_rate': 8.5,
        'due_date': '5',
        'date': '2024-01-01',
      };

      final loan = Loan.fromMap(map);

      expect(loan.id, 1);
      expect(loan.name, 'Home Loan');
      expect(loan.loanType, 'Home');
      expect(loan.totalAmount, 5000000);
      expect(loan.remainingAmount, 4000000);
      expect(loan.emi, 45000);
      expect(loan.interestRate, 8.5);
      expect(loan.dueDate, '5');
      expect(loan.date, '2024-01-01');
    });

    test('toMap should work correctly', () {
      final loan = Loan(
        id: 1,
        name: 'Home Loan',
        loanType: 'Home',
        totalAmount: 5000000,
        remainingAmount: 4000000,
        emi: 45000,
        interestRate: 8.5,
        dueDate: '5',
        date: '2024-01-01',
      );

      final map = loan.toMap();

      expect(map['id'], 1);
      expect(map['name'], 'Home Loan');
      expect(map['loan_type'], 'Home');
      expect(map['total_amount'], 5000000);
      expect(map['remaining_amount'], 4000000);
      expect(map['emi'], 45000);
      expect(map['interest_rate'], 8.5);
      expect(map['due_date'], '5');
      expect(map['date'], '2024-01-01');
    });

    test('fromMap should accept null date', () {
      final map = {
        'id': 1,
        'name': 'Car Loan',
        'loan_type': 'Auto',
        'total_amount': 500000,
        'remaining_amount': 400000,
        'emi': 15000,
        'interest_rate': 9.0,
        'due_date': '10',
        'date': null,
      };

      final loan = Loan.fromMap(map);

      expect(loan.date, isNull);
    });
  });
}
