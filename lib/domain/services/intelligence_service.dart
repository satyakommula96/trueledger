import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/domain/models/models.dart';
export 'package:trueledger/domain/models/models.dart'
    show AIInsight, InsightType, InsightPriority, InsightGroup;
import 'package:trueledger/core/providers/shared_prefs_provider.dart';

final intelligenceServiceProvider = Provider<IntelligenceService>((ref) {
  return IntelligenceService(ref.watch(sharedPreferencesProvider));
});

class IntelligenceService {
  final SharedPreferences _prefs;
  static const String _historyKey = 'insight_display_history';

  static const double _savingsRateThreshold = 0.3;
  static const double _subscriptionIncomeThreshold = 0.1;
  static const double _forecastSurgeThreshold = 1.15;
  static const double _debtToIncomeRiskyThreshold = 0.60;
  static const double _debtToIncomeManageableThreshold = 0.40;
  static const double _debtToIncomeHealthyThreshold = 0.20;

  static const Map<InsightGroup, int> _groupCooldowns = {
    InsightGroup.trend: 7, // Weekly
    InsightGroup.behavioral: 30, // Monthly
    InsightGroup.critical: 1, // Daily
  };

  IntelligenceService(this._prefs);

  Future<void> dismissInsight(String id, InsightGroup group) async {
    _recordShown(id, group);
  }

  List<AIInsight> generateInsights({
    required MonthlySummary summary,
    required List<Map<String, dynamic>> trendData,
    required List<Budget> budgets,
    required List<Map<String, dynamic>> categorySpending,
  }) {
    List<AIInsight> allPotentialInsights = [];

    // 1. Wealth Projection (Prediction) - High Priority
    double monthlyNet = (summary.totalIncome -
            (summary.totalFixed +
                summary.totalVariable +
                summary.totalSubscriptions))
        .toDouble();
    if (monthlyNet > 0) {
      final projectedYearly = monthlyNet * 12;
      if (projectedYearly.isFinite && projectedYearly > 0) {
        allPotentialInsights.add(AIInsight(
          id: 'wealth_projection',
          title: "WEALTH PROJECTION",
          body:
              "Based on this month's ${((monthlyNet / summary.totalIncome) * 100).toInt()}% savings rate, you could grow your net worth by ${projectedYearly.toInt()} in one year.",
          type: InsightType.prediction,
          priority: InsightPriority.high,
          value: "Projected",
          currencyValue: projectedYearly,
          group: InsightGroup.behavioral,
        ));
      }
    }

    // 2. Critical Overspending - High Priority
    final totalOutflow = (summary.totalFixed +
        summary.totalVariable +
        summary.totalSubscriptions);
    if (summary.totalIncome > 0 && totalOutflow > summary.totalIncome) {
      final deficit = totalOutflow - summary.totalIncome;
      allPotentialInsights.add(AIInsight(
        id: 'critical_overspending',
        title: "CRITICAL OVERSPENDING",
        body:
            "You've spent ${((deficit / summary.totalIncome) * 100).toInt()}% more than your income this month. High risk of debt accumulation.",
        type: InsightType.warning,
        priority: InsightPriority.high,
        value: "Danger",
        currencyValue: deficit,
        group: InsightGroup.critical,
      ));
    }

    // 3. Spending Forecast - Medium Priority
    if (trendData.length >= 2) {
      final monthlyExpenses =
          trendData.map((d) => ((d['total'] as num?) ?? 0).toDouble()).toList();
      double forecast = _forecastNext(monthlyExpenses);
      double avgExpense =
          monthlyExpenses.reduce((a, b) => a + b) / monthlyExpenses.length;

      if (forecast > avgExpense * _forecastSurgeThreshold) {
        allPotentialInsights.add(AIInsight(
          id: 'spending_surge',
          title: "SPENDING SURGE DETECTED",
          body:
              "Calculated velocity suggests next month's outflows will be ${((_forecastSurgeThreshold - 1) * 100).toInt()}% higher than your 3-month average.",
          type: InsightType.warning,
          priority: InsightPriority.medium,
          value: "Forecast",
          currencyValue: forecast,
          group: InsightGroup.trend,
        ));
      }
    }

    // 4. Budget Discipline - Medium Priority
    if (budgets.isNotEmpty) {
      final overspentBudgets =
          budgets.where((b) => b.spent > b.monthlyLimit).toList();
      if (overspentBudgets.isNotEmpty) {
        allPotentialInsights.add(AIInsight(
          id: 'budget_discipline',
          title: "BUDGET OVERFLOW",
          body:
              "You have exceeded your limit in ${overspentBudgets.length} categories. Total overflow is ${overspentBudgets.fold(0.0, (sum, b) => sum + (b.spent - b.monthlyLimit)).toInt()} vs your plan.",
          type: InsightType.warning,
          priority: InsightPriority.medium,
          value: "Action Needed",
          group: InsightGroup.trend,
        ));
      }
    }

    // 5. Subscription Leakage - Low Priority
    if (summary.totalSubscriptions >
        (summary.totalIncome * _subscriptionIncomeThreshold)) {
      allPotentialInsights.add(AIInsight(
        id: 'subscription_overload',
        title: "SUBSCRIPTION LEAKAGE",
        body:
            "Recurring services consume ${((summary.totalSubscriptions / summary.totalIncome) * 100).toInt()}% of your income, which is above the ${(_subscriptionIncomeThreshold * 100).toInt()}% recommendation.",
        type: InsightType.info,
        priority: InsightPriority.low,
        value: "Optimization",
        group: InsightGroup.behavioral,
      ));
    }

    // 6. Savings Milestone - Low Priority
    double savingsRate =
        summary.totalIncome > 0 ? (monthlyNet / summary.totalIncome) : 0;
    if (savingsRate > _savingsRateThreshold) {
      allPotentialInsights.add(AIInsight(
        id: 'savings_milestone',
        title: "SAVINGS MILESTONE",
        body:
            "Your ${((savingsRate) * 100).toInt()}% savings rate is well above the recommended 20% benchmark. Great consistency!",
        type: InsightType.success,
        priority: InsightPriority.low,
        value: "Elite",
        group: InsightGroup.trend,
      ));
    }

    // Filter by Cooldown
    List<AIInsight> filteredInsights = _filterByCooldown(allPotentialInsights);

    // Filter by Priority
    return _applyPriorityLogic(filteredInsights);
  }

