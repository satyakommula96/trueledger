import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:trueledger/data/datasources/database.dart';
import 'package:trueledger/data/datasources/schema.dart';
import 'package:trueledger/core/config/version.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String tempPath;
  MockPathProvider(this.tempPath);

  @override
  Future<String?> getApplicationDocumentsPath() async => tempPath;

  @override
  Future<String?> getTemporaryPath() async => tempPath;

  @override
  Future<String?> getApplicationSupportPath() async => tempPath;

  @override
  Future<String?> getLibraryPath() async => tempPath;

  @override
  Future<List<String>?> getExternalStoragePaths(
          {StorageDirectory? type}) async =>
      [tempPath];

  @override
  Future<String?> getExternalStoragePath() async => tempPath;

  @override
  Future<String?> getDownloadsPath() async => tempPath;

  @override
  Future<List<String>?> getExternalCachePaths() async => [tempPath];
}

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory tempDir;
  late MockPathProvider mockPathProvider;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('trueledger_db_test');
    mockPathProvider = MockPathProvider(tempDir.path);
    PathProviderPlatform.instance = mockPathProvider;
    await AppDatabase.close();
  });

  tearDown(() async {
    await AppDatabase.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Database Coverage Expansion', () {
    test('Should migrate legacy versioned database to stable filename',
        () async {
      final legacyName = 'tracker_enc_v${AppVersion.databaseVersion}.db';
      final legacyFile = File(join(tempDir.path, legacyName));

      final db = await openDatabase(legacyFile.path);
      await db.execute('CREATE TABLE legacy_check (id INTEGER PRIMARY KEY)');
      await db.insert('legacy_check', {'id': 1});
      await db.close();

      final stableFile = File(join(tempDir.path, 'trueledger_secure.db'));
      expect(await stableFile.exists(), isFalse);

      final appDb = await AppDatabase.db;

      expect(await stableFile.exists(), isTrue);
      final result = await appDb.query('legacy_check');
      expect(result.length, 1);
    });

    test('Should track migrations in the _migrations table', () async {
      final appDb = await AppDatabase.db;
      final migrations = await appDb.query(Schema.migrationsTable);
      expect(migrations, isNotEmpty);
      final hasCurrent = migrations
          .any((m) => m[Schema.colVersion] == AppVersion.databaseVersion);
      expect(hasCurrent, isTrue);
    });

    test('Should handle fallback path verification (Desktop)', () async {
      final dbPath = join(tempDir.path, 'fallback_test.db');
      final db = await openDatabase(dbPath);
      await db.execute('CREATE TABLE fallback_data (id INTEGER)');
      await db.close();

      // Test Desktop logic
      final key = await AppDatabase.getEncryptionKey();
      final desktopDb = await AppDatabase.handleMigrationFallback(dbPath, key,
          isDesktop: true);
      expect(desktopDb, isNotNull);
      await desktopDb.close();
    });

    test('Should handle migrateLegacyDatabases error gracefully', () async {
      await AppDatabase.migrateLegacyDatabases(
          '/invalid/path', '/invalid/target');
    });

    test('Should seed all profile types successfully', () async {
      await AppDatabase.seedDummyData();
      await AppDatabase.seedHealthyProfile();
      await AppDatabase.seedAtRiskProfile();
      await AppDatabase.seedLargeData(count: 10);
      await AppDatabase.seedRoadmapData();

      final appDb = await AppDatabase.db;
      final income = await appDb.query(Schema.incomeSourcesTable);
      expect(income, isNotEmpty);
    });

    test('clearData should remove all records', () async {
      await AppDatabase.seedDummyData();
      await AppDatabase.clearData();

      final appDb = await AppDatabase.db;
      final income = await appDb.query(Schema.incomeSourcesTable);
      expect(income, isEmpty);
    });

    test('getEncryptionKey should return consistent key in test mode',
        () async {
      final key1 = await AppDatabase.getEncryptionKey();
      final key2 = await AppDatabase.getEncryptionKey();
      expect(key1, key2);
      expect(key1, 'dummy_test_key_integration_mode_123');
    });
  });
}
