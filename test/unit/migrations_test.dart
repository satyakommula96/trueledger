import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:trueledger/data/datasources/database_migrations.dart';
import 'package:trueledger/data/datasources/schema.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Migrations Coverage', () {
    late Database db;

    setUp(() async {
      db = await openDatabase(inMemoryDatabasePath, version: 1,
          onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ${Schema.customCategoriesTable} (
            ${Schema.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${Schema.colName} TEXT,
            ${Schema.colType} TEXT
          )
        ''');
      });
    });

    tearDown(() async {
      await db.close();
    });

    test('MigrationV14 adds order_index column', () async {
      final migration = MigrationV14();
      await migration.up(db);

      // Verify column exists by querying it
      final result = await db.query(Schema.customCategoriesTable);
      expect(result, isEmpty);

      // Try to insert with the new column
      await db.insert(Schema.customCategoriesTable, {
        Schema.colName: 'Test',
        Schema.colType: 'Variable',
        Schema.colOrderIndex: 10,
      });

      final inserted = await db.query(Schema.customCategoriesTable);
      expect(inserted.first[Schema.colOrderIndex], 10);
    });

    test('MigrationV15 seeds missing categories', () async {
      // First ensure order_index exists (run v14)
      await MigrationV14().up(db);

      // Seed one existing category to test the "if not exists" logic
      await db.insert(Schema.customCategoriesTable, {
        Schema.colName: 'Food',
        Schema.colType: 'Variable',
        Schema.colOrderIndex: 0,
      });

      final migration = MigrationV15();
      await migration.up(db);

      final result = await db.query(Schema.customCategoriesTable);
      // Food should still be there, and many others should be added
      expect(result.length, greaterThan(10));

      final groceries = result.where((r) =>
          r[Schema.colName] == 'Groceries' && r[Schema.colType] == 'Variable');
      expect(groceries, isNotEmpty);
    });
  });
}
