import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:trueledger/data/repositories/financial_repository_impl.dart';
import 'package:trueledger/data/datasources/database.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FinancialRepositoryImpl', () {
    late FinancialRepositoryImpl repo;

    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      // Mock path_provider
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

    setUp(() async {
      repo = FinancialRepositoryImpl();
      // Reset database by opening a fresh in-memory one or clearing tables
      // Actually AppDatabase uses a singleton and files.
      // For testing, we should probably follow what large_data_test does.
      await AppDatabase.clearData();
    });

    test('getBudgets calculates stability correctly', () async {
      final db = await AppDatabase.db;
      final now = DateTime.now();

      // Category 'Food' - Stable (under limit in last 3 months)
      await db.insert('budgets', {
        'id': 1,
        'category': 'Food',
        'monthly_limit': 1000,
      });

      // Category 'Rent' - Not Stable (over limit in one of last 3 months)
      await db.insert('budgets', {
        'id': 2,
        'category': 'Rent',
        'monthly_limit': 2000,
      });

      // Helper to insert expenses
      Future<void> insertExpense(String cat, int amount, DateTime date) async {
        await db.insert('variable_expenses', {
          'category': cat,
          'amount': amount,
          'date': date.toIso8601String(),
        });
      }

      // Last 3 completed months
      for (int i = 1; i <= 3; i++) {
        final monthDate = DateTime(now.year, now.month - i, 15);
        await insertExpense('Food', 500, monthDate); // Under 1000
        if (i == 2) {
          await insertExpense('Rent', 2500, monthDate); // Over 2000
        } else {
          await insertExpense('Rent', 1500, monthDate); // Under 2000
        }
      }

      final budgets = await repo.getBudgets();

      final foodBudget = budgets.firstWhere((b) => b.category == 'Food');
      final rentBudget = budgets.firstWhere((b) => b.category == 'Rent');

      expect(foodBudget.isStable, isTrue);
      expect(rentBudget.isStable, isFalse);
    });

    test('markBudgetAsReviewed updates the timestamp', () async {
      final db = await AppDatabase.db;
      await db.insert('budgets', {
        'id': 1,
        'category': 'Food',
        'monthly_limit': 1000,
      });

      await repo.markBudgetAsReviewed(1);

      final result = await db.query('budgets', where: 'id = 1');
      expect(result.first['last_reviewed_at'], isNotNull);
    });
  });
}
