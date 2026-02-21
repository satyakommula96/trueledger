import 'package:sqflite_common/sqlite_api.dart' as common;

import 'schema.dart';

abstract class Migration {
  final int version;
  Migration(this.version);

  Future<void> up(common.DatabaseExecutor db);
  Future<void> down(common.DatabaseExecutor db);

  Future<void> addColumnSafe(common.DatabaseExecutor db, String table,
      String column, String type) async {
    final results = await db.rawQuery("PRAGMA table_info($table)");
    final columnExists = results.any((row) => row['name'] == column);
    if (!columnExists) {
      await db.execute("ALTER TABLE $table ADD COLUMN $column $type");
    }
  }
}

class MigrationV1 extends Migration {
  MigrationV1() : super(1);

  @override
  Future<void> up(common.DatabaseExecutor db) async {}

  @override
  Future<void> down(common.DatabaseExecutor db) async {}
}

class MigrationV2 extends Migration {
  MigrationV2() : super(2);

  @override
  Future<void> up(common.DatabaseExecutor db) async {
    await addColumnSafe(
        db, Schema.creditCardsTable, Schema.colStatementDate, "TEXT");
  }

  @override
  Future<void> down(common.DatabaseExecutor db) async {
    // SQLite doesn't support DROP COLUMN easily in older versions, skipping for now
  }
}

class MigrationV3 extends Migration {
  MigrationV3() : super(3);

  @override
  Future<void> up(common.DatabaseExecutor db) async {
    // Re-check for v2 column in case v2 migration skipped
    await addColumnSafe(
        db, Schema.creditCardsTable, Schema.colStatementDate, "TEXT");
  }

  @override
  Future<void> down(common.DatabaseExecutor db) async {}
}

class MigrationV4 extends Migration {
  MigrationV4() : super(4);

  @override
  Future<void> up(common.DatabaseExecutor db) async {
    await db.execute(
        'CREATE TABLE IF NOT EXISTS ${Schema.customCategoriesTable} (${Schema.colId} INTEGER PRIMARY KEY AUTOINCREMENT, ${Schema.colName} TEXT, ${Schema.colType} TEXT)');
  }

  @override
  Future<void> down(common.DatabaseExecutor db) async {}
}

class MigrationV5 extends Migration {
  MigrationV5() : super(5);

  @override
  Future<void> up(common.DatabaseExecutor db) async {
    // Ensure credit_cards table exists (in case it was somehow missed in older versions)
    await db.execute('''
          CREATE TABLE IF NOT EXISTS ${Schema.creditCardsTable} (
            ${Schema.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${Schema.colBank} TEXT,
            ${Schema.colCreditLimit} INTEGER,
            ${Schema.colStatementBalance} INTEGER,
            ${Schema.colMinDue} INTEGER,
            ${Schema.colDueDate} TEXT,
            ${Schema.colStatementDate} TEXT
          )
        ''');

    // Ensure loans table exists
    await db.execute('''
          CREATE TABLE IF NOT EXISTS ${Schema.loansTable} (
            ${Schema.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${Schema.colName} TEXT,
            ${Schema.colLoanType} TEXT,
            ${Schema.colTotalAmount} INTEGER,
            ${Schema.colRemainingAmount} INTEGER,
            ${Schema.colEmi} INTEGER,
            ${Schema.colInterestRate} REAL,
            ${Schema.colDueDate} TEXT,
            ${Schema.colDate} TEXT
          )
        ''');
  }

  @override
  Future<void> down(common.DatabaseExecutor db) async {}
}

class MigrationV6 extends Migration {
  MigrationV6() : super(6);

  @override
  Future<void> up(common.DatabaseExecutor db) async {
    await addColumnSafe(
        db, Schema.budgetsTable, Schema.colLastReviewedAt, "TEXT");
  }

  @override
  Future<void> down(common.DatabaseExecutor db) async {}
}

class MigrationV7 extends Migration {
  MigrationV7() : super(7);

  @override
  Future<void> up(common.DatabaseExecutor db) async {
    await addColumnSafe(
        db, Schema.loansTable, Schema.colLastPaymentDate, "TEXT");
  }

  @override
  Future<void> down(common.DatabaseExecutor db) async {}
}

class MigrationV8 extends Migration {
  MigrationV8() : super(8);

  @override
  Future<void> up(common.DatabaseExecutor db) async {
    await addColumnSafe(db, Schema.loansTable, Schema.colInterestEngineVersion,
        "INTEGER DEFAULT 1");
  }

