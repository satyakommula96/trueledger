import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/domain/services/intelligence_service.dart';
import 'package:trueledger/domain/models/models.dart';

void main() {
  late IntelligenceService service;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    service = IntelligenceService(prefs);
  });

  group('IntelligenceService.generateInsights', () {
    test('should generate wealth projection when net income is positive', () {
      final summary = MonthlySummary(
        totalIncome: 1000,
        totalFixed: 200,
        totalVariable: 300,
        totalSubscriptions: 50,
        totalInvestments: 0,
        netWorth: 1000,
      );

      final insights = service.generateInsights(
        summary: summary,
        trendData: [],
        budgets: [],
        categorySpending: [],
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
        totalIncome: 150, // Matches current expenses to avoid wealth projection
        totalFixed: 50,
        totalVariable: 50,
        totalSubscriptions: 50,
        totalInvestments: 0,
        netWorth: 0,
      );

      final insights = service.generateInsights(
        summary: summary,
        trendData: trendData,
        budgets: [],
        categorySpending: [],
      );

      // Current total = 150. Forecast 300 > 150 * 1.15
      expect(insights.any((i) => i.title == 'SPENDING SURGE DETECTED'), isTrue);
    });

    test('should generate critical overspending when expenses > income', () {
      final summary = MonthlySummary(
        totalIncome: 1000,
        totalFixed: 500,
        totalVariable: 500,
        totalSubscriptions: 100, // total outflow = 1100
        totalInvestments: 0,
        netWorth: 0,
      );

      final insights = service.generateInsights(
        summary: summary,
        trendData: [],
        budgets: [],
        categorySpending: [],
      );

      expect(insights.any((i) => i.title == 'CRITICAL OVERSPENDING'), isTrue);
    });

    test('should generate neutral patterns when no insights found', () {
      final summary = MonthlySummary(
        totalIncome: 0,
        totalFixed: 0,
        totalVariable: 0,
        totalSubscriptions: 0,
        totalInvestments: 0,
        netWorth: 0,
      );

      final insights = service.generateInsights(
        summary: summary,
        trendData: [],
        budgets: [],
        categorySpending: [],
      );

      expect(insights, isEmpty);
    });

    test('should respect cooldown and filter insights', () {
      final summary = MonthlySummary(
        totalIncome: 10000,
        totalFixed: 1000,
        totalVariable: 1000,
        totalSubscriptions: 0,
        totalInvestments: 0,
        netWorth: 1000,
      );

      // Generate first time - should have wealth projection
      final insights1 = service.generateInsights(
        summary: summary,
        trendData: [],
        budgets: [],
        categorySpending: [],
      );
      expect(insights1.any((i) => i.id == 'wealth_projection'), isTrue);

      final insights2 = service.generateInsights(
        summary: summary,
        trendData: [],
        budgets: [],
        categorySpending: [],
        forceRefresh: true,
      );
      expect(insights2.any((i) => i.id == 'wealth_projection'), isFalse);
    });

    test('should apply group-level cooldown (Trend)', () {
      final summary = MonthlySummary(
        totalIncome: 200, // Very low income
        totalFixed: 100,
        totalVariable: 100,
        totalSubscriptions: 0,
        totalInvestments: 0,
        netWorth: 0,
      );
      final budgets = [
        Budget(id: 1, category: 'Food', monthlyLimit: 50, spent: 100),
      ];
      // Savings milestone is also a Trend, but budget discipline is usually higher priority or first

      final insights1 = service.generateInsights(
        summary: summary,
        trendData: [],
        budgets: budgets,
        categorySpending: [],
      );

      // Should show at least one trend (budget overflow)
      expect(insights1.any((i) => i.group == InsightGroup.trend), isTrue);

      // Generate again - should be blocked by group cooldown
      final insights2 = service.generateInsights(
        summary: summary,
        trendData: [],
        budgets: budgets,
        categorySpending: [],
        forceRefresh: true,
      );
      expect(insights2.any((i) => i.group == InsightGroup.trend), isFalse);
    });

    test('should cache insights and not recompute on same day', () {
      final summary = MonthlySummary(
        totalIncome: 10000,
        totalFixed: 1000,
        totalVariable: 1000,
        totalSubscriptions: 0,
        totalInvestments: 0,
        netWorth: 1000,
      );

      // 1. Generate first time
      final insights1 = service.generateInsights(
        summary: summary,
        trendData: [],
        budgets: [],
        categorySpending: [],
      );

      // 2. Change data - if cached, it should still return insights1
      final emptySummary = MonthlySummary(
        totalIncome: 0,
        totalFixed: 0,
        totalVariable: 0,
        totalSubscriptions: 0,
        totalInvestments: 0,
        netWorth: 0,
      );

      final insights2 = service.generateInsights(
        summary: emptySummary,
        trendData: [],
        budgets: [],
        categorySpending: [],
      );

      expect(insights2.first.id, equals(insights1.first.id));
      expect(insights2.first.id, equals('wealth_projection'));
    });

    test('should only show ONE high priority insight if any exist', () {
      final summary = MonthlySummary(
        totalIncome: 1000,
        totalFixed: 600,
        totalVariable: 500,
        totalSubscriptions: 100, // total outflow = 1200 (Critical!)
        totalInvestments: 0,
        netWorth: 1000, // Also satisfies Wealth Projection (High)
      );

      final insights = service.generateInsights(
        summary: summary,
        trendData: [],
        budgets: [],
        categorySpending: [],
      );

      // Even if multiple high priority are valid, we only show one to stay calm
      expect(insights.length, 1);
      expect(insights.first.priority, InsightPriority.high);
    });

    test('should show max two medium/low priority insights', () {
      final summary = MonthlySummary(
        totalIncome: 1000,
        totalFixed: 100,
        totalVariable: 100,
        totalSubscriptions: 0,
        totalInvestments: 0,
        netWorth: 0,
      );
      // Validating multiple low/medium triggers:
      // 1. Savings Milestone (Low)
      // 2. Budget Discipline (Medium) - if we add one
      // 3. Subscription Leakage (Low) - if we adjust income

      final budgets = [
        Budget(id: 1, category: 'A', monthlyLimit: 50, spent: 100),
        Budget(id: 2, category: 'B', monthlyLimit: 50, spent: 100),
      ];

      final insights = service.generateInsights(
        summary: summary,
        trendData: [],
        budgets: budgets,
        categorySpending: [],
      );

      // Should be capped at 2
      expect(insights.length, lessThanOrEqualTo(2));
      if (insights.any((i) => i.priority == InsightPriority.high)) {
        expect(insights.length, 1);
      } else {
        expect(insights.length, 2);
      }
    });

    test('should generate STABLE LIFESTYLE insight when budgets are stable',
        () {
      final summary = MonthlySummary(
        totalIncome: 0,
        totalFixed: 0,
        totalVariable: 0,
        totalSubscriptions: 0,
        totalInvestments: 0,
        netWorth: 0,
      );
      final budgets = [
        Budget(
            id: 1, category: 'A', monthlyLimit: 100, spent: 50, isStable: true),
        Budget(
            id: 2, category: 'B', monthlyLimit: 100, spent: 50, isStable: true),
      ];

      final insights = service.generateInsights(
        summary: summary,
        trendData: [],
        budgets: budgets,
        categorySpending: [],
        requestedSurface: InsightSurface.details, // Low priority shows here
      );

      expect(insights.any((i) => i.id == 'stable_lifestyle'), isTrue);
    });
  });

  group('IntelligenceService.calculateHealthScore', () {
    test('New user (no data) should have 50', () {
      final summary = MonthlySummary(
        totalIncome: 0,
        totalFixed: 0,
        totalVariable: 0,
        totalSubscriptions: 0,
        totalInvestments: 0,
        netWorth: 0,
      );
      expect(
          IntelligenceService.calculateHealthScore(
              summary: summary, budgets: []),
          50);
    });

    test('Perfect profile: 100', () {
      final summary = MonthlySummary(
        totalIncome: 100000,
        totalFixed: 10000,
        totalVariable: 10000,
        totalSubscriptions: 0,
        totalInvestments: 1000000,
        netWorth: 1000000, // Assets cover 3mo exp easily
      );
      final score = IntelligenceService.calculateHealthScore(
          summary: summary, budgets: []);
      expect(score, 100);
    });

    test('Negative savings rate and extreme debt burden', () {
      final summary = MonthlySummary(
        totalIncome: 10000,
        totalFixed: 10000,
        totalVariable: 5000,
        totalSubscriptions: 0,
        totalInvestments: 0,
        netWorth: -50000,
        creditCardDebt: 50000, // 5% = 2500
        totalMonthlyEMI: 5000, // DTI = (5000+2500)/10000 = 75%
      );
      final score = IntelligenceService.calculateHealthScore(
          summary: summary, budgets: []);
      // Savings: -5000/10000 = -0.5. Penalty 20*0.5 = 10. score = -10
      // Debt: DTI 75% -> score += -10. score = -20
      // Solvency: Assets=0, Liab=50k -> score += 0. score = -20
      // Budget: no budgets -> score += 10. score = -10
      // Solvency Penalty: netWorth < 0 -> score -= 20. score = -30
      // Total clamped to 0.
      expect(score, 0);
    });

    test('Mid-range profile with budget discipline', () {
      final summary = MonthlySummary(
        totalIncome: 50000,
        totalFixed: 10000,
        totalVariable: 20000,
        totalSubscriptions: 5000, // Surplus 15000 (30%)
        totalInvestments: 20000,
        netWorth: 20000,
        loansTotal: 10000, // Asset/Liab ratio = 20k/10k = 2.0
        totalMonthlyEMI: 2000, // DTI = 2000/50000 = 4%
      );
      final budgets = [
        Budget(id: 1, category: 'Food', monthlyLimit: 5000, spent: 4000),
      ];
      final score = IntelligenceService.calculateHealthScore(
          summary: summary, budgets: budgets);

      // Savings: 30% -> 25 + (0.1/0.3)*15 = 25 + 5 = 30
      // Debt: DTI 4% -> 25
      // Solvency: Ratio 3.0 (Assets=20k+10k=30k, Liab=10k) -> 15
      // Budget: 100% health -> 15
      // Liquidity: Exp = 35k. Assets = 30k. No bonus.
      // Total: 30 + 25 + 15 + 15 = 85
      expect(score, equals(85));
    });

    test('Low solvency and overspent budgets', () {
      final summary = MonthlySummary(
        totalIncome: 50000,
        totalFixed: 20000,
        totalVariable: 20000,
        totalSubscriptions: 5000, // Surplus 5000 (10%)
        totalInvestments: 0,
        netWorth: 5000,
        loansTotal: 20000, // Asset/Liab = 25k/20k = 1.25
      );
      final budgets = [
        Budget(id: 1, category: 'Food', monthlyLimit: 5000, spent: 6000),
      ];
      final score = IntelligenceService.calculateHealthScore(
          summary: summary, budgets: budgets);
      // Savings: 10% -> (0.1/0.2)*25 = 12.5
      // Debt: DTI 0% -> 30
      // Solvency: Ratio 1.25 -> 5
      // Budget: 0% health -> 0
      // Total: 12.5 + 30 + 5 = 47.5 -> 47
      expect(score, equals(47));
    });

    test('Underwater solvency (Net Worth < 0)', () {
      final summary = MonthlySummary(
        totalIncome: 10000,
        totalFixed: 1000,
        totalVariable: 1000,
        totalSubscriptions: 1000,
        totalInvestments: 0,
        netWorth: -50000,
        loansTotal: 50000,
        totalMonthlyEMI: 0,
      );
      final score = IntelligenceService.calculateHealthScore(
          summary: summary, budgets: []);
      // Savings: 70% -> 40
      // Debt: DTI 0% -> 30
      // Solvency: Assets=0, Liab=50k -> 0
      // Budget: 10
      // Penalty: -20
      // Total: 40 + 30 + 10 - 20 = 60
      // Actually Assets = netWorth + liab = -50k + 50k = 0.
      expect(score, equals(60));
    });
  });
}
