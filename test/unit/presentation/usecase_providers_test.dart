import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/core/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/domain/usecases/add_transaction_usecase.dart';
import 'package:trueledger/domain/usecases/get_monthly_summary_usecase.dart';
import 'package:trueledger/domain/usecases/get_dashboard_data_usecase.dart';
import 'package:trueledger/domain/usecases/get_analysis_data_usecase.dart';
import 'package:trueledger/domain/usecases/startup_usecase.dart';
import 'package:trueledger/domain/usecases/budget_usecases.dart';
import 'package:trueledger/domain/usecases/auto_backup_usecase.dart';
import 'package:trueledger/domain/usecases/restore_backup_usecase.dart';
import 'package:trueledger/domain/usecases/get_weekly_reflection_usecase.dart';
import 'package:trueledger/domain/usecases/get_local_backups_usecase.dart';
import 'package:trueledger/domain/usecases/restore_from_local_file_usecase.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

class MockNotificationService extends Mock implements NotificationService {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('UseCase Providers', () {
    late MockFinancialRepository mockRepo;
    late MockNotificationService mockNotification;
    late MockSharedPreferences mockPrefs;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockFinancialRepository();
      mockNotification = MockNotificationService();
      mockPrefs = MockSharedPreferences();

      container = ProviderContainer(
        overrides: [
          financialRepositoryProvider.overrideWithValue(mockRepo),
          notificationServiceProvider.overrideWithValue(mockNotification),
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('addTransactionUseCaseProvider returns AddTransactionUseCase', () {
      final useCase = container.read(addTransactionUseCaseProvider);
      expect(useCase, isA<AddTransactionUseCase>());
      expect(useCase.repository, mockRepo);
    });

    test('getMonthlySummaryUseCaseProvider returns GetMonthlySummaryUseCase',
        () {
      final useCase = container.read(getMonthlySummaryUseCaseProvider);
      expect(useCase, isA<GetMonthlySummaryUseCase>());
      expect(useCase.repository, mockRepo);
    });

    test('startupUseCaseProvider returns StartupUseCase', () {
      final useCase = container.read(startupUseCaseProvider);
      expect(useCase, isA<StartupUseCase>());
      expect(useCase.repository, mockRepo);
    });

    test('updateBudgetUseCaseProvider returns UpdateBudgetUseCase', () {
      final useCase = container.read(updateBudgetUseCaseProvider);
      expect(useCase, isA<UpdateBudgetUseCase>());
      expect(useCase.repository, mockRepo);
    });

    test('addBudgetUseCaseProvider returns AddBudgetUseCase', () {
      final useCase = container.read(addBudgetUseCaseProvider);
      expect(useCase, isA<AddBudgetUseCase>());
      expect(useCase.repository, mockRepo);
    });

    test('deleteBudgetUseCaseProvider returns DeleteBudgetUseCase', () {
      final useCase = container.read(deleteBudgetUseCaseProvider);
      expect(useCase, isA<DeleteBudgetUseCase>());
      expect(useCase.repository, mockRepo);
    });

    test(
        'markBudgetAsReviewedUseCaseProvider returns MarkBudgetAsReviewedUseCase',
        () {
      final useCase = container.read(markBudgetAsReviewedUseCaseProvider);
      expect(useCase, isA<MarkBudgetAsReviewedUseCase>());
      expect(useCase.repository, mockRepo);
    });

    test('autoBackupUseCaseProvider returns AutoBackupUseCase', () {
      final useCase = container.read(autoBackupUseCaseProvider);
      expect(useCase, isA<AutoBackupUseCase>());
      expect(useCase.repository, mockRepo);
    });

    test('getDashboardDataUseCaseProvider returns GetDashboardDataUseCase', () {
      final useCase = container.read(getDashboardDataUseCaseProvider);
      expect(useCase, isA<GetDashboardDataUseCase>());
      expect(useCase.repository, mockRepo);
    });

    test(
        'getWeeklyReflectionUseCaseProvider returns GetWeeklyReflectionUseCase',
        () {
      final useCase = container.read(getWeeklyReflectionUseCaseProvider);
      expect(useCase, isA<GetWeeklyReflectionUseCase>());
      expect(useCase.repository, mockRepo);
    });

    test('getAnalysisDataUseCaseProvider returns GetAnalysisDataUseCase', () {
      final useCase = container.read(getAnalysisDataUseCaseProvider);
      expect(useCase, isA<GetAnalysisDataUseCase>());
      expect(useCase.repository, mockRepo);
    });

    test('restoreBackupUseCaseProvider returns RestoreBackupUseCase', () {
      final useCase = container.read(restoreBackupUseCaseProvider);
      expect(useCase, isA<RestoreBackupUseCase>());
      expect(useCase.repository, mockRepo);
    });

    test('getLocalBackupsUseCaseProvider returns GetLocalBackupsUseCase', () {
      final useCase = container.read(getLocalBackupsUseCaseProvider);
      expect(useCase, isA<GetLocalBackupsUseCase>());
    });

    test(
        'restoreFromLocalFileUseCaseProvider returns RestoreFromLocalFileUseCase',
        () {
      final useCase = container.read(restoreFromLocalFileUseCaseProvider);
      expect(useCase, isA<RestoreFromLocalFileUseCase>());
      expect(useCase.repository, mockRepo);
    });
  });
}
