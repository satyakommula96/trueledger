import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/domain/models/subscription_model.dart';
import 'package:trueledger/data/dtos/subscription_dto.dart';

void main() {
  group('Subscription', () {
    test('SubscriptionDto should parse correctly', () {
      final map = {
        'id': 1,
        'name': 'Netflix',
        'amount': 649.0,
        'billing_date': '15',
        'active': 1,
        'date': '2026-01-15',
      };

      final sub = SubscriptionDto.fromJson(map).toDomain();

      expect(sub.id, 1);
      expect(sub.name, 'Netflix');
      expect(sub.amount, 649);
      expect(sub.billingDate, '15');
      expect(sub.isActive, isTrue);
      expect(sub.date, '2026-01-15');
    });

    test('SubscriptionDto should work correctly to json', () {
      final sub = Subscription(
        id: 1,
        name: 'Netflix',
        amount: 649,
        billingDate: '15',
        isActive: true,
        date: '2026-01-15',
      );

      final map = SubscriptionDto.fromDomain(sub).toJson();

      expect(map['id'], 1);
      expect(map['name'], 'Netflix');
      expect(map['amount'], 649);
      expect(map['billing_date'], '15');
      expect(map['active'], 1);
      expect(map['date'], '2026-01-15');
    });

    test('SubscriptionDto should accept null date', () {
      final map = {
        'id': 1,
        'name': 'Spotify',
        'amount': 119.0,
        'billing_date': '1',
        'active': 1,
        'date': null,
      };

      final sub = SubscriptionDto.fromJson(map).toDomain();

      expect(sub.date, isNull);
    });
  });
}
