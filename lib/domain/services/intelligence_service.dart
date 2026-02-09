import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
export 'package:trueledger/domain/models/models.dart'
    show AIInsight, InsightType, InsightPriority, InsightGroup, InsightSurface;
import 'package:trueledger/core/providers/shared_prefs_provider.dart';

final intelligenceServiceProvider = Provider<IntelligenceService>((ref) {
  return IntelligenceService(ref.watch(sharedPreferencesProvider));
});

class IntelligenceService {
  final SharedPreferences _prefs;
  static const Map<InsightGroup, int> _groupCooldowns = {
    InsightGroup.trend: 7, // Weekly
    InsightGroup.behavioral: 30, // Monthly
    InsightGroup.critical: 1, // Daily
  };

  static const String _historyKey = 'insight_display_history';
  static const String _kindHistoryKey = 'insight_kind_history';

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
  static const int _defaultScore = 0;
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

  static const String _dailyCacheKey = 'daily_insight_cache';
  static const String _dailyCacheTimestampKey = 'daily_insight_cache_timestamp';

  List<AIInsight>? _memCache;
  DateTime? _memCacheDate;

  IntelligenceService(this._prefs);

  Future<void> dismissInsight(String id, InsightGroup group) async {
    _recordShown(id, group);
    _clearCache();
  }

  Future<void> snoozeInsight(String id, {int days = 7}) async {
    final historyJson = _prefs.getString(_historyKey) ?? '{}';
    final Map<String, dynamic> history = jsonDecode(historyJson);
    final snoozeDate = DateTime.now().add(Duration(days: days));

    history['snooze_$id'] = snoozeDate.toIso8601String();
    await _prefs.setString(_historyKey, jsonEncode(history));
    _clearCache();
  }

  void resetAll() {
    _clearCache();
    _prefs.remove(_historyKey);
    _prefs.remove(_kindHistoryKey);
  }

  void _clearCache() {
    _memCache = null;
    _memCacheDate = null;
    _prefs.remove(_dailyCacheKey);
    _prefs.remove(_dailyCacheTimestampKey);
  }

