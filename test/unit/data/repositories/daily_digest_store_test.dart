import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/data/repositories/daily_digest_store.dart';

void main() {
  group('DailyDigestStore', () {
    late SharedPreferences prefs;
    late DailyDigestStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      store = DailyDigestStore(prefs);
    });

    test('saves and retrieves today\'s digest state', () async {
      await store.saveState(date: '2026-02-22', count: 5, total: 150.5);

      expect(store.getLastDigestDate(), '2026-02-22');
      expect(store.getLastDigestCount(), 5);
      expect(store.getLastDigestTotal(), 150.5);
    });

    test('handles double to int conversion for total', () async {
      await prefs.setInt('last_bill_digest_total', 100);
      expect(store.getLastDigestTotal(), 100.0);
    });

    test('saves and retrieves tomorrow\'s digest state', () async {
      await store.saveTomorrowState(date: '2026-02-23', count: 3, total: 45.2);

      expect(store.getTomorrowLastDigestDate(), '2026-02-23');
      expect(store.getTomorrowLastDigestCount(), 3);
      expect(store.getTomorrowLastDigestTotal(), 45.2);
    });

    test('handles double to int conversion for tomorrow total', () async {
      await prefs.setInt('tomorrow_last_bill_digest_total', 200);
      expect(store.getTomorrowLastDigestTotal(), 200.0);
    });

    test('returns null when values do not exist', () {
      expect(store.getLastDigestDate(), isNull);
      expect(store.getLastDigestCount(), isNull);
      expect(store.getLastDigestTotal(), isNull);

      expect(store.getTomorrowLastDigestDate(), isNull);
      expect(store.getTomorrowLastDigestCount(), isNull);
      expect(store.getTomorrowLastDigestTotal(), isNull);
    });
  });
}
