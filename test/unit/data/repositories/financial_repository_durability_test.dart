import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:trueledger/data/repositories/financial_repository_impl.dart';
import 'package:trueledger/data/datasources/database.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FinancialRepository Durability Tests', () {
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

    test('getCreditCards handles records with missing/null fields gracefully',
        () async {
      final db = await AppDatabase.db;

      // Manually insert a record with missing fields that are required by DTO
      // This mimics an old schema or a partial insert
      await db.execute('''
        INSERT INTO credit_cards (bank, credit_limit, statement_balance)
        VALUES ('Broken Card', 50000.0, 1000.0)
      ''');
      // Note: current_balance, min_due, due_date, statement_date are NOT provided
      // In the new schema they have defaults, but we want to ensure the DTO also handles it
      // if for some reason the database returned null (e.g. if DEFAULT was missing)

      final cards = await repo.getCreditCards();

      expect(cards.length, 1);
      final card = cards.first;
      expect(card.bank, 'Broken Card');
      expect(card.creditLimit, 50000.0);
      expect(card.statementBalance,
          1000.0); // Wait, I put 1000 in SQL but 10000 here? Typo in thought, let's fix.
      expect(card.currentBalance, 0.0); // Handled by default/DB
      expect(card.minDue, 0.0);
      expect(card.dueDate, '');
      expect(card.statementDate, '');
    });

    test('getLoans handles records with missing fields gracefully', () async {
      final db = await AppDatabase.db;

      // Minimal loan insert
      await db.execute('''
        INSERT INTO loans (name, loan_type, total_amount)
        VALUES ('Minimal Loan', 'Personal', 100000.0)
      ''');

      final loans = await repo.getLoans();

      expect(loans.length, 1);
      final loan = loans.first;
      expect(loan.name, 'Minimal Loan');
      expect(loan.loanType, 'Personal');
      expect(loan.totalAmount, 100000.0);
      expect(loan.remainingAmount, 0.0);
      expect(loan.emi, 0.0);
      expect(loan.interestRate, 0.0);
    });
  });
}