  List<AIInsight> generateInsights({
    required MonthlySummary summary,
    required List<Map<String, dynamic>> trendData,
    required List<Budget> budgets,
    required List<Map<String, dynamic>> categorySpending,
    InsightSurface requestedSurface = InsightSurface.main,
    bool forceRefresh = false,
    bool ignoreCooldown = false,
  }) {
    final now = DateTime.now();

    // 0. Safety Check: If data is empty, clear cache and return empty immediately
    // This prevents "Ghost Insights" from persisting after data deletion
    bool isEmpty = summary.totalIncome == 0 &&
        summary.totalFixed == 0 &&
        summary.totalVariable == 0 &&
        summary.totalSubscriptions == 0 &&
        summary.netWorth == 0;

    if (isEmpty) {
      _clearCache();
      return [];
    }

    // 1. Check Memory Cache
    if (!forceRefresh &&
        _memCacheDate != null &&
        _memCacheDate!.year == now.year &&
        _memCacheDate!.month == now.month &&
        _memCacheDate!.day == now.day &&
        _memCache != null) {
      return _filterBySurface(_memCache!, requestedSurface);
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
              return _filterBySurface(_memCache!, requestedSurface);
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

    // Days until next month (for budget cycle cooldown)
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final daysUntilNextCycle = nextMonth.difference(now).inDays;

    // 1. Wealth Projection (Prediction) - High Priority
    double monthlyNet = (summary.totalIncome - monthlyOutflow).toDouble();
    if (monthlyNet > 0 && summary.totalIncome > 0) {
      final projectedYearly = monthlyNet * _monthsInYear;
      final savingsRate = monthlyNet / summary.totalIncome;
      if (projectedYearly.isFinite && projectedYearly > 0) {
        allPotentialInsights.add(AIInsight(
          id: 'wealth_projection',
          title: "WEALTH PROJECTION",
          body:
              "At your current ${((savingsRate) * 100).toInt()}% savings rate, you could grow your net worth by ${CurrencyFormatter.format(projectedYearly)} in one year. This beats the typical behavior benchmark of ${(_typicalSavingsBenchmark * 100).toInt()}%.",
          type: InsightType.prediction,
          priority: InsightPriority.high,
          value: "Projected",
          currencyValue: projectedYearly,
          group: InsightGroup.behavioral,
          cooldown: const Duration(days: 14), // Patterns: 14 days
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
        avgContext =
            " This is $diff% higher than your average monthly spending of ${CurrencyFormatter.format(avgOutflow)}.";
      }

      allPotentialInsights.add(AIInsight(
        id: 'critical_overspending',
        title: "CRITICAL OVERSPENDING",
        body:
            "You've spent ${((deficit / summary.totalIncome) * 100).toInt()}% more than your income this month.$avgContext Abnormal pattern detected compared to your earnings.",
        type: InsightType.warning,
        priority: InsightPriority.high,
        value: "Deficit",
        currencyValue: deficit,
        group: InsightGroup.critical,
        cooldown: const Duration(days: 1), // Daily check for critical
      ));
    }

    // 3. Spending Forecast - Medium Priority
    if (trendData.length >= 2 && avgOutflow > 0) {
      final monthlyExpenses =
          trendData.map((d) => ((d['total'] as num?) ?? 0).toDouble()).toList();
      double forecast = _forecastNext(monthlyExpenses);

      if (forecast > avgOutflow * _forecastSurgeThreshold) {
        allPotentialInsights.add(AIInsight(
          id: 'spending_surge',
          title: "SPENDING SURGE DETECTED",
          body:
              "Calculated velocity suggests next month's outflows will be ${CurrencyFormatter.format(forecast)}, a ${((forecast / avgOutflow - 1) * 100).toInt()}% increase compared to your 3-month average.",
          type: InsightType.warning,
          priority: InsightPriority.medium,
          value: "Forecast",
          currencyValue: forecast,
          group: InsightGroup.trend,
          cooldown: const Duration(days: 7), // Trends: weekly
        ));
      }
    }

    // 4. Budget Discipline - Medium Priority
    if (budgets.isNotEmpty) {
      final overspentBudgets =
          budgets.where((b) => b.spent > b.monthlyLimit).toList();
      if (overspentBudgets.isNotEmpty) {
        final totalOverflow = overspentBudgets.fold(
            0.0, (sum, b) => sum + (b.spent - b.monthlyLimit));
        allPotentialInsights.add(AIInsight(
          id: 'budget_discipline',
          title: "BUDGET OVERFLOW",
          body:
              "You have exceeded your limit in ${overspentBudgets.length} categories. Total overflow is ${CurrencyFormatter.format(totalOverflow)} compared to your set budget limits.",
          type: InsightType.warning,
          priority: InsightPriority.medium,
          value: "Overflow",
          currencyValue: totalOverflow,
          group: InsightGroup.trend,
          cooldown: Duration(
              days: daysUntilNextCycle.clamp(7, 30)), // Until next cycle
        ));
      }
    }

    // 5. Subscription Leakage - Low Priority
    if (summary.totalIncome > 0 &&
        summary.totalSubscriptions >
            (summary.totalIncome * _subscriptionIncomeThreshold)) {
      allPotentialInsights.add(AIInsight(
        id: 'subscription_overload',
        title: "SUBSCRIPTION LEAKAGE",
        body:
            "Recurring services consume ${((summary.totalSubscriptions / summary.totalIncome) * 100).toInt()}% of your income. This exceeds the ${(_subscriptionIncomeThreshold * 100).toInt()}% typical behavior benchmark.",
        type: InsightType.info,
        priority: InsightPriority.medium,
        value: "Subscriptions",
        currencyValue: summary.totalSubscriptions.toDouble(),
        group: InsightGroup.behavioral,
        cooldown: const Duration(days: 14), // Patterns: 14 days
      ));
    }

    // 6. Savings Milestone - Low Priority
    double savingsRate =
        summary.totalIncome > 0 ? (monthlyNet / summary.totalIncome) : 0;
    if (savingsRate > _savingsRateThreshold) {
      allPotentialInsights.add(AIInsight(
        id: 'savings_milestone',
        title: "SAVINGS MASTERY",
        body:
            "Your ${((savingsRate) * 100).toInt()}% savings rate is exceptional compared to the recommended ${(_typicalSavingsBenchmark * 100).toInt()}% benchmark.",
        type: InsightType.success,
        priority: InsightPriority.medium,
        value: "Savings Rate",
        currencyValue: (savingsRate * 100),
        group: InsightGroup.trend,
        cooldown: const Duration(days: 7), // Reflections: weekly
      ));
    }

    // 7. Budget Stability (Multi-month pattern) - Low Priority
    final stableBudgets = budgets.where((b) => b.isStable).toList();
    if (stableBudgets.length >= budgets.length / 2 && budgets.isNotEmpty) {
      allPotentialInsights.add(AIInsight(
        id: 'stable_lifestyle',
        title: "STABLE LIFESTYLE",
        body:
            "Most of your budget categories have remained stable for over 3 months. This level of consistency is a hallmark of financial maturity.",
        type: InsightType.success,
        priority: InsightPriority.medium,
        value: "Stability",
        currencyValue: null,
        group: InsightGroup.behavioral,
        cooldown: const Duration(days: 21), // Patterns: 21 days
      ));
    }

    // If ignoreCooldown is true (for exports), return all potential insights
    if (ignoreCooldown) {
      return _filterBySurface(allPotentialInsights, requestedSurface);
    }

    // Filter by Cooldown
    List<AIInsight> filteredInsights = _filterByCooldown(allPotentialInsights);

    // Filter by Priority & Surface Logic
    final results = _applyPriorityLogic(filteredInsights);

    // 3. Update Cache (All potential valid insights for the day)
    _memCache = results;
    _memCacheDate = now;
    _prefs.setString(_dailyCacheTimestampKey, now.toIso8601String());
    _prefs.setString(
        _dailyCacheKey, jsonEncode(results.map((e) => e.toJson()).toList()));

    return _filterBySurface(results, requestedSurface);
  }

  List<AIInsight> _filterBySurface(
      List<AIInsight> insights, InsightSurface surface) {
    if (surface == InsightSurface.main) {
      // Safety net: main surface should never show low-priority insights
      return insights.where((i) => i.priority != InsightPriority.low).toList();
    }
    return insights;
  }

  List<AIInsight> _filterByCooldown(List<AIInsight> potential) {
    final historyJson = _prefs.getString(_historyKey) ?? '{}';
    final kindHistoryJson = _prefs.getString(_kindHistoryKey) ?? '{}';
    final Map<String, dynamic> history = jsonDecode(historyJson);
    final Map<String, dynamic> kindHistory = jsonDecode(kindHistoryJson);
    final now = DateTime.now();
    final List<AIInsight> filtered = [];

    for (final insight in potential) {
      // 0. Check Explicit Snooze (Remains as is)
      final snoozeUntilStr = history['snooze_${insight.id}'];
      if (snoozeUntilStr != null) {
        try {
          final snoozeUntil = DateTime.parse(snoozeUntilStr);
          if (now.isBefore(snoozeUntil)) continue;
        } catch (_) {}
      }

      // 1. Check Kind-based Cooldown (Primary Requirement)
      // Insight IDs represent their "kind" in the current implementation.
      final lastShownStr = kindHistory[insight.id];
      if (lastShownStr != null) {
        try {
          final lastShown = DateTime.parse(lastShownStr);
          final cooldownDuration = insight.cooldown;

          // Enforce strict duration-based cooldown
          if (now.difference(lastShown) < cooldownDuration) {
            continue;
          }
        } catch (_) {}
      }

      // 2. Check Group Throttling (Breathing room for the whole category)
      final groupKey = 'group_last_shown_${insight.group.name}';
      final lastGroupShownStr = history[groupKey];
      if (lastGroupShownStr != null) {
        try {
          final lastGroupShown = DateTime.parse(lastGroupShownStr);
          // For groups, we might want a slightly shorter throttling than the individual kind,
          // but for Behavioral/Trend we follow the user's strict weekly/monthly desire.
          final groupCooldown = _groupCooldowns[insight.group] ?? 7;

          if (insight.group != InsightGroup.critical &&
              now.difference(lastGroupShown).inDays <
                  (groupCooldown / 2).ceil()) {
            // We use half the cooldown for group throttling to allow different insights
            // from same group occasionally, but still enforce strict kind cooldown above.
            continue;
          }
        } catch (_) {}
      }

      filtered.add(insight);
    }
    return filtered;
  }

  /// Applies strict priority-based display logic.
  ///
  /// **ENFORCEMENT RULES:**
  /// - HIGH: Exactly 1 if any exist (interrupts attention)
  /// - MEDIUM: Max 2 only if NO high exists (passive display)
  /// - LOW: Returned but FILTERED by surface (never auto-shown on main)
  ///
  /// This is the CENTRAL POLICY that prevents insight spam.
  /// DO NOT modify without understanding the product implications.
  List<AIInsight> _applyPriorityLogic(List<AIInsight> insights) {
    if (insights.isEmpty) {
      return [];
    }

    // 1. High Priority Rule: Exactly one if any exist
    final high =
        insights.where((i) => i.priority == InsightPriority.high).toList();
    if (high.isNotEmpty) {
      // Sort by confidence (DO NOT use enum.index)
      high.sort((a, b) => b.confidence.compareTo(a.confidence));
      final selected = high.first;
      _recordShown(selected.id, selected.group);
      return [selected];
    }

    // 2. Medium Priority Rule: Max 2 total
    final medium =
        insights.where((i) => i.priority == InsightPriority.medium).toList();

    if (medium.isNotEmpty) {
      medium.sort((a, b) => b.confidence.compareTo(a.confidence));
      final showing = medium.take(2).toList();
      for (var s in showing) {
        _recordShown(s.id, s.group);
      }
      return showing;
    }

    // 3. Low Priority Rule: NEVER auto-shown on main surface
    // These are returned here but MUST be filtered by _filterBySurface.
    // If a low priority insight appears on the dashboard, the system is broken.
    final low =
        insights.where((i) => i.priority == InsightPriority.low).toList();

    low.sort((a, b) => b.confidence.compareTo(a.confidence));
    final showing = low.take(2).toList();

    // DO NOT record as shown here - they're filtered by surface logic.
    // Only record when actually displayed in details view.
    return showing;
  }

  void _recordShown(String id, InsightGroup group) {
    if (id == 'no_insights') return;
    final nowStr = DateTime.now().toIso8601String();

    // 1. Record Kind History
    final kindHistoryJson = _prefs.getString(_kindHistoryKey) ?? '{}';
    final Map<String, dynamic> kindHistory = jsonDecode(kindHistoryJson);
    kindHistory[id] = nowStr;
    _prefs.setString(_kindHistoryKey, jsonEncode(kindHistory));

    // 2. Record Group Throttling History
    final historyJson = _prefs.getString(_historyKey) ?? '{}';
    final Map<String, dynamic> history = jsonDecode(historyJson);
    history['group_last_shown_${group.name}'] = nowStr;
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
