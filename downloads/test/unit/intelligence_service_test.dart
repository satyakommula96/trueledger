import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/domain/services/intelligence_service.dart';
import 'package:trueledger/domain/models/models.dart';

void main() {
  group('IntelligenceService.generateInsights', () {
    test('should generate wealth projection when net income is positive', () {
      final summary = MonthlySummary(
        totalIncome: 1000,
        totalFixed: 200,
        totalVariable: 300,
        totalSubscriptions: 50,
        totalInvestments: 0,
        netWorth: 1000,
        creditCardDebt: 0,
        loansTotal: 0,
        totalMonthlyEMI: 0,
      );

      final insights = IntelligenceService.generateInsights(
        summary: summary,
        trendData: [],
        budgets: [],
      );

      expect(insights.any((i) => i.title == 'WEALTH PROJECTION'), isTrue);
      // 1000 - (200+300+50) = 450. 450 * 12 = 5400
      expect(
          insights
              .firstWhere((i) => i.title == 'WEALTH PROJECTION')
              .currencyValue,
          5400);
    });

    test('should generate spending surge detected when forecast is high', () {
      final trendData = [
        {'month': '2025-11', 'total': 100.0},
        {'month': '2025-12', 'total': 200.0},
      ];
      final summary = MonthlySummary(
        totalIncome: 1000,
        totalFixed: 50,
        totalVariable: 50,
        totalSubscriptions: 50,
        totalInvestments: 0,
        netWorth: 0,
        creditCardDebt: 0,
        loansTotal: 0,
        totalMonthlyEMI: 0,
      );

      final insights = IntelligenceService.generateInsights(
        summary: summary,
        trendData: trendData,
        budgets: [],
      );

      // Values: 100, 200. Slope = 100. Next = 300.
      // Current total = 150. Forecast 300 > 150 * 1.2
      expect(insights.any((i) => i.title == 'SPENDING SURGE DETECTED'), isTrue);
    });

    test('should generate high savings efficiency when rate > 30%', () {
      final summary = MonthlySummary(
        totalIncome: 10000,
        totalFixed: 1000,
        totalVariable: 1000,
        totalSubscriptions: 1000,
        totalInvestments: 0,
        netWorth: 0,
        creditCardDebt: 0,
        loansTotal: 0,
        totalMonthlyEMI: 0,
      );

      final insights = IntelligenceService.generateInsights(
        summary: summary,
        trendData: [],
        budgets: [],
      );

      expect(insights.any((i) => i.title == 'HIGH SAVINGS EFFICIENCY'), isTrue);
    });

    test('should generate subscription overload when > 10% of income', () {
      final summary = MonthlySummary(
        totalIncome: 1000,
        totalFixed: 100,
        totalVariable: 100,
        totalSubscriptions: 150, // 15%
        totalInvestments: 0,
        netWorth: 0,
        creditCardDebt: 0,
        loansTotal: 0,
        totalMonthlyEMI: 0,
      );

      final insights = IntelligenceService.generateInsights(
        summary: summary,
        trendData: [],
        budgets: [],
      );

      expect(insights.any((i) => i.title == 'SUBSCRIPTION OVERLOAD'), isTrue);
    });
  });

  group('IntelligenceService.calculateHealthScore', () {
    test('should return 0 for new user with no data', () {
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
      expect(
          IntelligenceService.calculateHealthScore(
              summary: summary, budgets: []),
          0);
    });

    test('should give 100 for perfect financial profile', () {
      final summary = MonthlySummary(
        totalIncome: 100000,
        totalFixed: 10000,
        totalVariable: 10000,
        totalSubscriptions: 5000, // Savings rate: 75%
        totalInvestments: 1000000,
        netWorth: 500000,
        creditCardDebt: 0,
        loansTotal: 0,
        totalMonthlyEMI: 0,
      );
      final budgets = [
        Budget(id: 1, category: 'Food', monthlyLimit: 5000, spent: 4000),
      ];

      final score = IntelligenceService.calculateHealthScore(
          summary: summary, budgets: budgets);
      expect(score, greaterThanOrEqualTo(90));
    });

    test('should penalize for negative net worth', () {
      final summary = MonthlySummary(
        totalIncome: 10000,
        totalFixed: 1000,
        totalVariable: 1000,
        totalSubscriptions: 1000,
        totalInvestments: 0,
        netWorth: -50000, // Insolvency
        creditCardDebt: 10000,
        loansTotal: 100000,
        totalMonthlyEMI: 5000,
      );

      final score = IntelligenceService.calculateHealthScore(
          summary: summary, budgets: []);
      expect(score, lessThanOrEqualTo(40));
    });
  });
}
