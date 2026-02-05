import 'package:flutter/foundation.dart';
import 'package:trueledger/core/error/failure.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/data/datasources/database.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'usecase_base.dart';
import 'package:trueledger/domain/usecases/auto_backup_usecase.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:trueledger/core/config/app_config.dart';
import 'package:trueledger/domain/models/models.dart';

class StartupResult {
  final bool shouldScheduleReminder;
  final bool shouldCancelReminder;
  final List<BillSummary> billsDueToday;

  StartupResult({
    this.shouldScheduleReminder = false,
    this.shouldCancelReminder = false,
    this.billsDueToday = const [],
  });
}

// NOTE: StartupUseCase is intentionally capped.
// Do not add more behavioral logic here.
class StartupUseCase extends UseCase<StartupResult, NoParams> {
  final IFinancialRepository repository;
  final AutoBackupUseCase autoBackup;

  StartupUseCase(this.repository, this.autoBackup);

  @override
  Future<Result<StartupResult>> call(NoParams params,
      {VoidCallback? onBackupSuccess}) async {
    try {
      // 0. Migrate old backup folder if it exists
      await _migrateBackupFolder();

      // 1. Initialize Database (including migrations)
      await AppDatabase.db;

      // 1b. Auto Backup (Non-blocking)
      autoBackup
          .call(const NoParams(), onSuccess: onBackupSuccess)
          .catchError((e) {
        debugPrint("CRITICAL: Auto-backup failed during startup: $e");
        return Failure<void>(
            DatabaseFailure("Auto-backup failed silently: ${e.toString()}"));
      });

      bool shouldScheduleReminder = false;
      bool shouldCancelReminder = false;

      // 2. Logic for daily reminder intent
      final todaySpend = await repository.getTodaySpend();
      if (todaySpend == 0) {
        shouldScheduleReminder = true;
      } else {
        shouldCancelReminder = true;
      }

      // 3. Load Currency Preference
      await CurrencyFormatter.load();

      // 4. Check for recurring transactions
      await repository.checkAndProcessRecurring();

      // 5. Daily Bill Digest Logic
      List<BillSummary> billsDueToday = [];
      final upcomingBills = await repository.getUpcomingBills();
      final now = DateTime.now();

      billsDueToday = BillSummary.filterDueEntries(upcomingBills, now);

      return Success(StartupResult(
        shouldScheduleReminder: shouldScheduleReminder,
        shouldCancelReminder: shouldCancelReminder,
        billsDueToday: billsDueToday,
      ));
    } catch (e) {
      if (e is AppFailure) return Failure(e);
      return Failure(
          UnexpectedFailure("Critical startup failure: ${e.toString()}"));
    }
  }

  Future<void> _migrateBackupFolder() async {
    if (kIsWeb) return;
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final oldDir = Directory('${docsDir.path}/backups');
      final newDir = Directory('${docsDir.path}/${AppConfig.backupFolderName}');

      if (await oldDir.exists()) {
        if (!await newDir.exists()) {
          await newDir.create(recursive: true);
        }

        final files = oldDir.listSync().whereType<File>();
        for (final file in files) {
          final fileName = path.basename(file.path);
          final newFile = File(path.join(newDir.path, fileName));

          if (!await newFile.exists()) {
            try {
              await file.rename(newFile.path);
            } catch (e) {
              // Copy and delete as fallback for rename failure
              await file.copy(newFile.path);
              await file.delete();
            }
          } else {
            // If it already exists in both places, just delete the old one
            await file.delete();
          }
        }

        // Try to delete old directory if empty
        if (oldDir.listSync().isEmpty) {
          await oldDir.delete();
        }
      }
    } catch (e) {
      debugPrint('Backup folder migration failed: $e');
    }
  }
}
