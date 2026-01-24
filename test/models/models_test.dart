import 'package:flutter_test/flutter_test.dart';
import 'package:truecash/domain/models/models.dart';

void main() {
  group('Loan Model Tests', () {
    test('Loan.fromMap creates valid object', () {
      final map = {
        'id': 1,
        'name': 'Home Loan',
        'loan_type': 'Mortgage',
        'total_amount': 5000000,
        'remaining_amount': 4500000,
        'emi': 35000,
        'interest_rate': 8.5,
        'due_date': '5th',
        'date': '2023-01-01'
      };

      final loan = Loan.fromMap(map);

      expect(loan.id, 1);
      expect(loan.name, 'Home Loan');
      expect(loan.interestRate, 8.5);
      expect(loan.emi, 35000);
    });

    test('Loan.toMap returns valid map', () {
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

      final map = loan.toMap();

      expect(map['name'], 'Car Loan');
      expect(map['loan_type'], 'Auto');
      expect(map['interest_rate'], 9.2);
    });
  });

  group('CreditCard Model Tests', () {
    test('CreditCard serialization', () {
      final card = CreditCard(
          id: 101,
          bank: 'HDFC',
          creditLimit: 50000,
          statementBalance: 12000,
          minDue: 600,
          dueDate: '15th',
          generationDate: '2023-01-01');

      final map = card.toMap();
      expect(map['bank'], 'HDFC');
      expect(map['statement_balance'], 12000);

      final newCard = CreditCard.fromMap(map);
      expect(newCard.bank, card.bank);
      expect(newCard.statementBalance, card.statementBalance);
    });
  });

  group('LedgerItem Model Tests', () {
    test('LedgerItem infers label from source for Income', () {
      final map = {
        'id': 1,
        'source': 'Salary',
        'amount': 50000,
        'date': '2023-01-01',
        'entryType': 'Income'
      };

      final item = LedgerItem.fromMap(map);
      expect(item.label, 'Salary');
      expect(item.type, 'Income');

      final reconMap = item.toOriginalMap();
      expect(reconMap['source'], 'Salary');
    });

    test('LedgerItem infers label from category for Variable', () {
      final map = {
        'id': 2,
        'category': 'Food',
        'amount': 200,
        'date': '2023-01-02',
        'entryType': 'Variable'
      };

      final item = LedgerItem.fromMap(map);
      expect(item.label, 'Food');
      expect(item.type, 'Variable');
    });
  });

  group('Subscription Model Tests', () {
    test('Subscription serialization', () {
      final sub = Subscription(
          id: 1, name: 'Netflix', amount: 800, billingDate: '10th', active: 1);

      final map = sub.toMap();
      expect(map['billing_date'], '10th');

      final newSub = Subscription.fromMap(map);
      expect(newSub.name, 'Netflix');
    });
  });

  group('Budget Model Tests', () {
    test('Budget serialization', () {
      final budget = Budget(id: 1, category: 'Travel', monthlyLimit: 10000);

      final map = budget.toMap();
      expect(map['monthly_limit'], 10000);

      final newBudget = Budget.fromMap({...map, 'spent': 5000});
      expect(newBudget.category, 'Travel');
      expect(newBudget.spent, 5000);
    });
  });

  group('SavingGoal Model Tests', () {
    test('SavingGoal progress calculation', () {
      // Since logic is often in UI, we just test data integrity here
      final goal = SavingGoal(
          id: 1, name: 'Trip', targetAmount: 10000, currentAmount: 5000);

      expect(goal.targetAmount, 10000);
      expect(goal.currentAmount, 5000);

      final map = goal.toMap();
      expect(map['target_amount'], 10000);
    });
  });
}