  List<AIInsight> _filterByCooldown(List<AIInsight> potential) {
    final historyJson = _prefs.getString(_historyKey) ?? '{}';
    final Map<String, dynamic> history = jsonDecode(historyJson);
    final now = DateTime.now();
    final List<AIInsight> filtered = [];

    for (final insight in potential) {
      // 1. Check Individual Insight Cooldown
      final lastShownStr = history[insight.id];
      if (lastShownStr != null) {
        final lastShown = DateTime.parse(lastShownStr);
        final cooldown = _groupCooldowns[insight.group] ?? 7;
        if (now.difference(lastShown).inDays < cooldown) {
          continue;
        }
      }

      // 2. Check Group Cooldown (Broad Throttling)
      final groupKey = 'group_${insight.group.name}';
      final lastGroupShownStr = history[groupKey];
      if (lastGroupShownStr != null) {
        final lastGroupShown = DateTime.parse(lastGroupShownStr);
        final groupCooldown = _groupCooldowns[insight.group] ?? 7;

        // Critical insights can show multiple times if different, but others follow group throttles
        if (insight.group != InsightGroup.critical &&
            now.difference(lastGroupShown).inDays < groupCooldown) {
          continue;
        }
      }

      filtered.add(insight);
    }
    return filtered;
  }

