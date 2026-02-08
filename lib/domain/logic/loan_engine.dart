class LoanEngine {
  /// Tier 1: Daily Accrual Reducing Balance Engine
  /// This class handles the math and logic for loan calculations to ensure
  /// deterministic results and ease of testing.

  static double calculateInterest({
    required double balance,
    required double annualRate,
    required int days,
    int engineVersion = 1,
  }) {
    if (engineVersion == 1) {
      final dailyRate = (annualRate / 100) / 365;
      final interest = balance * dailyRate * days;
      // Round to 2 decimal places for financial accuracy
      return (interest * 100).roundToDouble() / 100;
    }
    return 0.0;
  }

  static LoanPaymentResult processPayment({
    required double openingBalance,
    required double annualRate,
    required double paymentAmount,
    required int daysSinceLastPayment,
    int engineVersion = 1,
  }) {
    final interestAccrued = calculateInterest(
      balance: openingBalance,
      annualRate: annualRate,
      days: daysSinceLastPayment,
      engineVersion: engineVersion,
    );

    // Apply payment in order:
    // 1. Accrued Interest
    // 2. Principal

    final pApplied =
        ((paymentAmount - interestAccrued) * 100).roundToDouble() / 100;
    final cBalance = ((openingBalance - pApplied) * 100).roundToDouble() / 100;

    return LoanPaymentResult(
      openingBalance: openingBalance,
      interestAccrued: interestAccrued,
      principalApplied: pApplied,
      closingBalance: cBalance,
      daysAccrued: daysSinceLastPayment,
      engineVersion: engineVersion,
    );
  }

  /// Invariants Check
  static String? validateInvariants({
    required double totalLoan,
    required double remainingBalance,
    required double emi,
    required double rate,
  }) {
    if (emi < 0) return "EMI amount cannot be negative.";
    if (rate < 0 || rate > 100) {
      return "Interest rate must be between 0% and 100%.";
    }
    if (remainingBalance > totalLoan) {
      return "Remaining balance cannot exceed total loan.";
    }
    return null;
  }
}

class LoanPaymentResult {
  final double openingBalance;
  final double interestAccrued;
  final double principalApplied;
  final double closingBalance;
  final int daysAccrued;
  final int engineVersion;

  LoanPaymentResult({
    required this.openingBalance,
    required this.interestAccrued,
    required this.principalApplied,
    required this.closingBalance,
    required this.daysAccrued,
    required this.engineVersion,
  });
}
