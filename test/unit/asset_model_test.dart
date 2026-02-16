import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/domain/models/asset_model.dart';
import 'package:trueledger/data/dtos/asset_dto.dart';

void main() {
  group('Asset Serialization (via DTO)', () {
    test('AssetDto should parse JSON correctly and convert to Domain', () {
      final json = {
        'id': 1,
        'name': 'Gold',
        'amount': 5000.0,
        'type': 'Commodity',
        'date': '2026-01-23T00:00:00.000Z',
        'active': 1,
      };

      final dto = AssetDto.fromJson(json);
      final asset = dto.toDomain();

      expect(asset.id, 1);
      expect(asset.name, 'Gold');
      expect(asset.amount, 5000.0);
      expect(asset.type, 'Commodity');
      expect(asset.date.isUtc, true); // UTC time because of 'Z' suffix in JSON
      expect(asset.isActive, true);
    });

    test('Asset domain to DTO should work correctly', () {
      final asset = Asset(
        id: 1,
        name: 'Gold',
        amount: 5000.0,
        type: 'Commodity',
        date: DateTime.utc(2026, 1, 23),
        isActive: true,
      );

      final dto = AssetDto.fromDomain(asset);
      final json = dto.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'Gold');
      expect(json['amount'], 5000.0);
      expect(json['type'], 'Commodity');
      expect(json['date'], '2026-01-23T00:00:00.000Z');
      expect(json['active'], 1);
    });
  });
}
