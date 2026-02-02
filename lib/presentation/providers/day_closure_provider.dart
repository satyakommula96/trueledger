import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';

final dayClosureProvider = NotifierProvider<DayClosureNotifier, bool>(() {
  return DayClosureNotifier();
});

class DayClosureNotifier extends Notifier<bool> {
  static const String _key = 'last_closed_day';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final lastClosed = prefs.getString(_key);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return lastClosed == today;
  }

  Future<void> closeDay() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString(_key, today);
    state = true;
  }
}
