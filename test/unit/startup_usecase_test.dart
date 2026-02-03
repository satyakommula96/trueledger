import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/domain/usecases/auto_backup_usecase.dart';
import 'package:trueledger/domain/usecases/startup_usecase.dart';
import 'package:trueledger/domain/usecases/usecase_base.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/core/error/failure.dart';
import 'package:trueledger/data/datasources/database.dart';

import 'package:flutter/services.dart';
import 'dart:io';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

class MockAutoBackupUseCase extends Mock implements AutoBackupUseCase {}

void main() {
  late StartupUseCase useCase;
  late MockFinancialRepository mockRepository;
  late MockAutoBackupUseCase mockAutoBackupUseCase;

  late Directory tempDir;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(NoParams());
  });

  setUp(() async {
    mockRepository = MockFinancialRepository();
    mockAutoBackupUseCase = MockAutoBackupUseCase();
    useCase = StartupUseCase(mockRepository, mockAutoBackupUseCase);
    tempDir = await Directory.systemTemp.createTemp('startup_test');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (message) async {
        if (message.method == 'getApplicationDocumentsDirectory') {
          return tempDir.path;
        }
        return null;
      },
    );

    when(() => mockRepository.getTodaySpend()).thenAnswer((_) async => 0);
    when(() => mockRepository.clearData()).thenAnswer((_) async {});
    when(() => mockRepository.checkAndProcessRecurring())
        .thenAnswer((_) async {});
    when(() => mockAutoBackupUseCase.call(any(),
            onSuccess: any(named: 'onSuccess')))
        .thenAnswer((_) async => const Success(null));
  });

  tearDown(() async {
    await AppDatabase.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('StartupUseCase', () {
    test('should return Failure when checkAndProcessRecurring throws',
        () async {
      // Arrange - Mock the repository method that the use case calls
      when(() => mockRepository.checkAndProcessRecurring())
          .thenThrow(Exception('Recurring check failed'));

      // Act
      final result = await useCase.call(NoParams());

      // Assert - Should fail because of the exception
      expect(result.isFailure, isTrue);
      expect(result.failureOrThrow, isA<UnexpectedFailure>());
    });

    test('should migrate old backups folder to new one', () async {
      // Arrange
      final oldDir = Directory('${tempDir.path}/backups');
      await oldDir.create(recursive: true);
      final testFile = File('${oldDir.path}/test_backup.json');
      await testFile.writeAsString('{}');

      // Act
      await useCase.call(NoParams());

      // Assert
      final newDir = Directory('${tempDir.path}/TrueLedgerSafeVault');
      expect(await newDir.exists(), isTrue);
      expect(await File('${newDir.path}/test_backup.json').exists(), isTrue);
      expect(await oldDir.exists(), isFalse);
    });
  });
}