  @override
  Future<void> down(common.DatabaseExecutor db) async {}
}

class MigrationV9 extends Migration {
  MigrationV9() : super(9);

  @override
  Future<void> up(common.DatabaseExecutor db) async {
    await db.execute('''
          CREATE TABLE IF NOT EXISTS ${Schema.loanAuditLogTable} (
            ${Schema.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${Schema.colLoanId} INTEGER,
            ${Schema.colDate} TEXT,
            ${Schema.colOpeningBalance} REAL,
            ${Schema.colInterestRate} REAL,
            ${Schema.colPaymentAmount} REAL,
            ${Schema.colDaysAccrued} INTEGER,
            ${Schema.colInterestAccrued} REAL,
            ${Schema.colPrincipalApplied} REAL,
            ${Schema.colClosingBalance} REAL,
            ${Schema.colEngineVersion} INTEGER,
            ${Schema.colType} TEXT
          )
        ''');
  }

  @override
  Future<void> down(common.DatabaseExecutor db) async {}
}

class MigrationV10 extends Migration {
  MigrationV10() : super(10);

  @override
  Future<void> up(common.DatabaseExecutor db) async {
    // 1. Add tags column to all transaction tables
    await addColumnSafe(db, Schema.incomeSourcesTable, Schema.colTags, "TEXT");
    await addColumnSafe(db, Schema.fixedExpensesTable, Schema.colTags, "TEXT");
    await addColumnSafe(
        db, Schema.variableExpensesTable, Schema.colTags, "TEXT");
    await addColumnSafe(db, Schema.investmentsTable, Schema.colTags, "TEXT");

    // 2. Legacy Migration: Auto-tag existing records (BEST EFFORT)
    // We mark everything as 'transfer' or 'income' by default if we can't be sure,
    // but we'll try to catch EMI/Payments based on previous heuristic keywords.
    // NOTE: Overwriting tags is safe here because legacy data had no 'tags' column.

    // Tag Income Sources
    await db.execute(
        "UPDATE ${Schema.incomeSourcesTable} SET ${Schema.colTags} = 'income' WHERE ${Schema.colTags} IS NULL");

    // Tag Fixed Expenses (Common for EMI)
    await db.execute('''
      UPDATE ${Schema.fixedExpensesTable} 
      SET ${Schema.colTags} = 'loanEmi' 
      WHERE ${Schema.colTags} IS NULL 
      AND (LOWER(${Schema.colName}) LIKE '%emi%' 
           OR LOWER(${Schema.colName}) LIKE '%payment%' 
           OR LOWER(${Schema.colName}) LIKE '%repayment%')
    ''');

    // Tag Variable Expenses (Prepayments / Fees)
    await db.execute('''
      UPDATE ${Schema.variableExpensesTable} 
      SET ${Schema.colTags} = 'loanPrepayment' 
      WHERE ${Schema.colTags} IS NULL 
      AND (LOWER(${Schema.colNote}) LIKE '%prepayment%' 
           OR LOWER(${Schema.colNote}) LIKE '%principal%')
    ''');

    await db.execute('''
      UPDATE ${Schema.variableExpensesTable} 
      SET ${Schema.colTags} = 'loanFee' 
      WHERE ${Schema.colTags} IS NULL 
      AND (LOWER(${Schema.colNote}) LIKE '%fee%' 
           OR LOWER(${Schema.colNote}) LIKE '%charge%')
    ''');

    // Default others to transfer to signify generic expense/movement
    await db.execute(
        "UPDATE ${Schema.fixedExpensesTable} SET ${Schema.colTags} = 'transfer' WHERE ${Schema.colTags} IS NULL");
    await db.execute(
        "UPDATE ${Schema.variableExpensesTable} SET ${Schema.colTags} = 'transfer' WHERE ${Schema.colTags} IS NULL");
    await db.execute(
        "UPDATE ${Schema.investmentsTable} SET ${Schema.colTags} = 'transfer' WHERE ${Schema.colTags} IS NULL");
  }

  @override
  Future<void> down(common.DatabaseExecutor db) async {}
}

final List<Migration> appMigrations = [
  MigrationV10(),
  MigrationV11(),
  MigrationV12(),
  MigrationV13(),
  MigrationV14(),
  MigrationV15(),
  MigrationV16(),
];

class MigrationV16 extends Migration {
  MigrationV16() : super(16);

