import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/domain/forecasting/cash_runway_models.dart';
import 'package:trueledger/domain/usecases/usecase_base.dart';
import 'usecase_providers.dart';

final runwayProvider = FutureProvider<CashRunwayResult>((ref) async {
  final getCashRunway = ref.watch(getCashRunwayUseCaseProvider);
  final result = await getCashRunway(NoParams());

  if (result.isSuccess) {
    return result.getOrThrow;
  } else {
    throw Exception(result.failureOrThrow.message);
  }
});
