import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/presentation/screens/settings/trust_center.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/presentation/providers/backup_provider.dart';
import 'package:trueledger/domain/usecases/get_local_backups_usecase.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';
import 'package:trueledger/domain/usecases/restore_from_local_file_usecase.dart';
import 'package:trueledger/core/utils/result.dart';

class MockRestoreFromLocalFileUseCase extends Mock
    implements RestoreFromLocalFileUseCase {}

class MockLastBackupTimeNotifier extends Notifier<String>
    with Mock
    implements LastBackupTimeNotifier {
  @override
  String build() => 'Never';
}

class MockFinancialRepository extends Mock implements IFinancialRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockFinancialRepository mockRepo;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockRepo = MockFinancialRepository();
    mockPrefs = MockSharedPreferences();
    registerFallbackValue(RestoreFromLocalFileParams(path: ''));
  });

  testWidgets('TrustCenterScreen renders stats correctly',
      (WidgetTester tester) async {
    final stats = {
      'variable': 10,
      'fixed': 5,
      'income': 2,
      'budgets': 3,
      'total_records': 20,
    };

    when(() => mockRepo.getDatabaseStats()).thenAnswer((_) async => stats);
    when(() => mockPrefs.getString(any())).thenReturn(null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          financialRepositoryProvider.overrideWithValue(mockRepo),
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          databaseStatsProvider.overrideWith((ref) async => stats),
          localBackupsProvider.overrideWith((ref) => []),
          lastBackupTimeProvider
              .overrideWith(() => MockLastBackupTimeNotifier()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const TrustCenterScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("TRUST CENTER"), findsOneWidget);
    expect(find.text("DATA HEALTH"), findsOneWidget);
    expect(find.text("TOTAL RECORDS"), findsOneWidget);
    expect(find.text("20"), findsOneWidget);
    expect(find.text("OUR GUARANTEES"), findsOneWidget);
    expect(find.text("STRICT POLICIES"), findsOneWidget);
  });

  testWidgets('TrustCenterScreen renders backups and shows restore dialog',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final mockRestoreUseCase = MockRestoreFromLocalFileUseCase();
    final stats = {
      'total_records': 0,
      'variable': 0,
      'income': 0,
      'budgets': 0
    };
    final backups = [
      BackupFile(
        path: '/path/backup.json',
        name: 'backup.json',
        date: DateTime.now(),
        size: 1024,
      ),
    ];

    when(() => mockRepo.getDatabaseStats()).thenAnswer((_) async => stats);
    when(() => mockRestoreUseCase.call(any()))
        .thenAnswer((_) async => const Success(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          financialRepositoryProvider.overrideWithValue(mockRepo),
          databaseStatsProvider.overrideWith((ref) async => stats),
          localBackupsProvider.overrideWith((ref) => backups),
          lastBackupTimeProvider
              .overrideWith(() => MockLastBackupTimeNotifier()),
          restoreFromLocalFileUseCaseProvider
              .overrideWithValue(mockRestoreUseCase),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const TrustCenterScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Check if backup is rendered
    expect(find.text("LOCAL BACKUPS"), findsOneWidget);
    expect(find.byIcon(Icons.inventory_2_rounded), findsOneWidget);

    // Tap Restore icon
    final restoreButton = find.byIcon(Icons.settings_backup_restore_rounded);
    await tester.ensureVisible(restoreButton);
    await tester.tap(restoreButton);
    await tester.pumpAndSettle();

    // Verify dialog
    expect(find.text("RESTORE DATA?"), findsOneWidget);
    expect(find.text("RESTORE NOW"), findsOneWidget);

    // Tap Restore
    await tester.tap(find.text("RESTORE NOW"));
    await tester.pump(); // Start restore logic

    verify(() => mockRestoreUseCase.call(any())).called(1);
  });
}
