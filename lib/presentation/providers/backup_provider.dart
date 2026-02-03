import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:intl/intl.dart';

class LastBackupTimeNotifier extends Notifier<String> {
  @override
  String build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getString('last_backup_time') ?? 'Never';
  }

  Future<void> updateLastBackupTime() async {
    final now = DateTime.now();
    final formattedDate = DateFormat('MMM dd, yyyy HH:mm').format(now);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('last_backup_time', formattedDate);
    state = formattedDate;
  }
}

final lastBackupTimeProvider =
    NotifierProvider<LastBackupTimeNotifier, String>(() {
  return LastBackupTimeNotifier();
});
