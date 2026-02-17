import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/domain/models/budget_model.dart';
import 'package:trueledger/data/dtos/budget_dto.dart';

void main() {
  group('Budget', () {
    test('BudgetDto should parse correctly', () {
      final map = {
        'id': 1,
        'category': 'Food',
        'monthly_limit': 5000.0,
        'spent': 3500.0,
        'last_reviewed_at': '2025-02-03T23:00:00.000',
        'is_stable': 1,
      };

      final budget = BudgetDto.fromJson(map).toDomain();

      expect(budget.id, 1);
      expect(budget.category, 'Food');
      expect(budget.monthlyLimit, 5000);
      expect(budget.spent, 3500);
      expect(budget.lastReviewedAt, isNotNull);
      expect(budget.isStable, isTrue);
    });

    test('BudgetDto should work correctly to json', () {
      final budget = Budget(
        id: 1,
        category: 'Food',
        monthlyLimit: 5000,
        spent: 3500,
        lastReviewedAt: DateTime(2025, 2, 3),
      );

      final map = BudgetDto.fromDomain(budget).toJson();

      expect(map['id'], 1);
      expect(map['category'], 'Food');
      expect(map['monthly_limit'], 5000);
      expect(map['last_reviewed_at'], isA<String>());
    });

    test('BudgetDto should handle missing spent field', () {
      final map = {
        'id': 1,
        'category': 'Food',
        'monthly_limit': 5000.0,
      };

      final budget = BudgetDto.fromJson(map).toDomain();

      expect(budget.spent, 0);
    });
  });
}
