import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/domain/models/asset_model.dart';

void main() {
  group('Asset', () {
    test('fromMap should parse correctly', () {
      final map = {
        'id': 1,
        'name': 'Gold',
        'amount': 5000,
        'type': 'Commodity',
        'date': '2026-01-23',
        'active': 1,
      };

      final asset = Asset.fromMap(map);

      expect(asset.id, 1);
      expect(asset.name, 'Gold');
      expect(asset.amount, 5000);
      expect(asset.type, 'Commodity');
      expect(asset.date, '2026-01-23');
      expect(asset.active, 1);
    });

    test('toMap should work correctly', () {
      final asset = Asset(
        id: 1,
        name: 'Gold',
        amount: 5000,
        type: 'Commodity',
        date: '2026-01-23',
        active: 1,
      );

      final map = asset.toMap();

      expect(map['id'], 1);
      expect(map['name'], 'Gold');
      expect(map['amount'], 5000);
      expect(map['type'], 'Commodity');
      expect(map['date'], '2026-01-23');
      expect(map['active'], 1);
    });
  });
}