  List<AIInsight> _applyPriorityLogic(List<AIInsight> insights) {
    if (insights.isEmpty) {
      return [
        AIInsight(
          id: 'no_insights',
          title: "NEUTRAL PATTERNS",
          body:
              "Your spending habits are balanced relative to your goals. Keep tracking to unlock more analysis.",
          type: InsightType.info,
          priority: InsightPriority.low,
          value: "Steady",
          group: InsightGroup.critical,
        )
      ];
    }

    // Sort by confidence within same priority groups
    insights.sort((a, b) => b.confidence.compareTo(a.confidence));

    // 1. High Priority Rule: Exactly one if any exist
    final high =
        insights.where((i) => i.priority == InsightPriority.high).toList();
    if (high.isNotEmpty) {
      final selected = high.first;
      _recordShown(selected.id, selected.group);
      return [selected];
    }

    // 2. Medium & Low Priority Rule: Max 2 total, priority ordered
    // We prioritize Medium over Low, and then confidence.
    final remaining = insights
        .where((i) =>
            i.priority == InsightPriority.medium ||
            i.priority == InsightPriority.low)
        .toList();

    // Sort by priority (Medium before Low) then confidence
    remaining.sort((a, b) {
      if (a.priority == b.priority) {
        return b.confidence.compareTo(a.confidence);
      }
      return a.priority == InsightPriority.medium ? -1 : 1;
    });

    final showing = remaining.take(2).toList();
    for (var s in showing) {
      _recordShown(s.id, s.group);
    }
    return showing;
  }

  void _recordShown(String id, InsightGroup group) {
    if (id == 'no_insights') return;
    final historyJson = _prefs.getString(_historyKey) ?? '{}';
    final Map<String, dynamic> history = jsonDecode(historyJson);
    final nowStr = DateTime.now().toIso8601String();

    history[id] = nowStr;
    history['group_${group.name}'] = nowStr;

    _prefs.setString(_historyKey, jsonEncode(history));
  }

  static int calculateHealthScore({
    required MonthlySummary summary,
    required List<Budget> budgets,
  }) {
    if (summary.totalIncome == 0 &&
        summary.totalFixed == 0 &&
        summary.totalVariable == 0 &&
        summary.netWorth == 0) {
      return 50;
    }

    double score = 0.0;
    final totalExpenses =
        summary.totalFixed + summary.totalVariable + summary.totalSubscriptions;
    final surplus = summary.totalIncome - totalExpenses;

    if (summary.totalIncome > 0) {
      double savingsRate = surplus / summary.totalIncome;
      if (savingsRate >= 0.50) {
        score += 40;
      } else if (savingsRate >= 0.20) {
        score += 25 + (savingsRate - 0.20) * (15 / 0.30);
      } else if (savingsRate > 0) {
        score += (savingsRate / 0.20) * 25;
      } else {
        score -= (savingsRate.abs() * 20).clamp(0.0, 30.0);
      }
    } else if (totalExpenses > 0) {
      score -= 20;
    }

    if (summary.totalIncome > 0) {
      double monthlyDebt =
          summary.totalMonthlyEMI.toDouble() + (summary.creditCardDebt * 0.05);
      double dti = monthlyDebt / summary.totalIncome;

      if (dti == 0) {
        score += 30;
      } else if (dti <= _debtToIncomeHealthyThreshold) {
        score += 25;
      } else if (dti <= _debtToIncomeManageableThreshold) {
        score += 15;
      } else if (dti <= _debtToIncomeRiskyThreshold) {
        score += 5;
      } else {
        score -= 10;
      }
    }

    double liabilities =
        (summary.loansTotal + summary.creditCardDebt).toDouble();
    double assets = (summary.netWorth + liabilities).toDouble();

    if (liabilities <= 0) {
      score += assets > 0 ? 15 : 7;
    } else if (assets > 0) {
      double ratio = assets / liabilities;
      if (ratio >= 3.0) {
        score += 15;
      } else if (ratio >= 1.5) {
        score += 10;
      } else if (ratio >= 1.0) {
        score += 5;
      }
    }

    if (budgets.isNotEmpty) {
      int overspentCount =
          budgets.where((b) => b.spent > b.monthlyLimit).length;
      double health = 1 - (overspentCount / budgets.length);
      score += (health * 15);
    } else {
      score += 10;
    }

    if (totalExpenses > 0 && assets > (totalExpenses * 3)) {
      score += 10;
    }

    if (summary.netWorth < 0) {
      score -= 20;
    }

    return score.toInt().clamp(0, 100);
  }

  double _forecastNext(List<double> values) {
    if (values.isEmpty) return 0;
    if (values.length == 1) return values.first;

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

    return slope * n + intercept;
  }
}
