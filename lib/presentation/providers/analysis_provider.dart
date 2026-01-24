import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truecash/domain/usecases/get_analysis_data_usecase.dart';
import 'package:truecash/domain/usecases/usecase_base.dart';
import 'usecase_providers.dart';

final analysisProvider = FutureProvider<AnalysisData>((ref) async {
  final getAnalysisData = ref.watch(getAnalysisDataUseCaseProvider);
  final result = await getAnalysisData(NoParams());

  if (result.isSuccess) {
    return result.getOrThrow;
  } else {
    throw Exception(result.failureOrThrow.message);
  }
});
