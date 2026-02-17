import 'forecasting_models.dart';
import 'cash_runway_models.dart';

abstract class CashRunwayEngine {
  CashRunwayResult calculate({
    required Money currentBalance,
    required List<ForecastPoint> projections,
    required DateTime referenceDate,
  });
}
