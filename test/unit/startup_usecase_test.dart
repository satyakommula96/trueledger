import 'package:intl/intl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late StartupUseCase useCase;
  late MockFinancialRepository mockRepository;
  late MockAutoBackupUseCase mockAutoBackupUseCase;
  late MockSharedPreferences mockPrefs;

  late Directory tempDir;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    registerFallbackValue(NoParams());
  });

  setUp(() async {
    mockRepository = MockFinancialRepository();
    mockAutoBackupUseCase = MockAutoBackupUseCase();
    mockPrefs = MockSharedPreferences();
    useCase = StartupUseCase(mockRepository, mockAutoBackupUseCase, mockPrefs);
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

    // Default setup for digest (empty)
    when(() => mockRepository.getTodaySpend()).thenAnswer((_) async => 0);
    when(() => mockRepository.checkAndProcessRecurring())
        .thenAnswer((_) async {});
    when(() => mockRepository.getUpcomingBills()).thenAnswer((_) async => []);
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.setInt(any(), any())).thenAnswer((_) async => true);
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

    test('should identify bills due today', () async {
      // Arrange
      final now = DateTime.now();
      final bills = [
        {
          'id': 1,
          'name': 'Rent',
          'amount': 20000,
          'due': now.toIso8601String(),
          'type': 'BILL'
        },
        {
          'id': 2,
          'name': 'Netflix',
          'amount': 199,
          'due': now.toIso8601String(),
          'type': 'SUBSCRIPTION'
        },
      ];
      when(() => mockRepository.getUpcomingBills())
          .thenAnswer((_) async => bills);
      when(() => mockPrefs.getString('last_bill_digest_date')).thenReturn(null);

      // Act
      final result = await useCase.call(NoParams());

      // Assert
      expect(result.isSuccess, isTrue);
      final data = result.getOrThrow;
      expect(data.billsDueToday.length, 2);
      expect(data.billsDueToday.first.name, 'Rent');
      verify(() => mockPrefs.setString('last_bill_digest_date', any()))
          .called(1);
    });

    test('should deduplicate digest if already shown today', () async {
      // Arrange
      final now = DateTime.now();
      final bills = [
        {
          'id': 1,
          'name': 'Rent',
          'amount': 20000,
          'due': now.toIso8601String(),
          'type': 'BILL'
        },
      ];
      final todayStr = DateFormat('yyyy-MM-dd').format(now);

      when(() => mockRepository.getUpcomingBills())
          .thenAnswer((_) async => bills);
      when(() => mockPrefs.getString('last_bill_digest_date'))
          .thenReturn(todayStr);

      // Act
      final result = await useCase.call(NoParams());

      // Assert
      expect(result.isSuccess, isTrue);
      final data = result.getOrThrow;
      expect(data.billsDueToday, isEmpty);
      verifyNever(() => mockPrefs.setString('last_bill_digest_date', any()));
    });
  });
}
