import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CurrencyFormatter.load();
    CurrencyFormatter.currencyNotifier.value = 'INR';
  });

  group('CurrencyFormatter', () {
    test('default currency is INR', () {
      expect(CurrencyFormatter.currencyNotifier.value, 'INR');
      expect(CurrencyFormatter.symbol, '₹');
    });

    test('format respects privacy', () {
      final result = CurrencyFormatter.format(1000, isPrivate: true);
      expect(result, '****');
    });

    test('format compact INR correctly', () {
      final result = CurrencyFormatter.format(1000, compact: true);
      expect(result, contains('₹'));
      expect(result, contains('1K'));
    });

    test('format decimal INR correctly', () {
      final result = CurrencyFormatter.format(1234567, compact: false);
      expect(result, contains('₹'));
      // en_IN uses different grouping
      expect(result, contains('12,34,567'));
    });

    test('setCurrency updates notifier and symbol', () async {
      await CurrencyFormatter.setCurrency('USD');
      expect(CurrencyFormatter.currencyNotifier.value, 'USD');
      expect(CurrencyFormatter.symbol, '\$');

      final result = CurrencyFormatter.format(1000, compact: false);
      expect(result, contains('\$'));
      expect(result, contains('1,000'));
    });

    test('setCurrency ignores invalid codes', () async {
      await CurrencyFormatter.setCurrency('INVALID');
      expect(CurrencyFormatter.currencyNotifier.value, 'INR');
    });
  });
}
