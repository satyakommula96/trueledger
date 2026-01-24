import 'package:flutter_test/flutter_test.dart';
import 'package:truecash/domain/models/models.dart';

void main() {
  group('MonthlySummary Domain Logic', () {
    test('calculate correctly when income and expenses are set', () {
      final summary = MonthlySummary(
        totalIncome: 100000,
        totalFixed: 20000,
        totalVariable: 10000,
        totalSubscriptions: 5000,
        totalInvestments: 20000,
      );

      expect(summary.net, 45000);
      expect(summary.savingsRate,
          65.0); // (100000 - (20000+10000+5000)) / 100000 * 100
      expect(summary.status, "PROSPEROUS");
    });

    test('calculate low savings rate', () {
      final summary = MonthlySummary(
        totalIncome: 100000,
        totalFixed: 50000,
        totalVariable: 40000,
        totalSubscriptions: 5000,
        totalInvestments: 0,
      );

      expect(summary.net, 5000);
      expect(summary.status, "TIGHT");
    });

    test('calculate negative net worth (liabilities > assets)', () {
      final summary = MonthlySummary(
        totalIncome: 0,
        totalFixed: 0,
        totalVariable: 0,
        totalSubscriptions: 0,
        totalInvestments: 100000,
        creditCardDebt: 50000,
        loansTotal: 100000,
        netWorth: -50000,
      );

      expect(summary.netWorth, -50000);
    });
  });
}
