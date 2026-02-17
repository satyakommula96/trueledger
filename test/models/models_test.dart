import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/data/dtos/loan_dto.dart';
import 'package:trueledger/data/dtos/credit_card_dto.dart';
import 'package:trueledger/data/dtos/ledger_item_dto.dart';
import 'package:trueledger/data/dtos/subscription_dto.dart';
import 'package:trueledger/data/dtos/budget_dto.dart';
import 'package:trueledger/data/dtos/saving_goal_dto.dart';

void main() {
  group('Loan Model Tests', () {
    test('LoanDto creates valid domain object', () {
      final map = {
        'id': 1,
        'name': 'Home Loan',
        'loan_type': 'Mortgage',
        'total_amount': 5000000.0,
        'remaining_amount': 4500000.0,
        'emi': 35000.0,
        'interest_rate': 8.5,
        'due_date': '5th',
        'date': '2023-01-01',
        'interest_engine_version': 1,
      };

      final loan = LoanDto.fromJson(map).toDomain();

      expect(loan.id, 1);
      expect(loan.name, 'Home Loan');
      expect(loan.interestRate, 8.5);
      expect(loan.emi, 35000);
    });

    test('LoanDto.fromDomain returns valid map', () {
      final loan = Loan(
        id: 1,
        name: 'Car Loan',
        loanType: 'Auto',
        totalAmount: 100000,
        remainingAmount: 80000,
        emi: 5000,
        interestRate: 9.2,
        dueDate: '10th',
      );

      final map = LoanDto.fromDomain(loan).toJson();

      expect(map['name'], 'Car Loan');
      expect(map['loan_type'], 'Auto');
      expect(map['interest_rate'], 9.2);
    });
  });

  group('CreditCard Model Tests', () {
    test('CreditCard serialization via CreditCardDto', () {
      final card = CreditCard(
        id: 101,
        bank: 'HDFC',
        creditLimit: 50000,
        statementBalance: 12000,
        currentBalance: 12000,
        minDue: 600,
        dueDate: '15th',
        statementDate: '1st',
      );

      final map = CreditCardDto.fromDomain(card).toJson();
      expect(map['bank'], 'HDFC');
      expect(map['statement_balance'], 12000);

      final newCard = CreditCardDto.fromJson(map).toDomain();
      expect(newCard.bank, card.bank);
      expect(newCard.statementBalance, card.statementBalance);
    });
  });

  group('LedgerItem Model Tests', () {
    test('LedgerItemDto infers label from source for Income', () {
      final map = {
        'id': 1,
        'source': 'Salary',
        'amount': 50000.0,
        'date': '2023-01-01T00:00:00.000Z',
        'entryType': 'Income'
      };

      final item = LedgerItemDto.fromJson(map).toDomain();
      expect(item.label, 'Salary');
      expect(item.type, 'Income');

      final reconMap = LedgerItemDto.fromDomain(item).toJson();
      expect(reconMap['source'], 'Salary');
    });

    test('LedgerItemDto infers label from category for Variable', () {
      final map = {
        'id': 2,
        'category': 'Food',
        'amount': 200.0,
        'date': '2023-01-02T00:00:00.000Z',
        'entryType': 'Variable'
      };

      final item = LedgerItemDto.fromJson(map).toDomain();
      expect(item.label, 'Food');
      expect(item.type, 'Variable');
    });
  });

  group('Subscription Model Tests', () {
    test('Subscription serialization via SubscriptionDto', () {
      final sub = Subscription(
          id: 1,
          name: 'Netflix',
          amount: 800,
          billingDate: '10th',
          isActive: true);

      final map = SubscriptionDto.fromDomain(sub).toJson();
      expect(map['billing_date'], '10th');

      final newSub = SubscriptionDto.fromJson(map).toDomain();
      expect(newSub.name, 'Netflix');
    });
  });

  group('Budget Model Tests', () {
    test('Budget serialization via BudgetDto', () {
      final budget = Budget(id: 1, category: 'Travel', monthlyLimit: 10000);

      final map = BudgetDto.fromDomain(budget).toJson();
      expect(map['monthly_limit'], 10000);

      final newBudget =
          BudgetDto.fromJson({...map, 'spent': 5000.0}).toDomain();
      expect(newBudget.category, 'Travel');
      expect(newBudget.spent, 5000);
    });
  });

  group('SavingGoal Model Tests', () {
    test('SavingGoal progress calculation', () {
      final goal = SavingGoal(
          id: 1, name: 'Trip', targetAmount: 10000, currentAmount: 5000);

      expect(goal.targetAmount, 10000);
      expect(goal.currentAmount, 5000);

      final map = SavingGoalDto.fromDomain(goal).toJson();
      expect(map['target_amount'], 10000);
    });
  });
}
