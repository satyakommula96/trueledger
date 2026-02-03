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
        'last_reviewed_at': '2025-02-03T23:00:00.000',
        'is_stable': 1,
      };

      final budget = Budget.fromMap(map);

      expect(budget.id, 1);
      expect(budget.category, 'Food');
      expect(budget.monthlyLimit, 5000);
      expect(budget.spent, 3500);
      expect(budget.lastReviewedAt, isNotNull);
      expect(budget.isStable, isTrue);
    });

    test('toMap should work correctly', () {
      final budget = Budget(
        id: 1,
        category: 'Food',
        monthlyLimit: 5000,
        spent: 3500,
        lastReviewedAt: DateTime(2025, 2, 3),
      );

      final map = budget.toMap();

      expect(map['id'], 1);
      expect(map['category'], 'Food');
      expect(map['monthly_limit'], 5000);
      expect(map['last_reviewed_at'], isA<String>());
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
