import 'package:sqflite/sqflite.dart' as sqflite;

abstract class Migration {
  final int version;
  Migration(this.version);

  Future<void> up(sqflite.Database db);
  Future<void> down(sqflite.Database db);
}

class MigrationV1 extends Migration {
  MigrationV1() : super(1);

  @override
  Future<void> up(sqflite.Database db) async {
    // Initial tables creation logic
    // This is handled in onCreate, but shown here for structure
  }

  @override
  Future<void> down(sqflite.Database db) async {
    // Drop tables if needed for rollback
  }
}

class MigrationV3 extends Migration {
  MigrationV3() : super(3);

  @override
  Future<void> up(sqflite.Database db) async {
    await db
        .execute("ALTER TABLE credit_cards ADD COLUMN generation_date TEXT");
  }

  @override
  Future<void> down(sqflite.Database db) async {
    // SQLite doesn't support DROP COLUMN easily, usually a table recreation is needed
  }
}

class MigrationV4 extends Migration {
  MigrationV4() : super(4);

  @override
  Future<void> up(sqflite.Database db) async {
    await db.execute("ALTER TABLE variable_expenses ADD COLUMN tags TEXT");
    await db.execute(
        'CREATE TABLE IF NOT EXISTS sys_config (key TEXT PRIMARY KEY, value TEXT)');
  }

  @override
  Future<void> down(sqflite.Database db) async {
    // Drop table if needed
  }
}

final List<Migration> appMigrations = [
  MigrationV3(),
  MigrationV4(),
];
