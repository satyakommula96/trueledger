
import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/domain/models/subscription_model.dart';

void main() {
  group('Subscription', () {
    test('fromMap should parse correctly', () {
      final map = {
        'id': 1,
        'name': 'Netflix',
        'amount': 649,
        'billing_date': '15',
        'active': 1,
        'date': '2026-01-15',
      };

      final sub = Subscription.fromMap(map);

      expect(sub.id, 1);
      expect(sub.name, 'Netflix');
      expect(sub.amount, 649);
      expect(sub.billingDate, '15');
      expect(sub.active, 1);
      expect(sub.date, '2026-01-15');
    });

    test('toMap should work correctly', () {
      final sub = Subscription(
        id: 1,
        name: 'Netflix',
        amount: 649,
        billingDate: '15',
        active: 1,
        date: '2026-01-15',
      );

      final map = sub.toMap();

      expect(map['id'], 1);
      expect(map['name'], 'Netflix');
      expect(map['amount'], 649);
      expect(map['billing_date'], '15');
      expect(map['active'], 1);
      expect(map['date'], '2026-01-15');
    });

    test('fromMap should accept null date', () {
      final map = {
        'id': 1,
        'name': 'Spotify',
        'amount': 119,
        'billing_date': '1',
        'active': 1,
        'date': null,
      };

      final sub = Subscription.fromMap(map);

      expect(sub.date, isNull);
    });
  });
}
