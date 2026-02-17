import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/domain/forecasting/forecasting.dart';

final forecastingEngineProvider = Provider<ForecastingEngine>((ref) {
  return LinearRegressionForecastEngine();
});

final cashRunwayEngineProvider = Provider<CashRunwayEngine>((ref) {
  return DeterministicCashRunwayEngine();
});
