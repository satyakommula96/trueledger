import 'dart:convert';
import 'dart:io';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/core/error/failure.dart';
import 'package:trueledger/data/datasources/database.dart';
import 'package:trueledger/core/services/backup_encryption_service.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'usecase_base.dart';
import 'restore_backup_usecase.dart';

class RestoreFromLocalFileParams {
  final String path;
  final String? password; // Optional manual password

  RestoreFromLocalFileParams({required this.path, this.password});
}

class RestoreFromLocalFileUseCase
    extends UseCase<void, RestoreFromLocalFileParams> {
  final IFinancialRepository repository;
  final RestoreBackupUseCase restoreBackupUseCase;

  RestoreFromLocalFileUseCase(this.repository, this.restoreBackupUseCase);

  @override
  Future<Result<void>> call(RestoreFromLocalFileParams params) async {
    try {
      final file = File(params.path);
      if (!await file.exists()) {
        return Failure(DatabaseFailure("Backup file not found."));
      }

      final content = await file.readAsString();
      final container = jsonDecode(content) as Map<String, dynamic>;

      Map<String, dynamic> backupData;

      if (container['encrypted'] == true) {
        // Try device key first
        try {
          final deviceKey = await AppDatabase.getEncryptionKey();
          final decryptedJson =
              BackupEncryptionService.decryptData(container['data'], deviceKey);
          backupData = jsonDecode(decryptedJson) as Map<String, dynamic>;
        } catch (e) {
          // If device key fails and password provided, try that
          if (params.password != null) {
            final decryptedJson = BackupEncryptionService.decryptData(
                container['data'], params.password!);
            backupData = jsonDecode(decryptedJson) as Map<String, dynamic>;
          } else {
            return Failure(DatabaseFailure("Decryption required."));
          }
        }
      } else {
        backupData = container;
      }

      // Now call the existing restore use case
      return await restoreBackupUseCase.call(RestoreBackupParams(
        backupData: backupData,
      ));
    } catch (e) {
      return Failure(DatabaseFailure("Failed to restore from file: $e"));
    }
  }
}
