import 'package:flutter/material.dart';
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

class MockFinancialRepository extends Mock implements IFinancialRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockFilePicker extends Mock
    with MockPlatformInterfaceMixin
    implements FilePicker {}

void main() {
  setUpAll(() {
    registerFallbackValue(FileType.any);
  });

  late MockFinancialRepository mockRepo;
  late MockSharedPreferences mockPrefs;
  late MockFilePicker mockFilePicker;

  setUp(() {
    mockRepo = MockFinancialRepository();
    mockPrefs = MockSharedPreferences();
    mockFilePicker = MockFilePicker();
    FilePicker.platform = mockFilePicker;

    // Repository mocks
    when(() => mockRepo.getAllValues(any())).thenAnswer((_) async => []);
    when(() => mockRepo.clearData()).thenAnswer((_) async => {});

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
    when(() => mockPrefs.getString('user_name')).thenReturn('Test User');
    when(() => mockPrefs.getString('theme_mode')).thenReturn('system');
    when(() => mockPrefs.getString('currency_symbol')).thenReturn('\$');
  });

  Widget createSettingsScreen() {
    return ProviderScope(
      overrides: [
        financialRepositoryProvider.overrideWithValue(mockRepo),
        appVersionProvider.overrideWith((ref) => '1.2.2'),
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
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

      final backupTile = find.text('Backup Data');
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
  });
}
