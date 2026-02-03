import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/core/error/failure.dart';
import 'package:trueledger/data/datasources/database.dart';
import 'package:trueledger/core/services/backup_encryption_service.dart';
import 'package:trueledger/core/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:trueledger/core/config/app_config.dart';
import 'usecase_base.dart';

class AutoBackupUseCase extends UseCase<void, NoParams> {
  final IFinancialRepository repository;
  final NotificationService? notificationService;
  final SharedPreferences? sharedPreferences;

  AutoBackupUseCase(this.repository,
      [this.notificationService, this.sharedPreferences]);

  @override
  Future<Result<void>> call(NoParams params, {VoidCallback? onSuccess}) async {
    if (kIsWeb) return const Success(null);
    try {
      notificationService?.showNotification(
        id: 999,
        title: "Auto Backup Started",
        body: "Securing your latest financial data...",
      );

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
      final backupDir =
          Directory('${directory.path}/${AppConfig.backupFolderName}');
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

      notificationService?.showNotification(
        id: 999,
        title: "Auto Backup Completed",
        body: "Your data is safely encrypted and stored locally.",
      );

      if (sharedPreferences != null) {
        await sharedPreferences!.setString('backup.last_success_at',
            DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now()));
      }

      onSuccess?.call();

      return const Success(null);
    } catch (e) {
      notificationService?.showNotification(
        id: 999,
        title: "Auto Backup Failed",
        body: "Could not secure your data. Please check storage.",
      );
      return Failure(DatabaseFailure("Auto-backup failed: $e"));
    }
  }
}
