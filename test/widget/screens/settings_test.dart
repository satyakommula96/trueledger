import 'package:flutter/material.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

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
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const SettingsScreen(),
      ),
    );
  }

  group('SettingsScreen', () {
    testWidgets('covers reset application logic', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createSettingsScreen());

      final resetTile = find.text('RESET APPLICATION');
      await tester.scrollUntilVisible(resetTile, 100.0);
      await tester.tap(resetTile);
      await tester.pumpAndSettle();

      expect(find.text('DELETE ALL DATA?'), findsOneWidget);
      await tester.tap(find.text('DELETE ALL'));
      await tester.pumpAndSettle();

      verify(() => mockRepo.clearData()).called(1);
      tester.view.resetPhysicalSize();
    });

    testWidgets('covers name picker logic', (tester) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.tap(find.text('USER NAME'));
      await tester.pumpAndSettle();

      expect(find.text('SET USER NAME'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'New Name');
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();
    });

    testWidgets('covers theme picker logic', (tester) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.tap(find.text('APPEARANCE'));
      await tester.pumpAndSettle();

      expect(find.text('SELECT THEME'), findsOneWidget);
      await tester.tap(find.text('DARK MODE'));
      await tester.pumpAndSettle();
    });

    testWidgets('covers seed data logic', (tester) async {
      await tester.pumpWidget(createSettingsScreen());
      final seedTile = find.text('SEED SAMPLE DATA');
      await tester.scrollUntilVisible(seedTile, 100);
      await tester.tap(seedTile);
      await tester.pumpAndSettle();

      expect(find.text('SELECT DATA SCENARIO'), findsOneWidget);
      await tester.tap(find.text('COMPLETE DEMO'));
      await tester.pumpAndSettle();

      verify(() => mockRepo.seedRoadmapData()).called(1);
    });

    testWidgets('covers currency picker logic', (tester) async {
      await tester.pumpWidget(createSettingsScreen());
      final currencyTile = find.text('CURRENCY');
      await tester.scrollUntilVisible(currencyTile, 100);
      await tester.tap(currencyTile);
      await tester.pumpAndSettle();

      expect(find.text('SELECT CURRENCY'), findsOneWidget);
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
