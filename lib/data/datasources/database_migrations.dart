import 'package:sqflite_common/sqlite_api.dart' as common;

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

final List<Migration> appMigrations = [];
