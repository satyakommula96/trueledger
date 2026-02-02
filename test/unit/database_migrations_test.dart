import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:trueledger/data/datasources/database_migrations.dart';
import 'package:trueledger/data/datasources/schema.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Database Migrations', () {
    late Database db;

    setUp(() async {
      db = await openDatabase(inMemoryDatabasePath);
      // Create table for testing
      await db.execute('''
        CREATE TABLE ${Schema.creditCardsTable} (
          ${Schema.colId} INTEGER PRIMARY KEY
        )
      ''');
    });

    tearDown(() async {
      await db.close();
    });

    test('MigrationV2 should add statement date column', () async {
      final migration = MigrationV2();
      await migration.up(db);

      final results =
          await db.rawQuery("PRAGMA table_info(${Schema.creditCardsTable})");
      final hasColumn =
          results.any((row) => row['name'] == Schema.colStatementDate);
      expect(hasColumn, isTrue);
    });

    test('MigrationV3 should add statement date column safely', () async {
      final migration = MigrationV3();
      await migration.up(db);

      final results =
          await db.rawQuery("PRAGMA table_info(${Schema.creditCardsTable})");
      final hasColumn =
          results.any((row) => row['name'] == Schema.colStatementDate);
      expect(hasColumn, isTrue);
    });

    test('addColumnSafe should handle existing columns gracefully', () async {
      final migration = MigrationV2(); // Any migration will do

      // First add
      await migration.addColumnSafe(
          db, Schema.creditCardsTable, 'new_column', 'TEXT');

      // Second add (should not throw and should not add twice)
      await migration.addColumnSafe(
          db, Schema.creditCardsTable, 'new_column', 'TEXT');

      final results =
          await db.rawQuery("PRAGMA table_info(${Schema.creditCardsTable})");
      final matches = results.where((row) => row['name'] == 'new_column');
      expect(matches.length, 1);
    });

    test('MigrationV1 should do nothing in up and down', () async {
      final migration = MigrationV1();
      await migration.up(db);
      await migration.down(db);
      // No crash means success for empty migration
    });

    test('MigrationV4 should create custom_categories table', () async {
      final migration = MigrationV4();
      await migration.up(db);

      final results = await db
          .rawQuery("PRAGMA table_info(${Schema.customCategoriesTable})");
      expect(results, isNotEmpty);
      final hasNameColumn = results.any((row) => row['name'] == Schema.colName);
      final hasTypeColumn = results.any((row) => row['name'] == Schema.colType);
      expect(hasNameColumn, isTrue);
      expect(hasTypeColumn, isTrue);
    });

    test('MigrationV2, V3 and V4 down should not throw', () async {
      await MigrationV2().down(db);
      await MigrationV3().down(db);
      await MigrationV4().down(db);
    });
  });
}
