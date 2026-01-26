
import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/domain/models/monthly_summary.dart';

void main() {
  group('MonthlySummary', () {
    test('should create with all required fields', () {
      final summary = MonthlySummary(
        totalIncome: 100000,
        totalFixed: 20000,
        totalVariable: 30000,
        totalSubscriptions: 5000,
        totalInvestments: 10000,
        netWorth: 500000,
        creditCardDebt: 25000,
        loansTotal: 200000,
        totalMonthlyEMI: 15000,
      );

      expect(summary.totalIncome, 100000);
      expect(summary.totalFixed, 20000);
      expect(summary.totalVariable, 30000);
      expect(summary.totalSubscriptions, 5000);
      expect(summary.totalInvestments, 10000);
      expect(summary.netWorth, 500000);
      expect(summary.creditCardDebt, 25000);
      expect(summary.loansTotal, 200000);
      expect(summary.totalMonthlyEMI, 15000);
    });

    test('should calculate total expenses correctly', () {
      final summary = MonthlySummary(
        totalIncome: 100000,
        totalFixed: 20000,
        totalVariable: 30000,
        totalSubscriptions: 5000,
        totalInvestments: 10000,
        netWorth: 500000,
        creditCardDebt: 0,
        loansTotal: 0,
        totalMonthlyEMI: 0,
      );

      // Total expenses = fixed + variable + subscriptions
      final totalExpenses = summary.totalFixed + summary.totalVariable + summary.totalSubscriptions;
      expect(totalExpenses, 55000);
    });

    test('should handle zero values', () {
      final summary = MonthlySummary(
        totalIncome: 0,
        totalFixed: 0,
        totalVariable: 0,
        totalSubscriptions: 0,
        totalInvestments: 0,
        netWorth: 0,
        creditCardDebt: 0,
        loansTotal: 0,
        totalMonthlyEMI: 0,
      );

      expect(summary.totalIncome, 0);
      expect(summary.netWorth, 0);
    });

    test('should handle negative net worth', () {
      final summary = MonthlySummary(
        totalIncome: 50000,
        totalFixed: 20000,
        totalVariable: 30000,
        totalSubscriptions: 5000,
        totalInvestments: 0,
        netWorth: -100000,
        creditCardDebt: 50000,
        loansTotal: 200000,
        totalMonthlyEMI: 10000,
      );

      expect(summary.netWorth, -100000);
    });
  });
}
