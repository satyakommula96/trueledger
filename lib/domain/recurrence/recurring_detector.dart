import 'recurrence_models.dart';

abstract class RecurringPatternDetector {
  RecurringDetectionResult detect({
    required List<Transaction> transactions,
    required DateTime referenceDate,
  });
}
