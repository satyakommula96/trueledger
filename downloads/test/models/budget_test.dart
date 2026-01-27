import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/domain/models/budget_model.dart';

void main() {
  group('Budget', () {
    test('fromMap should parse correctly', () {
      final map = {
        'id': 1,
        'category': 'Food',
        'monthly_limit': 5000,
        'spent': 3500,
      };

      final budget = Budget.fromMap(map);

      expect(budget.id, 1);
      expect(budget.category, 'Food');
      expect(budget.monthlyLimit, 5000);
      expect(budget.spent, 3500);
    });

    test('toMap should work correctly', () {
      final budget = Budget(
        id: 1,
        category: 'Food',
        monthlyLimit: 5000,
        spent: 3500,
      );

      final map = budget.toMap();

      expect(map['id'], 1);
      expect(map['category'], 'Food');
      expect(map['monthly_limit'], 5000);
    });

    test('fromMap should handle missing spent field', () {
      final map = {
        'id': 1,
        'category': 'Food',
        'monthly_limit': 5000,
      };

      final budget = Budget.fromMap(map);

      expect(budget.spent, 0);
    });
  });
}
