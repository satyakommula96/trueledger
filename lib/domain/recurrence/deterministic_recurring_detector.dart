import 'dart:math';
import 'recurrence_models.dart';
import 'recurring_detector.dart';

class DeterministicRecurringDetector implements RecurringPatternDetector {
  static const int minOccurrences = 3;
  static const int monthlyToleranceDays = 3;
  static const int weeklyToleranceDays = 1;
  static const int yearlyToleranceDays = 10;

  @override
  RecurringDetectionResult detect({
    required List<Transaction> transactions,
    required DateTime referenceDate,
  }) {
    if (transactions.length < minOccurrences) {
      return RecurringDetectionResult(patterns: []);
    }

    // Step 1: Group by Logical Key
    // Key = Category + Merchant (if any) + Account (if any)
    final Map<String, List<Transaction>> groups = {};

    for (var tx in transactions) {
      final key =
          '${tx.category}|${tx.merchant ?? 'none'}|${tx.accountId ?? 'default'}';
      groups.putIfAbsent(key, () => []).add(tx);
    }

    final List<RecurringPattern> detectedPatterns = [];

    // Step 2: Analyze each group
    groups.forEach((key, groupTransactions) {
      if (groupTransactions.length < minOccurrences) return;

      // Sort by date ascending
      groupTransactions.sort((a, b) => a.date.compareTo(b.date));

      final pattern = _analyzeGroup(key, groupTransactions);
      if (pattern != null && pattern.confidenceScore > 0.4) {
        detectedPatterns.add(pattern);
      }
    });

    return RecurringDetectionResult(patterns: detectedPatterns);
  }

  RecurringPattern? _analyzeGroup(String key, List<Transaction> txs) {
    final List<int> intervals = [];
    final List<int> amounts = [];

    for (int i = 0; i < txs.length; i++) {
      amounts.add(txs[i].amount);
      if (i > 0) {
        intervals.add(txs[i].date.difference(txs[i - 1].date).inDays);
      }
    }

    final avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;
    final avgAmount = amounts.reduce((a, b) => a + b) / amounts.length;

    // Detect Frequency
    RecurrenceFrequency freq = RecurrenceFrequency.unknown;
    if ((avgInterval - 30.4).abs() <= monthlyToleranceDays + 2) {
      freq = RecurrenceFrequency.monthly;
    } else if ((avgInterval - 7).abs() <= weeklyToleranceDays) {
      freq = RecurrenceFrequency.weekly;
    } else if ((avgInterval - 365).abs() <= yearlyToleranceDays) {
      freq = RecurrenceFrequency.yearly;
    }

    if (freq == RecurrenceFrequency.unknown) return null;

    // Calculate Scores
    final intervalScore = _calculateIntervalScore(intervals, freq);
    final amountStabilityScore = _calculateAmountScore(amounts);
    final occurrenceDepthScore = _calculateDepthScore(txs.length);

    final confidence = (intervalScore * 0.4) +
        (amountStabilityScore * 0.3) +
        (occurrenceDepthScore * 0.3);

    // Day of month for monthly
    int dayOfMonth = 0;
    if (freq == RecurrenceFrequency.monthly) {
      // Use the median or mode of the day of month
      final days = txs.map((t) => t.date.day).toList();
      days.sort();
      dayOfMonth = days[days.length ~/ 2];
    }

    return RecurringPattern(
      patternId: 'p_${key.hashCode.toRadixString(16)}',
      typicalAmount: avgAmount.round(),
      frequency: freq,
      dayOfMonth: dayOfMonth,
      confidenceScore: confidence,
      occurrenceCount: txs.length,
    );
  }

  double _calculateIntervalScore(
      List<int> intervals, RecurrenceFrequency freq) {
    double target;
    double tolerance;

    switch (freq) {
      case RecurrenceFrequency.monthly:
        target = 30.4;
        tolerance = monthlyToleranceDays.toDouble();
        break;
      case RecurrenceFrequency.weekly:
        target = 7;
        tolerance = weeklyToleranceDays.toDouble();
        break;
      case RecurrenceFrequency.yearly:
        target = 365;
        tolerance = yearlyToleranceDays.toDouble();
        break;
      default:
        return 0.0;
    }

    double totalDeviation = 0;
    for (var interval in intervals) {
      totalDeviation += (interval - target).abs();
    }
    final avgDeviation = totalDeviation / intervals.length;

    if (avgDeviation <= tolerance) return 1.0;
    if (avgDeviation > tolerance * 3) return 0.2;
    return 1.0 - (avgDeviation - tolerance) / (tolerance * 2);
  }

  double _calculateAmountScore(List<int> amounts) {
    if (amounts.isEmpty) return 0.0;
    final mean = amounts.reduce((a, b) => a + b) / amounts.length;
    if (mean == 0) return 1.0;

    double varianceSum = 0;
    for (var amt in amounts) {
      varianceSum += pow(amt - mean, 2);
    }
    final stdDev = sqrt(varianceSum / amounts.length);
    final cv = stdDev / mean; // Coefficient of Variation

    if (cv <= 0.05) return 1.0; // Very stable (e.g. Salary, Rent)
    if (cv <= 0.20) return 0.8; // Stable (e.g. Electricity)
    if (cv <= 0.50) return 0.4; // Variable
    return 0.1;
  }

  double _calculateDepthScore(int count) {
    if (count < 3) return 0.0;
    if (count == 3) return 0.5;
    if (count == 4) return 0.7;
    if (count == 5) return 0.9;
    return 1.0;
  }
}
