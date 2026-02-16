import 'forecasting_models.dart';
import 'cash_runway_models.dart';
import 'cash_runway_engine.dart';

class DeterministicCashRunwayEngine implements CashRunwayEngine {
  @override
  CashRunwayResult calculate({
    required Money currentBalance,
    required List<ForecastPoint> projections,
    required DateTime referenceDate,
  }) {
    // Step 1: Immediate Check
    if (currentBalance.isZeroOrNegative) {
      return CashRunwayResult(
        isSustainable: false,
        monthsUntilDepletion: 0,
        depletionDate: referenceDate,
        endingBalanceAfterProjection: currentBalance,
      );
    }

    // Step 2: Iterate Projections
    Money balance = currentBalance;

    for (int i = 0; i < projections.length; i++) {
      balance = balance + Money(projections[i].projectedNet);

      if (balance.isZeroOrNegative) {
        return CashRunwayResult(
          isSustainable: false,
          monthsUntilDepletion: i + 1,
          depletionDate: projections[i].month.toDateTime(),
          endingBalanceAfterProjection: balance,
        );
      }
    }

    // Loop finished and balance > 0
    // Option A — Horizon-bound runway: Return sustainable if not depleted within projections.
    return CashRunwayResult(
      isSustainable: true,
      monthsUntilDepletion: null,
      depletionDate: null,
      endingBalanceAfterProjection: balance,
    );
  }
}
