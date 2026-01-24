import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyHelper {
  static final ValueNotifier<String> currencyNotifier = ValueNotifier('INR');

  static const Map<String, String> currencies = {
    'INR': '₹',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
  };

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    currencyNotifier.value = prefs.getString('currency') ?? 'INR';
  }

  static Future<void> setCurrency(String code) async {
    if (!currencies.containsKey(code)) return;
    currencyNotifier.value = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', code);
  }

  static String get symbol => currencies[currencyNotifier.value] ?? '₹';

  static String format(num value, {bool compact = true}) {
    final sym = symbol;
    final locale = currencyNotifier.value == 'INR' ? 'en_IN' : 'en_US';

    if (compact) {
      return "$sym${NumberFormat.compact(locale: locale).format(value)}";
    }
    return "$sym${NumberFormat.decimalPattern(locale).format(value)}";
  }
}
