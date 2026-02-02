import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/domain/usecases/add_transaction_usecase.dart';
import 'package:trueledger/domain/usecases/get_monthly_summary_usecase.dart';
import 'package:trueledger/domain/usecases/get_dashboard_data_usecase.dart';
import 'package:trueledger/domain/usecases/get_analysis_data_usecase.dart';
import 'package:trueledger/domain/usecases/startup_usecase.dart';
import 'package:trueledger/domain/usecases/budget_usecases.dart';
import 'package:trueledger/domain/usecases/auto_backup_usecase.dart';
import 'package:trueledger/domain/usecases/restore_backup_usecase.dart';
import 'package:trueledger/domain/usecases/get_weekly_reflection_usecase.dart';
import 'notification_provider.dart';
import 'repository_providers.dart';

final addTransactionUseCaseProvider = Provider<AddTransactionUseCase>((ref) {
  return AddTransactionUseCase(ref.watch(financialRepositoryProvider));
});

final getMonthlySummaryUseCaseProvider =
    Provider<GetMonthlySummaryUseCase>((ref) {
  return GetMonthlySummaryUseCase(ref.watch(financialRepositoryProvider));
});

final startupUseCaseProvider = Provider<StartupUseCase>((ref) {
  return StartupUseCase(
    ref.watch(financialRepositoryProvider),
    ref.watch(autoBackupUseCaseProvider),
  );
});

final getDashboardDataUseCaseProvider =
    Provider<GetDashboardDataUseCase>((ref) {
  return GetDashboardDataUseCase(ref.watch(financialRepositoryProvider));
});

final getWeeklyReflectionUseCaseProvider =
    Provider<GetWeeklyReflectionUseCase>((ref) {
  return GetWeeklyReflectionUseCase(ref.watch(financialRepositoryProvider));
});

final updateBudgetUseCaseProvider = Provider<UpdateBudgetUseCase>((ref) {
  return UpdateBudgetUseCase(ref.watch(financialRepositoryProvider));
});

final addBudgetUseCaseProvider = Provider<AddBudgetUseCase>((ref) {
  return AddBudgetUseCase(ref.watch(financialRepositoryProvider));
});

final deleteBudgetUseCaseProvider = Provider<DeleteBudgetUseCase>((ref) {
  return DeleteBudgetUseCase(ref.watch(financialRepositoryProvider));
});

final getAnalysisDataUseCaseProvider = Provider<GetAnalysisDataUseCase>((ref) {
  return GetAnalysisDataUseCase(ref.watch(financialRepositoryProvider));
});

final autoBackupUseCaseProvider = Provider<AutoBackupUseCase>((ref) {
  return AutoBackupUseCase(
    ref.watch(financialRepositoryProvider),
    ref.watch(notificationServiceProvider),
  );
});

final restoreBackupUseCaseProvider = Provider<RestoreBackupUseCase>((ref) {
  return RestoreBackupUseCase(
    ref.watch(financialRepositoryProvider),
    ref.watch(autoBackupUseCaseProvider),
  );
});
