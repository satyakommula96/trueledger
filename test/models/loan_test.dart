import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/domain/models/loan_model.dart';
import 'package:trueledger/data/dtos/loan_dto.dart';

void main() {
  group('Loan', () {
    test('LoanDto should parse correctly', () {
      final map = {
        'id': 1,
        'name': 'Home Loan',
        'loan_type': 'Home',
        'total_amount': 5000000.0,
        'remaining_amount': 4000000.0,
        'emi': 45000.0,
        'interest_rate': 8.5,
        'due_date': '5',
        'date': '2024-01-01',
        'interest_engine_version': 1,
      };

      final loan = LoanDto.fromJson(map).toDomain();

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

    test('LoanDto should work correctly to json', () {
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

      final map = LoanDto.fromDomain(loan).toJson();

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

    test('LoanDto should accept null date', () {
      final map = {
        'id': 1,
        'name': 'Car Loan',
        'loan_type': 'Auto',
        'total_amount': 500000.0,
        'remaining_amount': 400000.0,
        'emi': 15000.0,
        'interest_rate': 9.0,
        'due_date': '10',
        'date': null,
        'interest_engine_version': 1,
      };

      final loan = LoanDto.fromJson(map).toDomain();

      expect(loan.date, isNull);
    });

    group('Loan model', () {
      test('equality should work correctly', () {
        final l1 = Loan(
            id: 1,
            name: 'A',
            loanType: 'T',
            totalAmount: 100,
            remainingAmount: 50,
            emi: 10,
            interestRate: 5,
            dueDate: '1');
        final l2 = Loan(
            id: 1,
            name: 'A',
            loanType: 'T',
            totalAmount: 100,
            remainingAmount: 50,
            emi: 10,
            interestRate: 5,
            dueDate: '1');
        final l3 = Loan(
            id: 2,
            name: 'A',
            loanType: 'T',
            totalAmount: 100,
            remainingAmount: 50,
            emi: 10,
            interestRate: 5,
            dueDate: '1');

        expect(l1 == l2, isTrue);
        expect(l1 == l3, isFalse);
      });
    });
  });
}
