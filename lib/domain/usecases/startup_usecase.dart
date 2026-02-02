import 'package:flutter/foundation.dart';
import 'package:trueledger/core/error/failure.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/data/datasources/database.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'usecase_base.dart';

import 'package:trueledger/domain/usecases/auto_backup_usecase.dart';

class StartupResult {
  final bool shouldScheduleReminder;
  final bool shouldCancelReminder;

  StartupResult({
    this.shouldScheduleReminder = false,
    this.shouldCancelReminder = false,
  });
}

class StartupUseCase extends UseCase<StartupResult, NoParams> {
  final IFinancialRepository repository;
  final AutoBackupUseCase autoBackup;

  StartupUseCase(this.repository, this.autoBackup);

  @override
  Future<Result<StartupResult>> call(NoParams params) async {
    try {
      // 1. Initialize Database (including migrations)
      await AppDatabase.db;

      // 1b. Auto Backup (Non-blocking)
      autoBackup.call(const NoParams()).catchError((e) {
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

      return Success(StartupResult(
        shouldScheduleReminder: shouldScheduleReminder,
        shouldCancelReminder: shouldCancelReminder,
      ));
    } catch (e) {
      if (e is AppFailure) return Failure(e);
      return Failure(
          UnexpectedFailure("Critical startup failure: ${e.toString()}"));
    }
  }
}
