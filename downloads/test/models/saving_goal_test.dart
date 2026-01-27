import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/domain/models/saving_goal_model.dart';

void main() {
  group('SavingGoal', () {
    test('fromMap should parse correctly', () {
      final map = {
        'id': 1,
        'name': 'Vacation',
        'target_amount': 10000,
        'current_amount': 5000,
      };

      final goal = SavingGoal.fromMap(map);

      expect(goal.id, 1);
      expect(goal.name, 'Vacation');
      expect(goal.targetAmount, 10000);
      expect(goal.currentAmount, 5000);
    });

    test('toMap should work correctly', () {
      final goal = SavingGoal(
        id: 1,
        name: 'Vacation',
        targetAmount: 10000,
        currentAmount: 5000,
      );

      final map = goal.toMap();

      expect(map['id'], 1);
      expect(map['name'], 'Vacation');
      expect(map['target_amount'], 10000);
      expect(map['current_amount'], 5000);
    });
  });
}
