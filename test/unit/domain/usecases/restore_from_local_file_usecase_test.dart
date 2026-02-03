import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/domain/usecases/restore_from_local_file_usecase.dart';
import 'package:trueledger/domain/usecases/restore_backup_usecase.dart';
import 'package:trueledger/core/services/backup_encryption_service.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/data/datasources/database.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

class MockRestoreBackupUseCase extends Mock implements RestoreBackupUseCase {}

void main() {
  late RestoreFromLocalFileUseCase useCase;
  late MockFinancialRepository mockRepository;
  late MockRestoreBackupUseCase mockRestoreBackupUseCase;
  late Directory tempDir;

  setUp(() async {
    mockRepository = MockFinancialRepository();
    mockRestoreBackupUseCase = MockRestoreBackupUseCase();
    useCase =
        RestoreFromLocalFileUseCase(mockRepository, mockRestoreBackupUseCase);
    tempDir = await Directory.systemTemp.createTemp('restore_test');

    registerFallbackValue(RestoreBackupParams(backupData: {}));
  });

  tearDown(() async {
    await AppDatabase.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('returns failure if file does not exist', () async {
    final result = await useCase
        .call(RestoreFromLocalFileParams(path: 'non_existent.json'));
    expect(result.isFailure, isTrue);
    expect(result.failureOrThrow.message, contains('not found'));
  });

  test('restores successfully from encrypted file using device key', () async {
    // Arrange
    final backupData = {'entries': [], 'budgets': []};
    final deviceKey =
        'dummy_test_key_integration_mode_123'; // matches AppDatabase._isTest
    final encryptedData =
        BackupEncryptionService.encryptData(jsonEncode(backupData), deviceKey);
    final container = {
      'encrypted': true,
      'data': encryptedData,
    };

    final file = File('${tempDir.path}/backup.json');
    await file.writeAsString(jsonEncode(container));

    when(() => mockRestoreBackupUseCase.call(any()))
        .thenAnswer((_) async => const Success(null));

    // Act
    final result =
        await useCase.call(RestoreFromLocalFileParams(path: file.path));

    // Assert
    expect(result.isSuccess, isTrue);
    verify(() => mockRestoreBackupUseCase
        .call(any(that: isA<RestoreBackupParams>()))).called(1);
  });

  test('restores successfully from encrypted file using manual password',
      () async {
    // Arrange
    final backupData = {'entries': [], 'budgets': []};
    final manualPassword = 'my_secret_password';
    final encryptedData = BackupEncryptionService.encryptData(
        jsonEncode(backupData), manualPassword);
    final container = {
      'encrypted': true,
      'data': encryptedData,
    };

    final file = File('${tempDir.path}/backup_manual.json');
    await file.writeAsString(jsonEncode(container));

    when(() => mockRestoreBackupUseCase.call(any()))
        .thenAnswer((_) async => const Success(null));

    // Act
    final result = await useCase.call(RestoreFromLocalFileParams(
      path: file.path,
      password: manualPassword,
    ));

    // Assert
    expect(result.isSuccess, isTrue);
  });

  test('restores successfully from unencrypted file', () async {
    // Arrange
    final backupData = {'entries': [], 'budgets': [], 'encrypted': false};

    final file = File('${tempDir.path}/backup_raw.json');
    await file.writeAsString(jsonEncode(backupData));

    when(() => mockRestoreBackupUseCase.call(any()))
        .thenAnswer((_) async => const Success(null));

    // Act
    final result =
        await useCase.call(RestoreFromLocalFileParams(path: file.path));

    // Assert
    expect(result.isSuccess, isTrue);
  });

  test('returns failure on decryption error', () async {
    // Arrange
    final container = {
      'encrypted': true,
      'data': 'invalid_encrypted_data',
    };

    final file = File('${tempDir.path}/backup_fail.json');
    await file.writeAsString(jsonEncode(container));

    // Act
    final result =
        await useCase.call(RestoreFromLocalFileParams(path: file.path));

    // Assert
    expect(result.isFailure, isTrue);
    expect(result.failureOrThrow.message, contains('Decryption required'));
  });
}
