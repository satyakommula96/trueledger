import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:trueledger/data/repositories/financial_repository_impl.dart';
import 'package:trueledger/data/datasources/database.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FinancialRepositoryImpl Coverage Expansion', () {
    late FinancialRepositoryImpl repo;

    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

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
      await AppDatabase.clearData();
    });

    test('getMonthlySummary returns correct totals', () async {
      final now = DateTime.now();
      final monthStr = now.toIso8601String().substring(0, 7);

      await repo.addEntry('Income', 5000, 'Salary', 'Monthly', '$monthStr-01');
      await repo.addEntry('Variable', 1000, 'Food', 'Dinner', '$monthStr-02');
      await repo.addEntry('Fixed', 2000, 'Rent', 'Monthly', '$monthStr-03');
      await repo.addEntry(
          'Subscription', 500, 'Netflix', 'Monthly', '$monthStr-04');
      await repo.addEntry('Investment', 1500, 'Stocks', 'HDFC', '$monthStr-05');

      await repo.addLoan(
          'Home Loan', 'Bank', 100000, 80000, 5000, 8.5, '5th', '$monthStr-01');
      await repo.addCreditCard('HDFC', 50000, 10000, 500, '15th', '1st');

      final summary = await repo.getMonthlySummary();

      expect(summary.totalIncome, 5000);
      expect(summary.totalVariable, 1000);
      expect(summary.totalFixed, 2000);
      expect(summary.totalSubscriptions, 500);
      expect(summary.totalInvestments, 1500);
      expect(summary.loansTotal, 80000);
      expect(summary.creditCardDebt, 10000);
      expect(summary.totalMonthlyEMI, 5000);
    });

    test('getSpendingTrend and getAvailableYears', () async {
      final now = DateTime.now();
      final lastMonth = DateTime(now.year, now.month - 1, 1);
      final lastMonthStr = lastMonth.toIso8601String().substring(0, 7);

      await repo.addEntry('Income', 5000, 'Salary', '',
          '${now.toIso8601String().substring(0, 7)}-01');
      await repo.addEntry('Variable', 1000, 'Food', '',
          '${now.toIso8601String().substring(0, 7)}-02');
      await repo.addEntry('Variable', 2000, 'Shopping', '', '$lastMonthStr-01');

      final trend = await repo.getSpendingTrend();
      expect(trend.length, greaterThanOrEqualTo(1));

      final years = await repo.getAvailableYears();
      expect(years, contains(now.year));
    });

    test('getUpcomingBills returns all types', () async {
      await repo.addSubscription('Spotify', 199, '15');
      await repo.addCreditCard('Amex', 100000, 5000, 1000, '20th', '5th');
      await repo.addLoan(
          'Car Loan', 'Bank', 500000, 400000, 8000, 9.0, '10th', '2024-01-01');
      await repo.addLoan(
          'Amit', 'Individual', 10000, 7000, 500, 0, '1st', '2024-01-01');

      final bills = await repo.getUpcomingBills();
      expect(bills.any((b) => b['type'] == 'SUBSCRIPTION'), isTrue);
      expect(bills.any((b) => b['type'] == 'CREDIT DUE'), isTrue);
      expect(bills.any((b) => b['type'] == 'LOAN EMI'), isTrue);

      final borrowing = bills.firstWhere((b) => b['type'] == 'BORROWING DUE');
      expect(borrowing['amount'],
          7000); // Should use remaining_amount (7000) not emi (500)
    });

    test('Saving goals and loans CRUD', () async {
      await repo.addGoal('Trip', 50000);
      var goals = await repo.getSavingGoals();
      expect(goals.first.name, 'Trip');

      await repo.updateGoal(goals.first.id, 'Euro Trip', 60000, 5000);
      goals = await repo.getSavingGoals();
      expect(goals.first.name, 'Euro Trip');
      expect(goals.first.currentAmount, 5000);

      await repo.addLoan(
          'Old Loan', 'Personal', 1000, 500, 100, 10, '1', '2023-01-01');
      var loans = await repo.getLoans();
      await repo.updateLoan(
          loans.first.id, 'Renamed Loan', 'Bank', 1000, 400, 100, 10, '2');
      loans = await repo.getLoans();
      expect(loans.first.name, 'Renamed Loan');
    });

    test('getCreditCards and payCreditCardBill', () async {
      await repo.addCreditCard('BankA', 1000, 500, 100, '1', '1');
      var cards = await repo.getCreditCards();
      expect(cards.first.statementBalance, 500);

      await repo.payCreditCardBill(cards.first.id, 200);
      cards = await repo.getCreditCards();
      expect(cards.first.statementBalance, 300);
      expect(cards.first.minDue, 0); // 100 - 200 clamped to 0
    });

    test('getMonthDetails and getMonthlyHistory', () async {
      final now = DateTime.now();
      final monthStr = now.toIso8601String().substring(0, 7);

      await repo.addEntry('Variable', 100, 'Food', 'Test', '$monthStr-01');
      await repo.addEntry('Income', 500, 'Salary', '', '$monthStr-02');

      final details = await repo.getMonthDetails(monthStr);
      expect(details.length, 2);

      final history = await repo.getMonthlyHistory(now.year);
      expect(history, isNotEmpty);
      expect(history.first['month'], monthStr);
    });

    test('Budget CRUD and review', () async {
      await repo.addBudget('Coffee', 2000);
      var budgets = await repo.getBudgets();
      expect(budgets.any((b) => b.category == 'Coffee'), isTrue);

      final budgetId = budgets.firstWhere((b) => b.category == 'Coffee').id;
      await repo.updateBudget(budgetId, 3000);
      budgets = await repo.getBudgets();
      expect(budgets.firstWhere((b) => b.id == budgetId).monthlyLimit, 3000);

      await repo.markBudgetAsReviewed(budgetId);
      budgets = await repo.getBudgets();
      expect(budgets.firstWhere((b) => b.id == budgetId).lastReviewedAt,
          isNotNull);
    });

    test('deleteItem removes from correct table', () async {
      await repo.addBudget('Test', 1000);
      final budgets = await repo.getBudgets();
      final id = budgets.first.id;

      await repo.deleteItem('budgets', id);
      final list = await repo.getBudgets();
      expect(list.any((b) => b.id == id), isFalse);
    });

    test('getActiveStreak calculates correctly', () async {
      final now = DateTime.now();
      final today = now.toIso8601String().substring(0, 10);
      final yesterday = now
          .subtract(const Duration(days: 1))
          .toIso8601String()
          .substring(0, 10);

      await repo.addEntry('Variable', 10, 'Test', '', today);
      await repo.addEntry('Variable', 10, 'Test', '', yesterday);

      final streak = await repo.getActiveStreak();
      expect(streak, 2);
    });

    test('backup and restore', () async {
      await repo.addEntry('Variable', 123, 'BackupTest', '', '2024-01-01');
      final backup = await repo.generateBackup();

      await repo.clearData();
      expect((await repo.getAllValues('variable_expenses')), isEmpty);

      await repo.restoreBackup(backup);
      final restored = await repo.getAllValues('variable_expenses');
      expect(restored.first['amount'], 123);
    });
  });
}
