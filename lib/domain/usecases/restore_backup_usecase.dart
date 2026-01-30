import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/core/error/failure.dart';
import 'usecase_base.dart';
import 'auto_backup_usecase.dart';

class RestoreBackupParams {
  final Map<String, dynamic> backupData;
  final bool merge;

  RestoreBackupParams({required this.backupData, this.merge = false});
}

class RestoreBackupUseCase extends UseCase<void, RestoreBackupParams> {
  final IFinancialRepository repository;
  final AutoBackupUseCase autoBackupUseCase;

  RestoreBackupUseCase(this.repository, this.autoBackupUseCase);

  @override
  Future<Result<void>> call(RestoreBackupParams params) async {
    try {
      // 1. PERFORM AUTO-BACKUP FOR SAFETY
      // This ensures that even if something goes wrong during restore,
      // the user has a local file they can find to recover.
      await autoBackupUseCase.call(const NoParams());

      // 2. Clear current data (Restore is currently a full overwrite as merge is risky with relational IDs)
      // Note: If merge=true were implemented, we would need a more complex logic here.
      // For now, we strictly follow the 'REPLACE' logic but with advanced safety.
      await repository.clearData();

      // 3. Restore the data
      await repository.restoreBackup(params.backupData);

      return const Success(null);
    } catch (e) {
      return Failure(DatabaseFailure("Restore failed: $e"));
    }
  }
}
