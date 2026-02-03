import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:intl/intl.dart';
import 'package:trueledger/domain/usecases/get_local_backups_usecase.dart';
import 'package:trueledger/domain/usecases/usecase_base.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';

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

final localBackupsProvider =
    FutureProvider.autoDispose<List<BackupFile>>((ref) async {
  final useCase = ref.watch(getLocalBackupsUseCaseProvider);
  final result = await useCase(NoParams());
  if (result.isSuccess) {
    return result.getOrThrow;
  } else {
    throw Exception(result.failureOrThrow.message);
  }
});
