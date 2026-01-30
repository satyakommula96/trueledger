import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/core/error/failure.dart';
import 'package:trueledger/data/datasources/database.dart';
import 'package:trueledger/core/services/backup_encryption_service.dart';
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

      // ENCRYPT using the device-specific database key
      final key = await AppDatabase.getEncryptionKey();
      final encryptedData =
          BackupEncryptionService.encryptData(jsonString, key);

      // Standard container format
      final container = {
        'version': '2.0',
        'encrypted': true,
        'data': encryptedData,
        'date': DateTime.now().toIso8601String(),
        'auto_backup': true,
      };

      final finalOutput = jsonEncode(container);

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

      final now = DateTime.now();
      final fileName =
          'autobackup_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
          '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.json';
      final file = File('${backupDir.path}/$fileName');
      await file.writeAsString(finalOutput);

      return const Success(null);
    } catch (e) {
      return Failure(DatabaseFailure("Auto-backup failed: $e"));
    }
  }
}
