import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:trueledger/core/services/backup_encryption_service.dart';

import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/screens/settings/settings.dart';
import 'package:trueledger/core/providers/version_provider.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/core/services/file_service.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/domain/usecases/auto_backup_usecase.dart';
import 'package:trueledger/domain/usecases/restore_backup_usecase.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';
import 'package:trueledger/domain/usecases/usecase_base.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockFilePicker extends Mock
    with MockPlatformInterfaceMixin
    implements FilePicker {}

class MockFileService extends Mock implements FileService {}

class MockRestoreBackupUseCase extends Mock implements RestoreBackupUseCase {}

class MockAutoBackupUseCase extends Mock implements AutoBackupUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FileType.any);
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(RestoreBackupParams(backupData: {}));
    registerFallbackValue(NoParams());
  });

  late MockFinancialRepository mockRepo;
  late MockSharedPreferences mockPrefs;
  late MockFilePicker mockFilePicker;
  late MockFileService mockFileService;
  late MockRestoreBackupUseCase mockRestoreUseCase;
  late MockAutoBackupUseCase mockAutoBackupUseCase;

  setUp(() {
    mockRepo = MockFinancialRepository();
    mockPrefs = MockSharedPreferences();
    mockFilePicker = MockFilePicker();
    mockFileService = MockFileService();
    mockRestoreUseCase = MockRestoreBackupUseCase();
    mockAutoBackupUseCase = MockAutoBackupUseCase();
    FilePicker.platform = mockFilePicker;

    // UseCase mocks
    when(() => mockRestoreUseCase.call(any()))
        .thenAnswer((_) async => const Success(null));
    when(() => mockAutoBackupUseCase.call(any()))
        .thenAnswer((_) async => const Success(null));

    // Repository mocks
    when(() => mockRepo.getAllValues(any())).thenAnswer((_) async => []);
    when(() => mockRepo.clearData()).thenAnswer((_) async => {});
    when(() => mockRepo.seedRoadmapData()).thenAnswer((_) async => {});
    when(() => mockRepo.restoreBackup(any())).thenAnswer((_) async => {});
    when(() => mockFileService.writeAsString(any(), any()))
        .thenAnswer((_) async => {});

    final emptySummary = MonthlySummary(
      totalIncome: 0,
      totalFixed: 0,
      totalVariable: 0,
      totalSubscriptions: 0,
      totalInvestments: 0,
    );
    when(() => mockRepo.getMonthlySummary())
        .thenAnswer((_) async => emptySummary);
    when(() => mockRepo.getCategorySpending()).thenAnswer((_) async => []);
    when(() => mockRepo.getBudgets()).thenAnswer((_) async => []);
    when(() => mockRepo.getSavingGoals()).thenAnswer((_) async => []);
    when(() => mockRepo.getSpendingTrend()).thenAnswer((_) async => []);
    when(() => mockRepo.getUpcomingBills()).thenAnswer((_) async => []);
    when(() => mockRepo.getLoans()).thenAnswer((_) async => []);
    when(() => mockRepo.getSubscriptions()).thenAnswer((_) async => []);
    when(() => mockRepo.getCreditCards()).thenAnswer((_) async => []);

    // Prefs mocks
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.getString('user_name')).thenReturn('Test User');
    when(() => mockPrefs.getString('theme_mode')).thenReturn('system');
    when(() => mockPrefs.getString('currency_symbol')).thenReturn('\$');
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);
    when(() => mockPrefs.getKeys()).thenReturn({});

    // Repository mocks
    when(() => mockRepo.generateBackup())
        .thenAnswer((_) async => <String, dynamic>{});
  });

  Widget createSettingsScreen() {
    return ProviderScope(
      overrides: [
        financialRepositoryProvider.overrideWithValue(mockRepo),
        appVersionProvider.overrideWith((ref) => '1.2.2'),
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        fileServiceProvider.overrideWithValue(mockFileService),
        restoreBackupUseCaseProvider.overrideWithValue(mockRestoreUseCase),
        autoBackupUseCaseProvider.overrideWithValue(mockAutoBackupUseCase),
      ],
      child: const MaterialApp(
        home: SettingsScreen(),
      ),
    );
  }

  group('SettingsScreen', () {
    testWidgets('covers backup encryption logic', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;

      when(() => mockFilePicker.saveFile(
            dialogTitle: any(named: 'dialogTitle'),
            fileName: any(named: 'fileName'),
            type: any(named: 'type'),
            allowedExtensions: any(named: 'allowedExtensions'),
          )).thenAnswer((_) async => '/tmp/test_backup.json');

      await tester.pumpWidget(createSettingsScreen());

      final backupTile = find.text('Secure Backup');
      await tester.scrollUntilVisible(backupTile, 100.0);
      await tester.tap(backupTile);
      await tester.pumpAndSettle();

      expect(find.text('Encrypt Backup'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'pass123');
      await tester.tap(find.text('CREATE BACKUP'));
      await tester.pumpAndSettle();

      verify(() => mockRepo.getAllValues(any())).called(greaterThan(0));
      tester.view.resetPhysicalSize();
    });

    testWidgets('covers reset application logic', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createSettingsScreen());

      final resetTile = find.text('Reset Application');
      await tester.scrollUntilVisible(resetTile, 100.0);
      await tester.tap(resetTile);
      await tester.pumpAndSettle();

      expect(find.text('Delete All Data?'), findsOneWidget);
      await tester.tap(find.text('DELETE ALL'));
      await tester.pumpAndSettle();

      verify(() => mockRepo.clearData()).called(1);
      tester.view.resetPhysicalSize();
    });

    testWidgets('covers name picker logic', (tester) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.tap(find.text('User Name'));
      await tester.pumpAndSettle();

      expect(find.text('Set User Name'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'New Name');
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();
    });

    testWidgets('covers theme picker logic', (tester) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();

      expect(find.text('Select Theme'), findsOneWidget);
      await tester.tap(find.text('Dark Mode'));
      await tester.pumpAndSettle();
    });

    testWidgets('covers seed data logic', (tester) async {
      await tester.pumpWidget(createSettingsScreen());
      final seedTile = find.text('Seed Sample Data');
      await tester.scrollUntilVisible(seedTile, 100);
      await tester.tap(seedTile);
      await tester.pumpAndSettle();

      expect(find.text('Select Data Scenario'), findsOneWidget);
      await tester.tap(find.text('Complete Demo'));
      await tester.pumpAndSettle();

      verify(() => mockRepo.seedRoadmapData()).called(1);
    });

    testWidgets('covers encrypted restore logic - success', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);

      final encryptedData = BackupEncryptionService.encryptData(
          jsonEncode({
            'vars': [],
            'income': [],
            'fixed': [],
            'invs': [],
            'subs': [],
            'cards': [],
            'loans': [],
            'goals': [],
            'budgets': [],
            'version': '1.0'
          }),
          'pass123');
      final container = jsonEncode({
        'encrypted': true,
        'data': encryptedData,
        'version': '2.0',
      });

      // Mock FileService reading
      when(() => mockFileService.readAsString(any()))
          .thenAnswer((_) async => container);

      when(() => mockFilePicker.pickFiles(type: any(named: 'type')))
          .thenAnswer((_) async => FilePickerResult([
                PlatformFile(
                  path: '/dummy/path/test_backup.json',
                  name: 'test_backup.json',
                  size: 100,
                )
              ]));

      await tester.pumpWidget(createSettingsScreen());
      final restoreTile = find.text('Restore Data');
      await tester.scrollUntilVisible(restoreTile, 100);
      await tester.tap(restoreTile);
      await tester.pumpAndSettle();

      expect(find.text('Decrypt Backup'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'pass123');
      await tester.tap(find.text('DECRYPT'));
      await tester.pumpAndSettle();

      expect(find.text('Restore & Overwrite?'), findsOneWidget);
      await tester.tap(find.text('RESTORE'));

      await tester.pumpAndSettle();

      verify(() => mockRestoreUseCase.call(any())).called(1);
      tester.view.resetPhysicalSize();
    });

    testWidgets('covers encrypted restore logic - wrong password',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      final container = jsonEncode({
        'encrypted': true,
        'data': 'bad-data',
        'version': '2.0',
      });

      // Mock FileService reading
      when(() => mockFileService.readAsString(any()))
          .thenAnswer((_) async => container);

      when(() => mockFilePicker.pickFiles(type: any(named: 'type')))
          .thenAnswer((_) async => FilePickerResult([
                PlatformFile(
                  path: '/dummy/path/test_bad_backup.json',
                  name: 'test_bad_backup.json',
                  size: 100,
                )
              ]));

      await tester.pumpWidget(createSettingsScreen());
      final restoreTile = find.text('Restore Data');
      await tester.scrollUntilVisible(restoreTile, 100);
      await tester.tap(restoreTile);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'wrongpass');
      await tester.tap(find.text('DECRYPT'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Invalid Password'), findsOneWidget);
      tester.view.resetPhysicalSize();
    });

    testWidgets('covers currency picker logic', (tester) async {
      await tester.pumpWidget(createSettingsScreen());
      final currencyTile = find.text('Currency');
      await tester.scrollUntilVisible(currencyTile, 100);
      await tester.tap(currencyTile);
      await tester.pumpAndSettle();

      expect(find.text('Select Currency'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'USD');
      await tester.pumpAndSettle();

      await tester.tap(find.descendant(
          of: find.byType(ListView), matching: find.text('USD')));
      await tester.pumpAndSettle();
    });

    // Pin setup test skipped due to inability to mock FlutterSecureStorage instance created inside the method
    // without further refactoring.
  });
}
