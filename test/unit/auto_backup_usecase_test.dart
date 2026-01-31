import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/domain/usecases/auto_backup_usecase.dart';
import 'package:trueledger/domain/usecases/usecase_base.dart';
import 'package:flutter/services.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  late AutoBackupUseCase useCase;
  late MockFinancialRepository mockRepository;
  late Directory tempDir;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    mockRepository = MockFinancialRepository();
    useCase = AutoBackupUseCase(mockRepository);
    tempDir = await Directory.systemTemp.createTemp('auto_backup_test');

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
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('AutoBackupUseCase', () {
    test('should generate backup and save to file successfully', () async {
      // Arrange
      final Map<String, dynamic> backupData = {'test': 'data'};
      when(() => mockRepository.generateBackup())
          .thenAnswer((_) async => backupData);

      // Act
      final result = await useCase.call(NoParams());

      // Assert
      expect(result.isSuccess, isTrue);
      final backupDir = Directory('${tempDir.path}/backups');
      expect(await backupDir.exists(), isTrue);
      final files = backupDir.listSync();
      expect(files.length, 1);
      expect(files.first is File, isTrue);

      final content = await (files.first as File).readAsString();
      expect(content, contains('encrypted'));
      expect(content, contains('data'));
      expect(content, contains('"auto_backup":true'));
    });

    test('should keep only last 7 backups plus the new one', () async {
      // Arrange
      final backupDir = Directory('${tempDir.path}/backups');
      await backupDir.create(recursive: true);

      // Create 10 dummy files with different timestamps
      for (int i = 0; i < 10; i++) {
        final file = File('${backupDir.path}/old_backup_$i.json');
        await file.writeAsString('test');
        // We need to ensure they have different timestamps for sorting
        // On some systems, modification time might not have enough resolution if created too fast
        await Future.delayed(const Duration(milliseconds: 10));
      }

      when(() => mockRepository.generateBackup())
          .thenAnswer((_) async => {'foo': 'bar'});

      // Act
      final result = await useCase.call(NoParams());

      // Assert
      expect(result.isSuccess, isTrue);
      final files = backupDir.listSync().whereType<File>().toList();
      // Logic: if files.length > 7, it deletes from index 7 (leaving 0,1,2,3,4,5,6 -> 7 files).
      // Then it writes the new one. So total 8.
      expect(files.length, 8);
    });

    test('should return failure when repository throws exception', () async {
      // Arrange
      when(() => mockRepository.generateBackup())
          .thenThrow(Exception('Database Error'));

      // Act
      final result = await useCase.call(NoParams());

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failureOrThrow.message, contains('Database Error'));
    });
  });
}
