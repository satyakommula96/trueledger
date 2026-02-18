import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/data/dtos/loan_dto.dart';
import 'package:trueledger/data/dtos/budget_dto.dart';
import 'package:trueledger/data/dtos/saving_goal_dto.dart';
import 'package:trueledger/data/dtos/subscription_dto.dart';

void main() {
  group('DTO Resilience Tests', () {
    test('LoanDto.fromJson handles missing/null fields with defaults', () {
      final json = {'id': 1, 'name': 'Home Loan'};
      final dto = LoanDto.fromJson(json);

      expect(dto.id, 1);
      expect(dto.name, 'Home Loan');
      expect(dto.loanType, 'Personal'); // default
      expect(dto.totalAmount, 0.0);
      expect(dto.emi, 0.0);
    });

    test('BudgetDto.fromJson handles missing/null fields with defaults', () {
      final json = {'id': 1};
      final dto = BudgetDto.fromJson(json);

      expect(dto.id, 1);
      expect(dto.category, '');
      expect(dto.monthlyLimit, 0.0);
    });

    test('SavingGoalDto.fromJson handles missing/null fields with defaults',
        () {
      final json = {'id': 1, 'name': 'Trip'};
      final dto = SavingGoalDto.fromJson(json);

      expect(dto.id, 1);
      expect(dto.name, 'Trip');
      expect(dto.targetAmount, 0.0);
      expect(dto.currentAmount, 0.0);
    });

    test('SubscriptionDto.fromJson handles missing/null fields with defaults',
        () {
      final json = {'id': 1, 'name': 'Netflix'};
      final dto = SubscriptionDto.fromJson(json);

      expect(dto.id, 1);
      expect(dto.name, 'Netflix');
      expect(dto.amount, 0.0);
      expect(dto.billingDate, '1');
      expect(dto.isActive, 1);
    });
  });
}
