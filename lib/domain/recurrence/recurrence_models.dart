enum RecurrenceFrequency {
  monthly,
  yearly,
  weekly,
  unknown,
}

class Transaction {
  final String id;
  final int amount; // in cents/paise
  final DateTime date;
  final String category;
  final String? merchant;
  final String? accountId;

  Transaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.category,
    this.merchant,
    this.accountId,
  });
}

class RecurringPattern {
  final String patternId;
  final int typicalAmount; // in cents/paise
  final RecurrenceFrequency frequency;
  final int dayOfMonth; // if monthly (1-31)
  final double confidenceScore; // 0.0 - 1.0
  final int occurrenceCount;

  RecurringPattern({
    required this.patternId,
    required this.typicalAmount,
    required this.frequency,
    required this.dayOfMonth,
    required this.confidenceScore,
    required this.occurrenceCount,
  });

  @override
  String toString() {
    return 'RecurringPattern(id: $patternId, amount: $typicalAmount, freq: $frequency, day: $dayOfMonth, confidence: ${confidenceScore.toStringAsFixed(2)}, count: $occurrenceCount)';
  }
}

class RecurringDetectionResult {
  final List<RecurringPattern> patterns;

  RecurringDetectionResult({required this.patterns});
}
