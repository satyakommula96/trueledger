import 'package:flutter_test/flutter_test.dart';
import 'package:truecash/data/repositories/financial_repository_impl.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Mock path_provider using the new API
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (message) async {
        if (message.method == 'getApplicationDocumentsDirectory') {
          return '.';
        }
        return null;
      },
    );
  });

  group('Performance Benchmarks (Large Dataset)', () {
    final repo = FinancialRepositoryImpl();

    test('Benchmark: Query performance with 5,000 transactions', () async {
      debugPrint('--- Starting Performance Benchmark ---');

      final seedStopwatch = Stopwatch()..start();
      await repo.seedLargeData(5000);
      seedStopwatch.stop();
      debugPrint(
          'Seeding 5,000 records took: ${seedStopwatch.elapsedMilliseconds}ms');

      // 1. Dashboard Summary
      final summaryStopwatch = Stopwatch()..start();
      await repo.getMonthlySummary();
      summaryStopwatch.stop();
      debugPrint(
          'getMonthlySummary took: ${summaryStopwatch.elapsedMilliseconds}ms');
      expect(summaryStopwatch.elapsedMilliseconds, lessThan(200),
          reason: 'Dashboard summary is too slow');

      // 2. Spending Trends
      final trendStopwatch = Stopwatch()..start();
      await repo.getSpendingTrend();
      trendStopwatch.stop();
      debugPrint(
          'getSpendingTrend (aggregating 5000 records) took: ${trendStopwatch.elapsedMilliseconds}ms');
      expect(trendStopwatch.elapsedMilliseconds, lessThan(100),
          reason: 'Spending trend aggregation is too slow');

      // 3. Category Spending
      final categoryStopwatch = Stopwatch()..start();
      await repo.getCategorySpending();
      categoryStopwatch.stop();
      debugPrint(
          'getCategorySpending took: ${categoryStopwatch.elapsedMilliseconds}ms');
      expect(categoryStopwatch.elapsedMilliseconds, lessThan(100),
          reason: 'Category spending aggregation is too slow');

      // 4. Monthly History (Complex aggregation)
      final historyStopwatch = Stopwatch()..start();
      final history = await repo.getMonthlyHistory();
      historyStopwatch.stop();
      debugPrint(
          'getMonthlyHistory (aggregating across multiple months) took: ${historyStopwatch.elapsedMilliseconds}ms');
      debugPrint('Total months in history: ${history.length}');
      expect(historyStopwatch.elapsedMilliseconds, lessThan(300),
          reason: 'Monthly history aggregation is too slow');

      // 5. Month Details (Filtering/Sorting)
      if (history.isNotEmpty) {
        final month = history.first['month'];
        final detailStopwatch = Stopwatch()..start();
        final details = await repo.getMonthDetails(month);
        detailStopwatch.stop();
        debugPrint(
            'getMonthDetails for $month (approx ${details.length} items) took: ${detailStopwatch.elapsedMilliseconds}ms');
        expect(detailStopwatch.elapsedMilliseconds, lessThan(100),
            reason: 'Month details query is too slow');
      }

      debugPrint('--- Performance Benchmark Completed ---');
    });
  });
}
