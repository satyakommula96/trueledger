import 'package:trueledger/domain/models/models.dart';

class AIInsight {
  final String title;
  final String body;
  final InsightType type;
  final String value;
  final num? currencyValue; // Raw numeric value for formatting
  final double confidence;

  AIInsight({
    required this.title,
    required this.body,
    required this.type,
    required this.value,
    this.currencyValue,
    this.confidence = 0.85,
  });
}

enum InsightType { warning, success, info, prediction }

class IntelligenceService {
  static List<AIInsight> generateInsights({
    required MonthlySummary summary,
    required List<Map<String, dynamic>> trendData,
    required List<Budget> budgets,
    required List<Map<String, dynamic>> categorySpending,
  }) {
    List<AIInsight> insights = [];

    // 1. Wealth Projection (1 Year) - MOVED TO FIRST
    double monthlyNet = (summary.totalIncome -
            (summary.totalFixed +
                summary.totalVariable +
                summary.totalSubscriptions))
        .toDouble();
    if (monthlyNet > 0) {
      final projectedYearly = monthlyNet * 12;

      if (projectedYearly.isFinite && projectedYearly > 0) {
        insights.add(AIInsight(
          title: "WEALTH PROJECTION",
          body:
              "At this rate, your net worth is projected to grow substantially in exactly 12 months.",
          type: InsightType.prediction,
          value: "Projected",
          currencyValue: projectedYearly,
        ));
      }
    }

    // 2. Spending Forecast (Simple Linear Projection)
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
          value: "Forecast",
          currencyValue: forecast,
        ));
      } else {
        insights.add(AIInsight(
          title: "SPENDING STABILITY",
          body:
              "Your spending velocity is consistent. You are on track with your historical averages.",
          type: InsightType.success,
          value: "Forecast",
          currencyValue: forecast,
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

    // 4. Overspending Check
    final totalOutflow = (summary.totalFixed +
        summary.totalVariable +
        summary.totalSubscriptions);
    if (summary.totalIncome > 0 && totalOutflow > summary.totalIncome) {
      insights.add(AIInsight(
        title: "CRITICAL OVERSPENDING",
        body:
            "Your monthly expenses exceed your income. This is unsustainable. Review your variable costs immediately.",
        type: InsightType.warning,
        value: "Danger",
      ));
    }

    // 5. Top Expense Category
    if (categorySpending.isNotEmpty) {
      final topCategory = categorySpending.reduce((curr, next) =>
          ((curr['total'] as num?) ?? 0) > ((next['total'] as num?) ?? 0)
              ? curr
              : next);

      final totalExpense = summary.totalFixed +
          summary.totalVariable +
          summary.totalSubscriptions;

      if (totalExpense > 0) {
        final percentage =
            (((topCategory['total'] as num?) ?? 0) / totalExpense) * 100;
        if (percentage > 40) {
          insights.add(AIInsight(
            title: "CONCENTRATED SPENDING",
            body:
                "${topCategory['category']} accounts for ${percentage.toInt()}% of your monthly outflow. Explore ways to reduce this specific category.",
            type: InsightType.info,
            value: (topCategory['category'] as String).toUpperCase(),
            currencyValue: (topCategory['total'] as num?)?.toDouble(),
          ));
        }
      }
    }

    return insights;
  }

  static int calculateHealthScore({
    required MonthlySummary summary,
    required List<Budget> budgets,
  }) {
    // Edge case: No data or newly initialized
    if (summary.totalIncome == 0 &&
        summary.totalFixed == 0 &&
        summary.totalVariable == 0 &&
        summary.netWorth == 0) {
      return 50; // New users start at a neutral mid-point
    }

    double score = 0.0;

    // 1. SURPLUS / SAVINGS RATE (Weight: 40%)
    final totalExpenses =
        summary.totalFixed + summary.totalVariable + summary.totalSubscriptions;
    final surplus = summary.totalIncome - totalExpenses;

    if (summary.totalIncome > 0) {
      double savingsRate = surplus / summary.totalIncome;
      if (savingsRate >= 0.50) {
        score += 40; // Exceptional (50%+)
      } else if (savingsRate >= 0.20) {
        // Linear scale from 20% to 50% (25 to 40 points)
        score += 25 + (savingsRate - 0.20) * (15 / 0.30);
      } else if (savingsRate > 0) {
        // Linear scale from 0% to 20% (0 to 25 points)
        score += (savingsRate / 0.20) * 25;
      } else {
        // Negative savings rate penalty
        score -= (savingsRate.abs() * 20).clamp(0.0, 30.0);
      }
    } else if (totalExpenses > 0) {
      score -= 20; // Spending with no income
    }

    // 2. DEBT BURDEN / DTI (Weight: 30%)
    if (summary.totalIncome > 0) {
      // Monthly debt obligation = EMI + 5% of CC debt (proxy for min due)
      double monthlyDebt =
          summary.totalMonthlyEMI.toDouble() + (summary.creditCardDebt * 0.05);
      double dti = monthlyDebt / summary.totalIncome;

      if (dti == 0) {
        score += 30; // No debt is perfect
      } else if (dti <= 0.20) {
        score += 25; // Healthy
      } else if (dti <= 0.40) {
        score += 15; // Manageable
      } else if (dti <= 0.60) {
        score += 5; // High risk
      } else {
        score -= 10; // Extreme burden
      }
    } else if (summary.loansTotal == 0 && summary.creditCardDebt == 0) {
      score += 20; // No income, but at least no debt
    }

    // 3. SOLVENCY & WEALTH (ASSET/LIABILITY) (Weight: 15%)
    // In our model, netWorth = (Investments + Retirement) - Debt
    // So Total Assets = netWorth + Debt
    double liabilities =
        (summary.loansTotal + summary.creditCardDebt).toDouble();
    double assets = (summary.netWorth + liabilities).toDouble();

    if (liabilities <= 0) {
      if (assets > 0) {
        score += 15; // Solvent and growing
      } else {
        score += 7; // Neutral (no assets, no debt)
      }
    } else if (assets > 0) {
      double ratio = assets / liabilities;
      if (ratio >= 3.0) {
        score += 15; // Solid (Assets > 3x Debt)
      } else if (ratio >= 1.5) {
        score += 10; // Good
      } else if (ratio >= 1.0) {
        score += 5; // Solvent but leveraged
      } else {
        score += 0; // Underwater or highly leveraged
      }
    }

    // 4. BUDGET DISCIPLINE (Weight: 15%)
    if (budgets.isNotEmpty) {
      int overspentCount =
          budgets.where((b) => b.spent > b.monthlyLimit).length;
      double health = 1 - (overspentCount / budgets.length);
      score += (health * 15);
    } else {
      score += 10; // Bonus for just showing up, or neutral
    }

    // 5. LIQUIDITY BONUS (Emergency Fund Proxy)
    // If Assets covers 3+ months of expenses
    if (totalExpenses > 0 && assets > (totalExpenses * 3)) {
      score += 10;
    }

    // 6. SOLVENCY PENALTY
    if (summary.netWorth < 0) {
      score -= 20;
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
