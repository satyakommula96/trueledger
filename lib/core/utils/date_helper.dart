import 'package:intl/intl.dart';

class DateHelper {
  static String formatDue(String due, {String prefix = "DUE"}) {
    if (due.toLowerCase() == 'flexible') {
      return "FLEXIBLE";
    }
    if (due.toLowerCase() == 'recurring') {
      return "RECURRING";
    }

    final now = DateTime.now();
    int? day;

    // Try ISO parse first (e.g. 2026-01-23T...)
    try {
      final date = DateTime.parse(due);
      day = date.day;
    } catch (_) {
      // Try full date parse (e.g. "15 Jan 2026")
      try {
        final date = DateFormat('dd MMM yyyy').parse(due);
        day = date.day;
      } catch (_) {
        // Fallback: Remove non-digits for day number (e.g. "5th", "5")
        final clean = due.replaceAll(RegExp(r'[^0-9]'), '');
        if (clean.isNotEmpty) {
          // Only if it's a small number (1-31) representing a day, not a year
          if (clean.length <= 2) {
            day = int.tryParse(clean);
          }
        }
      }
    }

    if (day != null && day > 0 && day <= 31) {
      var next = DateTime(now.year, now.month, day);
      if (next.isBefore(DateTime(now.year, now.month, now.day))) {
        next = DateTime(now.year, now.month + 1, day);
      }
      return "$prefix: ${DateFormat('dd MMM').format(next).toUpperCase()}";
    }

    return "$due $prefix".toUpperCase();
  }

  static DateTime? parseDue(String due, {DateTime? relativeTo}) {
    final now = relativeTo ?? DateTime.now();

    // Try ISO first
    try {
      return DateTime.parse(due);
    } catch (_) {}

    // Try day number (e.g. "5", "5th")
    final clean = due.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isNotEmpty) {
      final day = int.tryParse(clean);
      if (day != null && day > 0 && day <= 31) {
        return DateTime(now.year, now.month, day);
      }
    }

    // Try "20th Jan" or "15 Feb 2026"
    try {
      final date = DateFormat('dd MMM yyyy').parse(due);
      // We likely want the day part applied to the specified month/year.
      return DateTime(now.year, now.month, date.day);
    } catch (_) {}

    return null;
  }
}
