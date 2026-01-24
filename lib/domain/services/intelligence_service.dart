import 'package:truecash/domain/models/models.dart';
import 'package:truecash/core/utils/currency_helper.dart';

class AIInsight {
  final String title;
  final String body;
  final InsightType type;
  final String value;
  final double confidence;

  AIInsight({
    required this.title,
    required this.body,
    required this.type,
    required this.value,
    this.confidence = 0.85,
  });
}

enum InsightType { warning, success, info, prediction }

class IntelligenceService {
  static List<AIInsight> generateInsights({
    required MonthlySummary summary,
    required List<Map<String, dynamic>> trendData,
    required List<Budget> budgets,
  }) {
    List<AIInsight> insights = [];

    // 1. Spending Forecast (Simple Linear Projection)
    if (trendData.length >= 2) {
      final monthlyExpenses =
          trendData.map((d) => ((d['total'] as num?) ?? 0).toDouble()).toList();
      double forecast = _forecastNext(monthlyExpenses);
      double currentTotal = (summary.totalFixed +
              summary.totalVariable +
              summary.totalSubscriptions)
          .toDouble();

      if (forecast > currentTotal * 1.2) {
        insights.add(AIInsight(
          title: "SPENDING SURGE DETECTED",
          body:
              "Based on historical velocity, next month might see a 20% increase in outflows.",
          type: InsightType.warning,
          value: "Forecast: ${forecast.toInt()}",
        ));
      } else {
        insights.add(AIInsight(
          title: "SPENDING STABILITY",
          body:
              "Your spending velocity is consistent. You are on track with your historical averages.",
          type: InsightType.success,
          value: "Forecast: ${forecast.toInt()}",
        ));
      }
    }

    // 2. Savings Intelligence
    double savingsRate = summary.totalIncome > 0
        ? ((summary.totalIncome -
                (summary.totalFixed +
                    summary.totalVariable +
                    summary.totalSubscriptions)) /
            summary.totalIncome)
        : 0.0;

    if (savingsRate > 0.3) {
      insights.add(AIInsight(
        title: "HIGH SAVINGS EFFICIENCY",
        body:
            "You are saving ${(savingsRate * 100).toInt()}% of your income. Consider increasing your SIP contributions.",
        type: InsightType.info,
        value: "Elite Tier",
      ));
    }

    // 3. Subscription Leakage
    if (summary.totalSubscriptions > (summary.totalIncome * 0.1)) {
      insights.add(AIInsight(
        title: "SUBSCRIPTION OVERLOAD",
        body:
            "Subscriptions account for over 10% of your income. Review and prune unused services.",
        type: InsightType.warning,
        value: "Review",
      ));
    }

    // 4. Wealth Projection (1 Year)
    double monthlyNet = (summary.totalIncome -
            (summary.totalFixed +
                summary.totalVariable +
                summary.totalSubscriptions))
        .toDouble();
    if (monthlyNet > 0) {
      double projectedYearly = monthlyNet * 12;
      insights.add(AIInsight(
        title: "WEALTH PROJECTION",
        body:
            "At this rate, your net worth could increase by ${CurrencyHelper.format(projectedYearly)} in exactly 12 months.",
        type: InsightType.prediction,
        value: CurrencyHelper.format(projectedYearly),
      ));
    }

    return insights;
  }

  static int calculateHealthScore({
    required MonthlySummary summary,
    required List<Budget> budgets,
  }) {
    // Edge case: No data at all (New User)
    if (summary.totalIncome == 0 &&
        summary.totalFixed == 0 &&
        summary.totalVariable == 0 &&
        summary.netWorth == 0) {
      return 0; // Or a neutral starting score like 0 until they add data
    }

    double score = 0.0; // Start from 0

    // 1. Savings Rate (Max 35 points)
    // Higher weight because saving is the foundation
    double savingsRate = summary.totalIncome > 0
        ? (summary.totalIncome -
                (summary.totalFixed +
                    summary.totalVariable +
                    summary.totalSubscriptions)) /
            summary.totalIncome
        : 0;

    if (savingsRate > 0) {
      score += (savingsRate * 100).clamp(0.0, 35.0);
    }

    // 2. Debt-to-Income / Debt Load (Max 25 points)
    if (summary.totalIncome > 0) {
      // Use actual EMI + 5% of Credit Card Balance (Min Due proxy)
      double monthlyDebt =
          summary.totalMonthlyEMI.toDouble() + (summary.creditCardDebt * 0.05);
      double dti = (monthlyDebt / summary.totalIncome).clamp(0.0, 1.0);
      score += (25 * (1 - dti));
    } else if (summary.loansTotal > 0 || summary.creditCardDebt > 0) {
      // Debt with no income is a big risk
      score += 0;
    } else {
      score += 20; // No debt and no income (balanced)
    }

    // 3. Asset-to-Liability Ratio (Max 20 points)
    double assets =
        (summary.totalInvestments + summary.netWorth.clamp(0, double.infinity))
            .toDouble();
    double liabilities =
        (summary.loansTotal + summary.creditCardDebt).toDouble();
    if (liabilities == 0) {
      if (assets > 0) {
        score += 20;
      } else {
        score += 10; // Neutral
      }
    } else {
      double ratio = assets / liabilities;
      score += (ratio * 10).clamp(0.0, 20.0);
    }

    // 4. Budget Discipline (Max 20 points)
    if (budgets.isNotEmpty) {
      int overspentCount =
          budgets.where((b) => b.spent > b.monthlyLimit).length;
      double adherence = 1 - (overspentCount / budgets.length);
      score += (adherence * 20);
    } else {
      score += 10; // Neutral
    }

    // 5. Net Worth / Solvency Penalty
    if (summary.netWorth < 0) {
      if (score > 40) {
        score = 40; // Cap at 40 (At Risk boundary) immediately for insolvency
      }

      // Further reduce if deeply in debt relative to income
      if (summary.totalIncome > 0 &&
          summary.netWorth.abs() > (summary.totalIncome * 12)) {
        score -= 10; // Serious long-term insolvency risk
      }
    }

    return score.toInt().clamp(0, 100);
  }

  static double _forecastNext(List<double> values) {
    if (values.isEmpty) return 0;
    if (values.length == 1) return values.first;

    // Simple Linear Regression
    int n = values.length;
    double sumX = 0;
    double sumY = 0;
    double sumXY = 0;
    double sumXX = 0;

    for (int i = 0; i < n; i++) {
      sumX += i;
      sumY += values[i];
      sumXY += i * values[i];
      sumXX += i * i;
    }

    double slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    double intercept = (sumY - slope * sumX) / n;

    // Project for n (the next index)
    return slope * n + intercept;
  }
}
