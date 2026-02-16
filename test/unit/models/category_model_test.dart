import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/domain/models/category_model.dart';
import 'package:trueledger/data/dtos/category_dto.dart';

void main() {
  group('TransactionCategory Model', () {
    test('TransactionCategoryDto should be consistent with domain model', () {
      final category = TransactionCategory(
        id: 1,
        name: 'Test',
        type: 'Variable',
        orderIndex: 5,
      );

      final dto = TransactionCategoryDto.fromDomain(category);
      final json = dto.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'Test');
      expect(json['type'], 'Variable');
      expect(json['order_index'], 5);

      final fromDto = TransactionCategoryDto.fromJson(json).toDomain();
      expect(fromDto, category);
      expect(fromDto.hashCode, category.hashCode);
    });

    test('equality should work correctly', () {
      final c1 =
          TransactionCategory(id: 1, name: 'A', type: 'T', orderIndex: 0);
      final c2 =
          TransactionCategory(id: 1, name: 'A', type: 'T', orderIndex: 0);
      final c3 =
          TransactionCategory(id: 2, name: 'A', type: 'T', orderIndex: 0);

      expect(c1 == c2, isTrue);
      expect(c1 == c3, isFalse);
      expect(c1.hashCode == c2.hashCode, isTrue);
    });
  });
}
