import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/domain/recurrence/recurrence_models.dart';
import 'package:trueledger/domain/recurrence/deterministic_recurring_detector.dart';

void main() {
  late DeterministicRecurringDetector detector;
  final referenceDate = DateTime(2025, 6, 1);

  setUp(() {
    detector = DeterministicRecurringDetector();
  });

  test('detects perfect monthly salary', () {
    final transactions = [
      Transaction(
        id: '1',
        amount: 5000000,
        date: DateTime(2025, 1, 1),
        category: 'Income',
        merchant: 'Employer Corp',
      ),
      Transaction(
        id: '2',
        amount: 5000000,
        date: DateTime(2025, 2, 1),
        category: 'Income',
        merchant: 'Employer Corp',
      ),
      Transaction(
        id: '3',
        amount: 5000000,
        date: DateTime(2025, 3, 1),
        category: 'Income',
        merchant: 'Employer Corp',
      ),
      Transaction(
        id: '4',
        amount: 5000000,
        date: DateTime(2025, 4, 1),
        category: 'Income',
        merchant: 'Employer Corp',
      ),
    ];

    final result = detector.detect(
      transactions: transactions,
      referenceDate: referenceDate,
    );

    expect(result.patterns.length, 1);
    final salary = result.patterns.first;
    expect(salary.frequency, RecurrenceFrequency.monthly);
    expect(salary.typicalAmount, 5000000);
    expect(salary.confidenceScore, greaterThan(0.9));
    expect(salary.dayOfMonth, 1);
  });

  test('detects variable monthly bills', () {
    final transactions = [
      Transaction(
        id: '1',
        amount: 125000, // 1250
        date: DateTime(2025, 1, 5),
        category: 'Utilities',
        merchant: 'Power Co',
      ),
      Transaction(
        id: '2',
        amount: 140000, // 1400
        date: DateTime(2025, 2, 5),
        category: 'Utilities',
        merchant: 'Power Co',
      ),
      Transaction(
        id: '3',
        amount: 110000, // 1100
        date: DateTime(2025, 3, 4), // 1 day tolerance
        category: 'Utilities',
        merchant: 'Power Co',
      ),
    ];

    final result = detector.detect(
      transactions: transactions,
      referenceDate: referenceDate,
    );

    expect(result.patterns.length, 1);
    final bill = result.patterns.first;
    expect(bill.frequency, RecurrenceFrequency.monthly);
    expect(bill.confidenceScore,
        lessThan(0.9)); // Lower due to variable amount and depth=3
    expect(bill.confidenceScore, greaterThan(0.5));
  });

  test('does not detect patterns with insufficient data', () {
    final transactions = [
      Transaction(
        id: '1',
        amount: 100000,
        date: DateTime(2025, 1, 1),
        category: 'Dining',
      ),
      Transaction(
        id: '2',
        amount: 100000,
        date: DateTime(2025, 2, 1),
        category: 'Dining',
      ),
    ];

    final result = detector.detect(
      transactions: transactions,
      referenceDate: referenceDate,
    );

    expect(result.patterns, isEmpty);
  });

  test('ignores random noise', () {
    final transactions = [
      Transaction(
          id: '1', amount: 5000, date: DateTime(2025, 1, 1), category: 'Misc'),
      Transaction(
          id: '2',
          amount: 15000,
          date: DateTime(2025, 1, 12),
          category: 'Misc'),
      Transaction(
          id: '3', amount: 2000, date: DateTime(2025, 2, 3), category: 'Misc'),
      Transaction(
          id: '4', amount: 8000, date: DateTime(2025, 3, 20), category: 'Misc'),
    ];

    final result = detector.detect(
      transactions: transactions,
      referenceDate: referenceDate,
    );

    expect(result.patterns, isEmpty);
  });

  test('detects yearly recurring transactions', () {
    final transactions = [
      Transaction(
        id: '1',
        amount: 1500000,
        date: DateTime(2023, 5, 10),
        category: 'Insurance',
      ),
      Transaction(
        id: '2',
        amount: 1500000,
        date: DateTime(2024, 5, 10),
        category: 'Insurance',
      ),
      Transaction(
        id: '3',
        amount: 1500000,
        date: DateTime(2025, 5, 10),
        category: 'Insurance',
      ),
    ];

    final result = detector.detect(
      transactions: transactions,
      referenceDate: referenceDate,
    );

    expect(result.patterns.length, 1);
    expect(result.patterns.first.frequency, RecurrenceFrequency.yearly);
  });
}
