import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/core/error/failure.dart';
import 'usecase_base.dart';

class AutoBackupUseCase extends UseCase<void, NoParams> {
  final IFinancialRepository repository;

  AutoBackupUseCase(this.repository);

  @override
  Future<Result<void>> call(NoParams params) async {
    try {
      final backupData = await repository.generateBackup();
      backupData['auto_backup'] = true;
      backupData['date'] = DateTime.now().toIso8601String();
      backupData['version'] = '1.0';

      final jsonString = jsonEncode(backupData);

      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      // Keep only last 7 days of auto-backups (rollover)
      final files = backupDir.listSync().whereType<File>().toList();
      files
          .sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      if (files.length > 7) {
        for (var i = 7; i < files.length; i++) {
          await files[i].delete();
        }
      }

      final fileName =
          'autobackup_${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}.json';
      final file = File('${backupDir.path}/$fileName');
      await file.writeAsString(jsonString);

      return const Success(null);
    } catch (e) {
      return Failure(DatabaseFailure("Auto-backup failed: $e"));
    }
  }
}
