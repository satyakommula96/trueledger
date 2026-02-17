import 'forecasting_models.dart';

/// A deterministic domain service for financial forecasting.
/// This interface is stateless and free of infrastructure dependencies.
abstract class ForecastingEngine {
  ForecastResult forecastCashFlow({
    required CashFlowHistory history,
    required ForecastHorizon horizon,
    required DateTime referenceDate,
    ForecastScenario? scenario,
  });
}
