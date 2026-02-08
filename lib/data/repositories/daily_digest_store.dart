import 'package:shared_preferences/shared_preferences.dart';

/// Scoped persistence for Daily Bill Digest state to avoid global key collisions.
class DailyDigestStore {
  final SharedPreferences _prefs;

  static const String _keyLastDate = 'last_bill_digest_date';
  static const String _keyLastCount = 'last_bill_digest_count';
  static const String _keyLastTotal = 'last_bill_digest_total';

  DailyDigestStore(this._prefs);

  String? getLastDigestDate() => _prefs.getString(_keyLastDate);
  int? getLastDigestCount() => _prefs.getInt(_keyLastCount);
  double? getLastDigestTotal() {
    final value = _prefs.get(_keyLastTotal);
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return null;
  }

  Future<void> saveState({
    required String date,
    required int count,
    required double total,
  }) async {
    await _prefs.setString(_keyLastDate, date);
    await _prefs.setInt(_keyLastCount, count);
    await _prefs.setDouble(_keyLastTotal, total);
  }
}
