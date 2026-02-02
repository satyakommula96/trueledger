import 'package:sqflite_common/sqlite_api.dart' as common;

import 'schema.dart';

abstract class Migration {
  final int version;
  Migration(this.version);

  Future<void> up(common.Database db);
  Future<void> down(common.Database db);

  Future<void> addColumnSafe(
      common.Database db, String table, String column, String type) async {
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
  Future<void> up(common.Database db) async {}

  @override
  Future<void> down(common.Database db) async {}
}

class MigrationV2 extends Migration {
  MigrationV2() : super(2);

  @override
  Future<void> up(common.Database db) async {
    await addColumnSafe(
        db, Schema.creditCardsTable, Schema.colStatementDate, "TEXT");
  }

  @override
  Future<void> down(common.Database db) async {
    // SQLite doesn't support DROP COLUMN easily in older versions, skipping for now
  }
}

class MigrationV3 extends Migration {
  MigrationV3() : super(3);

  @override
  Future<void> up(common.Database db) async {
    // Re-check for v2 column in case v2 migration skipped
    await addColumnSafe(
        db, Schema.creditCardsTable, Schema.colStatementDate, "TEXT");
  }

  @override
  Future<void> down(common.Database db) async {}
}

class MigrationV4 extends Migration {
  MigrationV4() : super(4);

  @override
  Future<void> up(common.Database db) async {
    await db.execute(
        'CREATE TABLE IF NOT EXISTS ${Schema.customCategoriesTable} (${Schema.colId} INTEGER PRIMARY KEY AUTOINCREMENT, ${Schema.colName} TEXT, ${Schema.colType} TEXT)');
  }

  @override
  Future<void> down(common.Database db) async {}
}

class MigrationV5 extends Migration {
  MigrationV5() : super(5);

  @override
  Future<void> up(common.Database db) async {
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
  Future<void> down(common.Database db) async {}
}

final List<Migration> appMigrations = [
  MigrationV2(),
  MigrationV3(),
  MigrationV4(),
  MigrationV5(),
];
