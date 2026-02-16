import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/domain/models/saving_goal_model.dart';
import 'package:trueledger/data/dtos/saving_goal_dto.dart';

void main() {
  group('SavingGoal', () {
    test('SavingGoalDto should parse correctly', () {
      final map = {
        'id': 1,
        'name': 'Vacation',
        'target_amount': 10000.0,
        'current_amount': 5000.0,
      };

      final goal = SavingGoalDto.fromJson(map).toDomain();

      expect(goal.id, 1);
      expect(goal.name, 'Vacation');
      expect(goal.targetAmount, 10000);
      expect(goal.currentAmount, 5000);
    });

    test('SavingGoalDto should work correctly to json', () {
      final goal = SavingGoal(
        id: 1,
        name: 'Vacation',
        targetAmount: 10000,
        currentAmount: 5000,
      );

      final map = SavingGoalDto.fromDomain(goal).toJson();

      expect(map['id'], 1);
      expect(map['name'], 'Vacation');
      expect(map['target_amount'], 10000);
      expect(map['current_amount'], 5000);
    });
  });
}