  @override
  Future<void> up(common.DatabaseExecutor db) async {
    final tables = [
      Schema.incomeSourcesTable,
      Schema.fixedExpensesTable,
      Schema.variableExpensesTable,
    ];

    for (var table in tables) {
      await addColumnSafe(db, table, Schema.colOriginalAmount, "REAL");
      await addColumnSafe(db, table, Schema.colCurrencyCode, "TEXT");
      await addColumnSafe(db, table, Schema.colExchangeRate, "REAL");
    }
  }

  @override
  Future<void> down(common.DatabaseExecutor db) async {}
}

class MigrationV12 extends Migration {
  MigrationV12() : super(12);

  @override
  Future<void> up(common.DatabaseExecutor db) async {
    await db.execute('''
          CREATE TABLE IF NOT EXISTS ${Schema.recurringTransactionsTable} (
            ${Schema.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${Schema.colName} TEXT,
            ${Schema.colAmount} REAL,
            ${Schema.colCategory} TEXT,
            ${Schema.colType} TEXT,
            ${Schema.colFrequency} TEXT,
            ${Schema.colDayOfMonth} INTEGER,
            ${Schema.colDayOfWeek} INTEGER,
            ${Schema.colLastProcessed} TEXT,
            ${Schema.colActive} INTEGER DEFAULT 1
          )
        ''');
  }

  @override
  Future<void> down(common.DatabaseExecutor db) async {}
}

class MigrationV11 extends Migration {
  MigrationV11() : super(11);

  @override
  Future<void> up(common.DatabaseExecutor db) async {
    await addColumnSafe(db, Schema.creditCardsTable, Schema.colCurrentBalance,
        "REAL DEFAULT 0");
    // Initialize current_balance with statement_balance for existing records
    await db.execute(
        "UPDATE ${Schema.creditCardsTable} SET ${Schema.colCurrentBalance} = ${Schema.colStatementBalance}");
  }

  @override
  Future<void> down(common.DatabaseExecutor db) async {}
}

class MigrationV13 extends Migration {
  MigrationV13() : super(13);

  @override
  Future<void> up(common.DatabaseExecutor db) async {
    // Check and add Groceries
    final groceries = await db.query(Schema.customCategoriesTable,
        where: "${Schema.colName} = ? AND ${Schema.colType} = ?",
        whereArgs: ['Groceries', 'Variable']);
    if (groceries.isEmpty) {
      await db.insert(Schema.customCategoriesTable,
          {Schema.colName: 'Groceries', Schema.colType: 'Variable'});
    }

    // Check and add Medical
    final medical = await db.query(Schema.customCategoriesTable,
        where: "${Schema.colName} = ? AND ${Schema.colType} = ?",
        whereArgs: ['Medical', 'Variable']);
    if (medical.isEmpty) {
      await db.insert(Schema.customCategoriesTable,
          {Schema.colName: 'Medical', Schema.colType: 'Variable'});
    }
  }

  @override
  Future<void> down(common.DatabaseExecutor db) async {}
}

class MigrationV14 extends Migration {
  MigrationV14() : super(14);

  @override
  Future<void> up(common.DatabaseExecutor db) async {
    await addColumnSafe(db, Schema.customCategoriesTable, Schema.colOrderIndex,
        "INTEGER DEFAULT 0");
  }

  @override
  Future<void> down(common.DatabaseExecutor db) async {}
}

class MigrationV15 extends Migration {
  MigrationV15() : super(15);

  @override
  Future<void> up(common.DatabaseExecutor db) async {
    final Map<String, List<String>> defaults = {
      'Variable': [
        'Food',
        'Groceries',
        'Transport',
        'Medical',
        'Shopping',
        'Entertainment',
        'Others'
      ],
      'Fixed': ['Rent', 'Utility', 'Insurance', 'EMI'],
      'Investment': [
        'Stocks',
        'Mutual Funds',
        'SIP',
        'Crypto',
        'Gold',
        'Lending',
        'Retirement',
        'Other'
      ],
      'Income': ['Salary', 'Freelance', 'Dividends'],
      'Subscription': ['OTT', 'Software', 'Gym'],
    };

    for (var entry in defaults.entries) {
      final type = entry.key;
      for (var name in entry.value) {
        // Check if exists
        final existing = await db.query(Schema.customCategoriesTable,
            where: "${Schema.colName} = ? AND ${Schema.colType} = ?",
            whereArgs: [name, type]);

        if (existing.isEmpty) {
          await db.insert(Schema.customCategoriesTable, {
            Schema.colName: name,
            Schema.colType: type,
            Schema.colOrderIndex: 0,
          });
        }
      }
    }
  }

  @override
  Future<void> down(common.DatabaseExecutor db) async {}
}
