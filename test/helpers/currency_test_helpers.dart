import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';

/// Helper to find text by formatted amount
Finder findAmount(String value) =>
    find.text('${CurrencyFormatter.symbol}$value');

/// Helper to find text by raw double amount
Finder findFormattedAmount(double amount) {
  final formatted = CurrencyFormatter.format(amount);
  return find.text(formatted);
}
