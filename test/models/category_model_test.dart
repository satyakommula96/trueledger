import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/domain/models/category_model.dart';
import 'package:trueledger/data/dtos/category_dto.dart';

void main() {
  group('TransactionCategory Model', () {
    test('TransactionCategoryDto should parse correctly', () {
      final map = {
        'id': 1,
        'name': 'Food',
        'type': 'Variable',
        'order_index': 0,
      };

      final category = TransactionCategoryDto.fromJson(map).toDomain();

      expect(category.id, 1);
      expect(category.name, 'Food');
      expect(category.type, 'Variable');
    });

    test('TransactionCategoryDto should work correctly to json', () {
      final category = TransactionCategory(
        id: 1,
        name: 'Salary',
        type: 'Income',
      );

      final map = TransactionCategoryDto.fromDomain(category).toJson();

      expect(map['id'], 1);
      expect(map['name'], 'Salary');
      expect(map['type'], 'Income');
    });

    test('TransactionCategoryDto should handle missing id', () {
      final category = TransactionCategory(
        name: 'Rent',
        type: 'Fixed',
      );

      final map = TransactionCategoryDto.fromDomain(category).toJson();

      expect(map['id'], isNull);
      expect(map['name'], 'Rent');
      expect(map['type'], 'Fixed');
    });
  });
}
