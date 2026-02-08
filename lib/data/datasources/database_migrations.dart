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

final List<Migration> appMigrations = [
  MigrationV2(),
  MigrationV3(),
  MigrationV4(),
  MigrationV5(),
  MigrationV6(),
  MigrationV7(),
  MigrationV8(),
  MigrationV9(),
];
