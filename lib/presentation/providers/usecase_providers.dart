import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truecash/domain/usecases/add_transaction_usecase.dart';
import 'package:truecash/domain/usecases/get_monthly_summary_usecase.dart';
import 'package:truecash/domain/usecases/get_dashboard_data_usecase.dart';
import 'package:truecash/domain/usecases/get_analysis_data_usecase.dart';
import 'package:truecash/domain/usecases/startup_usecase.dart';
import 'package:truecash/domain/usecases/budget_usecases.dart';
import 'repository_providers.dart';

final addTransactionUseCaseProvider = Provider<AddTransactionUseCase>((ref) {
  return AddTransactionUseCase(ref.watch(financialRepositoryProvider));
});

final getMonthlySummaryUseCaseProvider =
    Provider<GetMonthlySummaryUseCase>((ref) {
  return GetMonthlySummaryUseCase(ref.watch(financialRepositoryProvider));
});

final startupUseCaseProvider = Provider<StartupUseCase>((ref) {
  return StartupUseCase(ref.watch(financialRepositoryProvider));
});

final getDashboardDataUseCaseProvider =
    Provider<GetDashboardDataUseCase>((ref) {
  return GetDashboardDataUseCase(ref.watch(financialRepositoryProvider));
});

final updateBudgetUseCaseProvider = Provider<UpdateBudgetUseCase>((ref) {
  return UpdateBudgetUseCase(ref.watch(financialRepositoryProvider));
});

final deleteBudgetUseCaseProvider = Provider<DeleteBudgetUseCase>((ref) {
  return DeleteBudgetUseCase(ref.watch(financialRepositoryProvider));
});

final getAnalysisDataUseCaseProvider = Provider<GetAnalysisDataUseCase>((ref) {
  return GetAnalysisDataUseCase(ref.watch(financialRepositoryProvider));
});
