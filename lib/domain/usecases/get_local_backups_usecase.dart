import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/core/error/failure.dart';
import 'package:trueledger/core/config/app_config.dart';
import 'usecase_base.dart';

class BackupFile {
  final String path;
  final String name;
  final DateTime date;
  final int size;

  BackupFile({
    required this.path,
    required this.name,
    required this.date,
    required this.size,
  });
}

class GetLocalBackupsUseCase extends UseCase<List<BackupFile>, NoParams> {
  @override
  Future<Result<List<BackupFile>>> call(NoParams params) async {
    if (kIsWeb) return const Success([]);
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir =
          Directory('${directory.path}/${AppConfig.backupFolderName}');
      if (!await backupDir.exists()) {
        return const Success([]);
      }

      final files = backupDir.listSync().whereType<File>().toList();
      final backupFiles = files.map((f) {
        final stat = f.statSync();
        return BackupFile(
          path: f.path,
          name: f.uri.pathSegments.last,
          date: stat.modified,
          size: stat.size,
        );
      }).toList();

      // Sort by date descending
      backupFiles.sort((a, b) => b.date.compareTo(a.date));

      return Success(backupFiles);
    } catch (e) {
      return Failure(DatabaseFailure("Failed to list backups: $e"));
    }
  }
}
