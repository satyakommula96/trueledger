import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/domain/models/category_model.dart';

void main() {
  group('TransactionCategory Model', () {
    test('toMap and fromMap should be consistent', () {
      final category = TransactionCategory(
        id: 1,
        name: 'Test',
        type: 'Variable',
        orderIndex: 5,
      );

      final map = category.toMap();
      expect(map['id'], 1);
      expect(map['name'], 'Test');
      expect(map['type'], 'Variable');
      expect(map['order_index'], 5);

      final fromMap = TransactionCategory.fromMap(map);
      expect(fromMap, category);
      expect(fromMap.hashCode, category.hashCode);
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
