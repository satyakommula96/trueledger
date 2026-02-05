import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/domain/usecases/get_dashboard_data_usecase.dart';
import 'package:trueledger/domain/usecases/usecase_base.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';

// Re-exporting DashboardData to avoid breaking UI references if they imported it from here
export 'package:trueledger/domain/usecases/get_dashboard_data_usecase.dart'
    show DashboardData;

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final getDashboardData = ref.watch(getDashboardDataUseCaseProvider);
  final result = await getDashboardData(NoParams());

  if (result.isSuccess) {
    return result.getOrThrow;
  } else {
    throw Exception(result.failureOrThrow.message);
  }
});

final paidLabelsProvider =
    FutureProvider.family<List<String>, String>((ref, monthStr) async {
  final repo = ref.watch(financialRepositoryProvider);
  return repo.getPaidBillLabels(monthStr);
});
