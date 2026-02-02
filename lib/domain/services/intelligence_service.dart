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

  // --- Behavioral Thresholds ---
  static const double _savingsRateThreshold = 0.3;
  static const double _subscriptionIncomeThreshold = 0.1;
  static const double _forecastSurgeThreshold = 1.15;
  static const double _debtToIncomeRiskyThreshold = 0.60;
  static const double _debtToIncomeManageableThreshold = 0.40;
  static const double _debtToIncomeHealthyThreshold = 0.20;
  static const double _typicalSavingsBenchmark = 0.20;
  static const double _creditCardPaymentFactor =
      0.05; // 5% minimum payment estimate
  static const int _monthsInYear = 12;

  // --- Health Score Weights ---
  static const int _defaultScore = 50;
  static const double _highSavingsThreshold = 0.50;
  static const double _savingsBaseScore = 25.0;
  static const double _savingsMaxBonus = 15.0;
  static const double _savingsSlopeDenom = 0.30;
  static const double _savingsPenaltyFactor = 20.0;
  static const double _savingsPenaltyMax = 30.0;

  static const double _dtiZeroScore = 30.0;
  static const double _dtiHealthyScore = 25.0;
  static const double _dtiManageableScore = 15.0;
  static const double _dtiRiskyScore = 5.0;
  static const double _dtiHeavyPenalty = 10.0;

  static const double _solvencyHighRatio = 3.0;
  static const double _solvencyMidRatio = 1.5;
  static const double _solvencyBaseRatio = 1.0;
  static const double _solvencyHighBonus = 15.0;
  static const double _solvencyMidBonus = 10.0;
  static const double _solvencyBaseBonus = 5.0;
  static const double _solvencyZeroLiabBonus = 7.0;

  static const double _budgetMaxScore = 15.0;
  static const double _budgetNoBudgetsBonus = 10.0;
  static const double _liquidityExpMultiplier = 3.0;
  static const double _liquidityBonus = 10.0;
  static const double _insolvencyPenalty = 20.0;

  static const Map<InsightGroup, int> _groupCooldowns = {
    InsightGroup.trend: 7, // Weekly
    InsightGroup.behavioral: 30, // Monthly
    InsightGroup.critical: 1, // Daily
  };

  static const String _dailyCacheKey = 'daily_insight_cache';
  static const String _dailyCacheTimestampKey = 'daily_insight_cache_timestamp';

  List<AIInsight>? _memCache;
  DateTime? _memCacheDate;

  IntelligenceService(this._prefs);

  Future<void> dismissInsight(String id, InsightGroup group) async {
    _recordShown(id, group);
    // Invalidate cache to force re-generation without the dismissed item
    _memCache = null;
    _memCacheDate = null;
    await _prefs.remove(_dailyCacheKey);
    await _prefs.remove(_dailyCacheTimestampKey);
  }

  List<AIInsight> generateInsights({
    required MonthlySummary summary,
    required List<Map<String, dynamic>> trendData,
    required List<Budget> budgets,
    required List<Map<String, dynamic>> categorySpending,
    bool forceRefresh = false,
  }) {
    final now = DateTime.now();

    // 1. Check Memory Cache
    if (!forceRefresh &&
        _memCacheDate != null &&
        _memCacheDate!.year == now.year &&
        _memCacheDate!.month == now.month &&
        _memCacheDate!.day == now.day &&
        _memCache != null) {
      return _memCache!;
    }

    // 2. Check Disk Cache (Sync read)
    if (!forceRefresh) {
      final lastRunStr = _prefs.getString(_dailyCacheTimestampKey);
      if (lastRunStr != null) {
        try {
          final lastRun = DateTime.parse(lastRunStr);
          if (lastRun.year == now.year &&
              lastRun.month == now.month &&
              lastRun.day == now.day) {
            final cachedJson = _prefs.getString(_dailyCacheKey);
            if (cachedJson != null) {
              final List<dynamic> list = jsonDecode(cachedJson);
              _memCache = list.map((j) => AIInsight.fromJson(j)).toList();
              _memCacheDate = now;
              return _memCache!;
            }
          }
        } catch (e) {
          // Fallback to recomputation
        }
      }
    }

    List<AIInsight> allPotentialInsights = [];

    final monthlyOutflow = (summary.totalFixed +
            summary.totalVariable +
            summary.totalSubscriptions)
        .toDouble();

    double avgOutflow = 0;
    if (trendData.isNotEmpty) {
      final monthlyExpenses =
          trendData.map((d) => ((d['total'] as num?) ?? 0).toDouble()).toList();
      avgOutflow =
          monthlyExpenses.reduce((a, b) => a + b) / monthlyExpenses.length;
    }

    // 1. Wealth Projection (Prediction) - High Priority
    double monthlyNet = (summary.totalIncome - monthlyOutflow).toDouble();
    if (monthlyNet > 0) {
      final projectedYearly = monthlyNet * _monthsInYear;
      if (projectedYearly.isFinite && projectedYearly > 0) {
        allPotentialInsights.add(AIInsight(
          id: 'wealth_projection',
          title: "WEALTH PROJECTION",
          body:
              "Based on this month's ${((monthlyNet / summary.totalIncome) * 100).toInt()}% savings rate, you could grow your net worth by ${projectedYearly.toInt()} in one year. This beats the typical ${(_typicalSavingsBenchmark * 100).toInt()}% behavior benchmark.",
          type: InsightType.prediction,
          priority: InsightPriority.high,
          value: "Projected",
          currencyValue: projectedYearly,
          group: InsightGroup.behavioral,
        ));
      }
    }

    // 2. Critical Overspending - High Priority
    if (summary.totalIncome > 0 && monthlyOutflow > summary.totalIncome) {
      final deficit = monthlyOutflow - summary.totalIncome;
      String avgContext = "";
      if (avgOutflow > 0) {
        final diff = ((monthlyOutflow - avgOutflow) / avgOutflow * 100)
            .toStringAsFixed(0);
        avgContext = " This is $diff% higher than your average.";
      }

      allPotentialInsights.add(AIInsight(
        id: 'critical_overspending',
        title: "CRITICAL OVERSPENDING",
        body:
            "You've spent ${((deficit / summary.totalIncome) * 100).toInt()}% more than your income this month.$avgContext High risk of debt accumulation vs your budget limits.",
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

      if (avgOutflow > 0 && forecast > avgOutflow * _forecastSurgeThreshold) {
        allPotentialInsights.add(AIInsight(
          id: 'spending_surge',
          title: "SPENDING SURGE DETECTED",
          body:
              "Calculated velocity suggests next month's outflows will be ${((forecast / avgOutflow - 1) * 100).toInt()}% higher than your 3-month average of ${avgOutflow.toInt()}.",
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
              "You have exceeded your limit in ${overspentBudgets.length} categories. Total overflow is ${overspentBudgets.fold(0.0, (sum, b) => sum + (b.spent - b.monthlyLimit)).toInt()} vs your planned budget limits.",
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
            "Recurring services consume ${((summary.totalSubscriptions / summary.totalIncome) * 100).toInt()}% of your income, which is above the ${(_subscriptionIncomeThreshold * 100).toInt()}% typical behavior recommendation.",
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
            "Your ${((savingsRate) * 100).toInt()}% savings rate is well above the recommended 20% benchmark. This shows strong discipline vs typical consumer behavior.",
        type: InsightType.success,
        priority: InsightPriority.low,
        value: "Elite",
        group: InsightGroup.trend,
      ));
    }

    // Filter by Cooldown
    List<AIInsight> filteredInsights = _filterByCooldown(allPotentialInsights);

    // Filter by Priority
    final results = _applyPriorityLogic(filteredInsights);

    // 3. Update Cache
    _memCache = results;
    _memCacheDate = now;
    _prefs.setString(_dailyCacheTimestampKey, now.toIso8601String());
    _prefs.setString(
        _dailyCacheKey, jsonEncode(results.map((e) => e.toJson()).toList()));

    return results;
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
      return _defaultScore;
    }

    double score = 0.0;
    final totalExpenses =
        summary.totalFixed + summary.totalVariable + summary.totalSubscriptions;
    final surplus = summary.totalIncome - totalExpenses;

    if (summary.totalIncome > 0) {
      double savingsRate = surplus / summary.totalIncome;
      if (savingsRate >= _highSavingsThreshold) {
        score += (_savingsBaseScore + _savingsMaxBonus);
      } else if (savingsRate >= _typicalSavingsBenchmark) {
        score += _savingsBaseScore +
            (savingsRate - _typicalSavingsBenchmark) *
                (_savingsMaxBonus / _savingsSlopeDenom);
      } else if (savingsRate > 0) {
        score += (savingsRate / _typicalSavingsBenchmark) * _savingsBaseScore;
      } else {
        score -= (savingsRate.abs() * _savingsPenaltyFactor)
            .clamp(0.0, _savingsPenaltyMax);
      }
    } else if (totalExpenses > 0) {
      score -= _insolvencyPenalty;
    }

    if (summary.totalIncome > 0) {
      double monthlyDebt = summary.totalMonthlyEMI.toDouble() +
          (summary.creditCardDebt * _creditCardPaymentFactor);
      double dti = monthlyDebt / summary.totalIncome;

      if (dti == 0) {
        score += _dtiZeroScore;
      } else if (dti <= _debtToIncomeHealthyThreshold) {
        score += _dtiHealthyScore;
      } else if (dti <= _debtToIncomeManageableThreshold) {
        score += _dtiManageableScore;
      } else if (dti <= _debtToIncomeRiskyThreshold) {
        score += _dtiRiskyScore;
      } else {
        score -= _dtiHeavyPenalty;
      }
    }

    double liabilities =
        (summary.loansTotal + summary.creditCardDebt).toDouble();
    double assets = (summary.netWorth + liabilities).toDouble();

    if (liabilities <= 0) {
      score += assets > 0 ? _solvencyHighBonus : _solvencyZeroLiabBonus;
    } else if (assets > 0) {
      double ratio = assets / liabilities;
      if (ratio >= _solvencyHighRatio) {
        score += _solvencyHighBonus;
      } else if (ratio >= _solvencyMidRatio) {
        score += _solvencyMidBonus;
      } else if (ratio >= _solvencyBaseRatio) {
        score += _solvencyBaseBonus;
      }
    }

    if (budgets.isNotEmpty) {
      int overspentCount =
          budgets.where((b) => b.spent > b.monthlyLimit).length;
      double health = 1 - (overspentCount / budgets.length);
      score += (health * _budgetMaxScore);
    } else {
      score += _budgetNoBudgetsBonus;
    }

    if (totalExpenses > 0 &&
        assets > (totalExpenses * _liquidityExpMultiplier)) {
      score += _liquidityBonus;
    }

    if (summary.netWorth < 0) {
      score -= _insolvencyPenalty;
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
