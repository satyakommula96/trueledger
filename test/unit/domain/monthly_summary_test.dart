import 'package:flutter_test/flutter_test.dart';
import 'package:truecash/domain/models/models.dart';

void main() {
  group('MonthlySummary Domain Entity', () {
    test('Calculates net income correctly (Income - Expenses)', () {
      final summary = MonthlySummary(
        totalIncome: 10000,
        totalFixed: 2000,
        totalVariable: 1500,
        totalSubscriptions: 500,
        totalInvestments: 1000,
      );

      // (10000) - (2000 + 1500 + 500 + 1000) = 10000 - 5000 = 5000
      expect(summary.net, 5000);
    });

    test('Calculates zero savings rate when income is 0', () {
      final summary = MonthlySummary(
        totalIncome: 0,
        totalFixed: 0,
        totalVariable: 0,
        totalSubscriptions: 0,
        totalInvestments: 0,
      );
      expect(summary.savingsRate, 0.0);
    });

    test('Calculates correct savings rate', () {
      final summary = MonthlySummary(
        totalIncome: 1000, // Income
        totalFixed: 200, // Expense
        totalVariable: 200, // Expense
        totalSubscriptions: 100, // Expense
        totalInvestments: 0,
        // Expenses = 500. Remaining = 500. Savings Rate = 50%
      );
      expect(summary.savingsRate, 50.0);
    });

    test('Status returns correct string based on net value', () {
      expect(
        MonthlySummary(
          totalIncome: 30000,
          totalFixed: 0,
          totalVariable: 0,
          totalSubscriptions: 0,
          totalInvestments: 0,
        ).status,
        'PROSPEROUS',
      );

      expect(
        MonthlySummary(
          totalIncome: 15000,
          totalFixed: 0,
          totalVariable: 0,
          totalSubscriptions: 0,
          totalInvestments: 0,
        ).status,
        'STABLE',
      );

      expect(
        MonthlySummary(
          totalIncome: 5000,
          totalFixed: 0,
          totalVariable: 0,
          totalSubscriptions: 0,
          totalInvestments: 0,
        ).status,
        'TIGHT',
      );

      expect(
        MonthlySummary(
          totalIncome: 100,
          totalFixed: 200,
          totalVariable: 0,
          totalSubscriptions: 0,
          totalInvestments: 0,
        ).status,
        'OVERSPENT',
      );
    });
  });
}
