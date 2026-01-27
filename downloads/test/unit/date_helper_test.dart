import 'package:flutter_test/flutter_test.dart';
import 'package:trueledger/core/utils/date_helper.dart';

void main() {
  group('DateHelper.formatDue', () {
    test('formats "flexible"', () {
      expect(DateHelper.formatDue('flexible'), 'FLEXIBLE');
    });

    test('formats "recurring"', () {
      expect(DateHelper.formatDue('recurring'), 'RECURRING');
    });

    test('formats ISO date string', () {
      final now = DateTime.now();
      // Use a day that is definitely reachable this month or next
      final targetDate = DateTime(now.year, now.month, 15);
      final isoStr = targetDate.toIso8601String();

      final result = DateHelper.formatDue(isoStr);
      expect(result, contains('15'));
    });

    test('formats day numbers like "5th"', () {
      final result = DateHelper.formatDue('5th');
      expect(result, contains('05'));
    });

    test('formats full dates like "23 Jan 2026"', () {
      final result = DateHelper.formatDue('23 Jan 2026');
      expect(result, contains('23'));
    });
  });

  group('DateHelper.parseDue', () {
    test('parses ISO date', () {
      final date = DateTime(2026, 1, 23);
      final result = DateHelper.parseDue(date.toIso8601String());
      expect(result?.year, 2026);
      expect(result?.month, 1);
      expect(result?.day, 23);
    });

    test('parses day number string', () {
      final relative = DateTime(2026, 2, 1);
      final result = DateHelper.parseDue('10th', relativeTo: relative);
      expect(result?.year, 2026);
      expect(result?.month, 2);
      expect(result?.day, 10);
    });

    test('returns null for unparseable dates', () {
      expect(DateHelper.parseDue('invalid date'), isNull);
    });
  });
}
