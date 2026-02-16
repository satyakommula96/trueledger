import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:trueledger/data/repositories/financial_repository_impl.dart';
import 'package:trueledger/data/datasources/database.dart';
import 'package:trueledger/domain/models/transaction_tag.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Transaction Tag Persistence', () {
    late FinancialRepositoryImpl repo;
    late Directory tempDir;

    setUpAll(() async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      tempDir = await Directory.systemTemp.createTemp('tag_repo_test_');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (message) async {
          if (message.method == 'getApplicationDocumentsDirectory') {
            return tempDir.path;
          }
          return null;
        },
      );
    });

    tearDownAll(() async {
      await AppDatabase.close();
      if (tempDir.existsSync()) {
        try {
          tempDir.deleteSync(recursive: true);
        } catch (_) {}
      }
    });

    setUp(() async {
      repo = FinancialRepositoryImpl();
      await AppDatabase.clearData();
    });

    test('addEntry saves explicit tags correctly', () async {
      await repo.addEntry('Fixed', 500.0, 'EMI', 'Note', DateTime(2024, 2, 1),
          tags: {TransactionTag.loanEmi});

      final items = await repo.getTransactionsForRange(
          DateTime(2024, 02, 01), DateTime(2024, 02, 01));
      expect(items.first.tags, contains(TransactionTag.loanEmi));
    });

    test('addEntry applies default tags when none provided', () async {
      // Income should default to 'income'
      await repo.addEntry('Income', 5000.0, 'Salary', '', DateTime(2024, 2, 1));
      // Fixed should default to 'transfer'
      await repo.addEntry('Fixed', 1000.0, 'Rent', '', DateTime(2024, 2, 1));

      final items = await repo.getTransactionsForRange(
          DateTime(2024, 02, 01), DateTime(2024, 02, 01));

      final income = items.firstWhere((i) => i.amount == 5000.0);
      final expense = items.firstWhere((i) => i.amount == 1000.0);

      expect(income.tags, contains(TransactionTag.income));
      expect(expense.tags, contains(TransactionTag.transfer));
    });

    test('updateEntryTags modifies tags of existing transaction', () async {
      await repo.addEntry(
          'Variable', 100.0, 'Food', 'Dinner', DateTime(2024, 2, 1));
      var items = await repo.getTransactionsForRange(
          DateTime(2024, 02, 01), DateTime(2024, 02, 01));
      final originalId = items.first.id;

      expect(items.first.tags, contains(TransactionTag.transfer)); // Default

      // Update to loanFee
      await repo
          .updateEntryTags('Variable', originalId, {TransactionTag.loanFee});

      items = await repo.getTransactionsForRange(
          DateTime(2024, 02, 01), DateTime(2024, 02, 01));
      expect(items.first.tags, contains(TransactionTag.loanFee));
      expect(items.first.tags, isNot(contains(TransactionTag.transfer)));
    });

    test('updateEntryTags handles different tables correctly', () async {
      // Test the switch logic in repo.updateEntryTags
      await repo.addEntry('Fixed', 1000.0, 'Rent', '', DateTime(2024, 2, 1));
      await repo.addEntry('Income', 5000.0, 'Salary', '', DateTime(2024, 2, 1));

      final items = await repo.getTransactionsForRange(
          DateTime(2024, 02, 01), DateTime(2024, 02, 01));
      final fixedItem = items.firstWhere((i) => i.label == 'Rent');
      final incomeItem = items.firstWhere((i) => i.label == 'Salary');

      await repo
          .updateEntryTags('Fixed', fixedItem.id, {TransactionTag.loanEmi});
      await repo.updateEntryTags('Income', incomeItem.id,
          {TransactionTag.income, TransactionTag.loanEmi});

      final updated = await repo.getTransactionsForRange(
          DateTime(2024, 02, 01), DateTime(2024, 02, 01));
      expect(updated.firstWhere((i) => i.label == 'Rent').tags,
          contains(TransactionTag.loanEmi));
      expect(updated.firstWhere((i) => i.label == 'Salary').tags,
          containsAll([TransactionTag.income, TransactionTag.loanEmi]));
    });
  });
}
