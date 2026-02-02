import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/domain/models/category_model.dart';

void main() {
  group('TransactionCategory Model', () {
    test('should create TransactionCategory from map', () {
      final map = {
        'id': 1,
        'name': 'Food',
        'type': 'Variable',
      };

      final category = TransactionCategory.fromMap(map);

      expect(category.id, 1);
      expect(category.name, 'Food');
      expect(category.type, 'Variable');
    });

    test('should convert TransactionCategory to map', () {
      final category = TransactionCategory(
        id: 1,
        name: 'Salary',
        type: 'Income',
      );

      final map = category.toMap();

      expect(map['id'], 1);
      expect(map['name'], 'Salary');
      expect(map['type'], 'Income');
    });

    test('should convert TransactionCategory to map without id', () {
      final category = TransactionCategory(
        name: 'Rent',
        type: 'Fixed',
      );

      final map = category.toMap();

      expect(map.containsKey('id'), isFalse);
      expect(map['name'], 'Rent');
      expect(map['type'], 'Fixed');
    });
  });
}
