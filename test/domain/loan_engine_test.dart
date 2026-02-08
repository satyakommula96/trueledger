import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/domain/logic/loan_engine.dart';

void main() {
  group('LoanEngine deterministic math', () {
    test('calculateInterest: Tier 1 Daily Accrual (Standard)', () {
      // 100,000 at 12% for 30 days
      // (100000 * 0.12 / 365) * 30 = 986.301... -> 986.30
      final interest = LoanEngine.calculateInterest(
        balance: 100000,
        annualRate: 12.0,
        days: 30,
      );
      expect(interest, 986.30);
    });

    test('calculateInterest: Large balance precision', () {
      final interest = LoanEngine.calculateInterest(
        balance: 1469950.0,
        annualRate: 20.99,
        days: 30,
      );
      // (1469950 * 0.2099 / 365) * 30 = 25359.657... -> 25359.66
      expect(interest, 25359.66);
    });
  });

  group('LoanEngine payment processing (Phase 7)', () {
    test('processPayment: Interest first, then principal', () {
      final result = LoanEngine.processPayment(
        openingBalance: 100000,
        annualRate: 12.0,
        paymentAmount: 5000.0,
        daysSinceLastPayment: 30,
      );

      expect(result.interestAccrued, 986.30);
      expect(result.principalApplied, 5000.0 - 986.30); // 4013.70
      expect(result.closingBalance, 100000 - 4013.70); // 95986.30
    });

    test('processPayment: Partial payment (less than interest)', () {
      // Negative Amortization scenario
      final result = LoanEngine.processPayment(
        openingBalance: 100000,
        annualRate: 12.0,
        paymentAmount: 500.0, // Less than the 986.30 interest
        daysSinceLastPayment: 30,
      );

      expect(result.interestAccrued, 986.30);
      expect(result.principalApplied, -486.30); // Negative principal
      expect(result.closingBalance, 100486.30); // Balance increases
    });

    test('processPayment: Zero days (Multiple payments same day)', () {
      final result = LoanEngine.processPayment(
        openingBalance: 100000,
        annualRate: 12.0,
        paymentAmount: 2000.0,
        daysSinceLastPayment: 0,
      );

      expect(result.interestAccrued, 0.0);
      expect(result.principalApplied, 2000.0);
      expect(result.closingBalance, 98000.0);
    });
  });

  group('LoanEngine Invariants (Phase 5)', () {
    test('validateInvariants: rejects negative EMI', () {
      final error = LoanEngine.validateInvariants(
        totalLoan: 100000,
        remainingBalance: 50000,
        emi: -100,
        rate: 10,
      );
      expect(error, contains("cannot be negative"));
    });

    test('validateInvariants: rejects balance > total', () {
      final error = LoanEngine.validateInvariants(
        totalLoan: 100000,
        remainingBalance: 150000,
        emi: 5000,
        rate: 10,
      );
      expect(error, contains("cannot exceed total loan"));
    });

    test('validateInvariants: accepts valid state', () {
      final error = LoanEngine.validateInvariants(
        totalLoan: 100000,
        remainingBalance: 90000,
        emi: 5000,
        rate: 12,
      );
      expect(error, isNull);
    });
  });
}
