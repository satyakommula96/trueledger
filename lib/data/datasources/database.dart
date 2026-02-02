import 'dart:io';
import 'package:sqflite_sqlcipher/sqflite.dart' as sqlcipher;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart' as sqflite_web;
import 'package:sqflite_common/sqlite_api.dart' as common;
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'schema.dart';
import 'database_migrations.dart';
import 'package:trueledger/core/config/version.dart';

import 'package:trueledger/core/config/app_config.dart';

class AppDatabase {
  static common.Database? _db;
  static Future<common.Database>? _initializationInstance;
  static const _storage = FlutterSecureStorage();
  static const _keyParams = 'db_key';

  static bool get _isTest =>
      AppConfig.isIntegrationTest ||
      (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST'));

  static Future<common.Database> get db async {
    if (_db != null) return _db!;
    _initializationInstance ??= _initDb();
    _db = await _initializationInstance;
    return _db!;
  }

  static Future<String> getEncryptionKey() async => _getOrGenerateKey();

  static Future<String> _getOrGenerateKey() async {
    // Return a dummy key for testing to avoid KeyChain hangs
    if (_isTest) {
      debugPrint('TEST MODE: Using dummy database key.');
      return 'dummy_test_key_integration_mode_123';
    }

    try {
      String? key = await _storage.read(key: _keyParams);
      if (key == null) {
        final random = Random.secure();
        final values = List<int>.generate(32, (i) => random.nextInt(256));
        key = base64UrlEncode(values);
        await _storage.write(key: _keyParams, value: key);
      }
      return key;
    } catch (e, stack) {
      debugPrint("SECURE STORAGE FAILURE: $e");
      if (kDebugMode) {
        debugPrint(stack.toString());
        // Fail loudly in debug to alert the developer
        throw Exception(
            "CRITICAL: Secure Storage failed in Debug Mode: $e\n$stack");
      }
      // Fallback for production if secure storage fails (ALLOWS APP TO OPEN)
      return 'fallback_dev_key_DO_NOT_USE_IN_PROD';
    }
  }

  static Future<common.Database> _initDb() async {
    // Use Application Documents Directory for reliable storage on Linux/Desktop
    String path;
    if (kIsWeb) {
      path = 'tracker_enc_v${AppVersion.databaseVersion}.db';
    } else {
      final docsDir = await getApplicationDocumentsDirectory();
      path =
          join(docsDir.path, 'tracker_enc_v${AppVersion.databaseVersion}.db');
    }

    debugPrint('Initializing database at: $path');

    final key = await _getOrGenerateKey();

    if (kIsWeb) {
      try {
        return await sqflite_web.databaseFactoryFfiWeb.openDatabase(
          path,
          options: common.OpenDatabaseOptions(
              version: AppVersion.databaseVersion,
              onConfigure: (db) async {
                // No encryption for Web for now
                debugPrint('Web database initialized.');
              },
              onCreate: (db, version) async {
                await _createDb(db);
                debugPrint('Database tables created successfully.');
              },
              onUpgrade: (db, oldVersion, newVersion) async {
                await _upgradeDb(db, oldVersion, newVersion);
              }),
        );
      } catch (e) {
        debugPrint(
            'CRITICAL: Web database open failed ($e). Attempting recovery...');
        if (kDebugMode) rethrow;
        return await _handleDatabaseReset(path, key, isDesktop: false);
      }
    } else if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      try {
        return await sqflite_ffi.databaseFactoryFfi.openDatabase(
          path,
          options: common.OpenDatabaseOptions(
              version: AppVersion.databaseVersion,
              onConfigure: (db) async {
                // Verify SQLCipher support before applying key
                // Bypass this in unit/integration tests
                if (_isTest) {
                  debugPrint('Skipping desktop encryption check in Test Mode.');
                } else {
                  bool isEncrypted = false;
                  try {
                    // Check if SQLCipher is available
                    final result = await db.rawQuery('PRAGMA cipher_version;');
                    if (result.isEmpty || result.first.values.first == null) {
                      if (kDebugMode && !kIsWeb) {
                        debugPrint(
                            'WARNING: SQLCipher not detected. Falling back to unencrypted SQLite for development.');
                      } else {
                        throw Exception(
                            'SQLCipher not detected. Your build may be using vanilla SQLite. '
                            'Encryption is MANDATORY for privacy compliance.');
                      }
                    } else {
                      isEncrypted = true;
                      // Apply the key only if SQLCipher is available
                      await db.execute("PRAGMA key = '$key';");
                    }

                    // Validation: Try a simple query that requires a valid key/encryption setup
                    await db.rawQuery('SELECT count(*) FROM sqlite_master;');

                    if (isEncrypted) {
                      debugPrint(
                          'Desktop SQLCipher encryption verified and active on ${kIsWeb ? "Web" : Platform.operatingSystem}.');
                    } else {
                      debugPrint(
                          'Running in UNENCRYPTED mode (Development Fallback).');
                    }
                  } catch (e) {
                    debugPrint('CRITICAL: Database encryption failure: $e');
                    // Re-throw to prevent the app from starting with unencrypted data
                    rethrow;
                  }
                }
              },
              onCreate: (db, version) async {
                await _createDb(db);
                debugPrint('Database tables created successfully.');
              },
              onUpgrade: (db, oldVersion, newVersion) async {
                await _upgradeDb(db, oldVersion, newVersion);
              }),
        );
      } catch (e) {
        debugPrint(
            'CRITICAL: Desktop database open failed ($e). Attempting recovery...');
        if (kDebugMode) rethrow;
        return await _handleDatabaseReset(path, key, isDesktop: true);
      }
    } else {
      // Android / iOS / macOS
      try {
        final db = await sqlcipher.openDatabase(
          path,
          password: key, // ENCRYPTION ENABLED
          version: AppVersion.databaseVersion,
          onCreate: (db, _) async {
            await _createDb(db);
            debugPrint('Database tables created successfully.');
          },
          onUpgrade: (db, old, newV) => _upgradeDb(db, old, newV),
        );
        debugPrint(
            'Secure SQLCipher database opened successfully on ${kIsWeb ? "Web" : Platform.operatingSystem}.');
        return db;
      } catch (e) {
        debugPrint(
            'CRITICAL: ${kIsWeb ? "Web" : Platform.operatingSystem} database open failed ($e). Attempting recovery...');
        if (kDebugMode) rethrow;
        return await _handleDatabaseReset(path, key,
            isDesktop: !kIsWeb &&
                (Platform.isWindows || Platform.isLinux || Platform.isMacOS));
      }
    }
  }

  static Future<common.Database> _handleDatabaseReset(String path, String key,
      {required bool isDesktop}) async {
    if (!kIsWeb) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
          debugPrint('Corrupted database file deleted at: $path');
        }
      } catch (delErr) {
        debugPrint('Failed to delete database file: $delErr');
      }
    }

    if (kIsWeb) {
      return await sqflite_web.databaseFactoryFfiWeb.openDatabase(
        path,
        options: common.OpenDatabaseOptions(
            version: AppVersion.databaseVersion,
            onCreate: (db, version) => _createDb(db),
            onUpgrade: (db, old, newV) => _upgradeDb(db, old, newV)),
      );
    } else if (isDesktop) {
      return await sqflite_ffi.databaseFactoryFfi.openDatabase(
        path,
        options: common.OpenDatabaseOptions(
            version: AppVersion.databaseVersion,
            onConfigure: (db) async {
              // Verify cipher support before applying key in recovery too
              final result = await db.rawQuery('PRAGMA cipher_version;');
              if (result.isNotEmpty && result.first.values.first != null) {
                await db.execute("PRAGMA key = '$key';");
              }
            },
            onCreate: (db, version) => _createDb(db),
            onUpgrade: (db, old, newV) => _upgradeDb(db, old, newV)),
      );
    } else {
      return await sqlcipher.openDatabase(
        path,
        password: key,
        version: AppVersion.databaseVersion,
        onCreate: (db, _) => _createDb(db),
        onUpgrade: (db, old, newV) => _upgradeDb(db, old, newV),
      );
    }
  }

  static Future<void> _createDb(common.DatabaseExecutor db) async {
    await db.execute(
        'CREATE TABLE ${Schema.incomeSourcesTable} (${Schema.colId} INTEGER PRIMARY KEY AUTOINCREMENT, ${Schema.colSource} TEXT, ${Schema.colAmount} INTEGER, ${Schema.colDate} TEXT)');
    await db.execute(
        'CREATE TABLE ${Schema.fixedExpensesTable} (${Schema.colId} INTEGER PRIMARY KEY AUTOINCREMENT, ${Schema.colName} TEXT, ${Schema.colAmount} INTEGER, ${Schema.colCategory} TEXT, ${Schema.colDate} TEXT)');
    await db.execute(
        'CREATE TABLE ${Schema.variableExpensesTable} (${Schema.colId} INTEGER PRIMARY KEY AUTOINCREMENT, ${Schema.colDate} TEXT, ${Schema.colAmount} INTEGER, ${Schema.colCategory} TEXT, ${Schema.colNote} TEXT)');
    await db.execute(
        'CREATE TABLE ${Schema.investmentsTable} (${Schema.colId} INTEGER PRIMARY KEY AUTOINCREMENT, ${Schema.colName} TEXT, ${Schema.colAmount} INTEGER, ${Schema.colActive} INTEGER, ${Schema.colType} TEXT, ${Schema.colDate} TEXT)');
    await db.execute(
        'CREATE TABLE ${Schema.subscriptionsTable} (${Schema.colId} INTEGER PRIMARY KEY AUTOINCREMENT, ${Schema.colName} TEXT, ${Schema.colAmount} INTEGER, ${Schema.colBillingDate} TEXT, ${Schema.colActive} INTEGER, ${Schema.colDate} TEXT)');
    await db.execute(
        'CREATE TABLE ${Schema.retirementContributionsTable} (${Schema.colId} INTEGER PRIMARY KEY AUTOINCREMENT, ${Schema.colType} TEXT, ${Schema.colAmount} INTEGER, ${Schema.colDate} TEXT)');
    await db.execute('''
          CREATE TABLE ${Schema.creditCardsTable} (
            ${Schema.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${Schema.colBank} TEXT,
            ${Schema.colCreditLimit} INTEGER,
            ${Schema.colStatementBalance} INTEGER,
            ${Schema.colMinDue} INTEGER,
            ${Schema.colDueDate} TEXT,
            ${Schema.colStatementDate} TEXT
          )
        ''');
    await db.execute('''
          CREATE TABLE ${Schema.loansTable} (
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
    await db.execute(
        'CREATE TABLE ${Schema.savingGoalsTable} (${Schema.colId} INTEGER PRIMARY KEY AUTOINCREMENT, ${Schema.colName} TEXT, ${Schema.colTargetAmount} INTEGER, ${Schema.colCurrentAmount} INTEGER)');
    await db.execute(
        'CREATE TABLE ${Schema.budgetsTable} (${Schema.colId} INTEGER PRIMARY KEY AUTOINCREMENT, ${Schema.colCategory} TEXT, ${Schema.colMonthlyLimit} INTEGER)');
    await db.execute(
        'CREATE TABLE ${Schema.customCategoriesTable} (${Schema.colId} INTEGER PRIMARY KEY AUTOINCREMENT, ${Schema.colName} TEXT, ${Schema.colType} TEXT)');
  }

  static Future<void> _upgradeDb(
      common.DatabaseExecutor db, int oldVersion, int newVersion) async {
    final database = db as common.Database;
    for (var migration in appMigrations) {
      if (migration.version > oldVersion && migration.version <= newVersion) {
        try {
          await migration.up(database);
          debugPrint(
              'Successfully applied migration to version ${migration.version}');
        } catch (e) {
          debugPrint('Migration failed for version ${migration.version}: $e');
          // In production, we might want to handle this more strictly (e.g. backup/restore)
          rethrow;
        }
      }
    }
  }

  static Future<void> clearData() async {
    final database = await db;
    await database.delete(Schema.incomeSourcesTable);
    await database.delete(Schema.fixedExpensesTable);
    await database.delete(Schema.variableExpensesTable);
    await database.delete(Schema.investmentsTable);
    await database.delete(Schema.subscriptionsTable);
    await database.delete(Schema.retirementContributionsTable);
    await database.delete(Schema.creditCardsTable);
    await database.delete(Schema.loansTable);
    await database.delete(Schema.savingGoalsTable);
    await database.delete(Schema.budgetsTable);
    await database.delete(Schema.customCategoriesTable);
  }

  static Future<void> seedDummyData() async {
    if (!kDebugMode) return;
    await clearData(); // Ensure fresh start
    final database = await db;
    final now = DateTime.now();
    final batch = database.batch();

    // 1. Static Configuration (Budgets & Goals) - These remain constant
    batch.insert(Schema.budgetsTable,
        {Schema.colCategory: 'Food', Schema.colMonthlyLimit: 25000});
    batch.insert(Schema.budgetsTable,
        {Schema.colCategory: 'Transport', Schema.colMonthlyLimit: 15000});
    batch.insert(Schema.budgetsTable,
        {Schema.colCategory: 'Shopping', Schema.colMonthlyLimit: 30000});
    batch.insert(Schema.budgetsTable,
        {Schema.colCategory: 'Entertainment', Schema.colMonthlyLimit: 10000});

    batch.insert(Schema.savingGoalsTable, {
      Schema.colName: 'Europe Trip',
      Schema.colTargetAmount: 800000,
      Schema.colCurrentAmount: 350000
    });
    batch.insert(Schema.savingGoalsTable, {
      Schema.colName: 'Emergency Fund',
      Schema.colTargetAmount: 1000000,
      Schema.colCurrentAmount: 600000
    });

    // 2. Current Assets/Liabilities Snapshot (Investments, Loans, Credit Cards)
    // Investments
    batch.insert(Schema.investmentsTable, {
      Schema.colName: 'Reliance Industries',
      Schema.colAmount: 520000,
      Schema.colActive: 1,
      Schema.colType: 'Equity / Stocks',
      Schema.colDate: now.toIso8601String()
    });
    batch.insert(Schema.investmentsTable, {
      Schema.colName: 'HDFC Mid Cap Fund',
      Schema.colAmount: 350000,
      Schema.colActive: 1,
      Schema.colType: 'Mutual Fund',
      Schema.colDate: now.toIso8601String()
    });
    batch.insert(Schema.investmentsTable, {
      Schema.colName: 'Sovereign Gold Bond',
      Schema.colAmount: 210000,
      Schema.colActive: 1,
      Schema.colType: 'Gold / Commodity',
      Schema.colDate: now.toIso8601String()
    });

    // Individual Lending (Personal Asset)
    batch.insert(Schema.investmentsTable, {
      Schema.colName: 'Personal Loan to Rahul',
      Schema.colAmount: 50000,
      Schema.colActive: 1,
      Schema.colType: 'Lending',
      Schema.colDate: now.toIso8601String()
    });

    // Retirement
    batch.insert(Schema.retirementContributionsTable, {
      Schema.colType: 'NPS',
      Schema.colAmount: 150000,
      Schema.colDate: now.toIso8601String()
    });
    batch.insert(Schema.retirementContributionsTable, {
      Schema.colType: 'EPF',
      Schema.colAmount: 850000,
      Schema.colDate: now.toIso8601String()
    });

    // Loans
    batch.insert(Schema.loansTable, {
      Schema.colName: 'Home Loan (SBI)',
      Schema.colLoanType: 'Home',
      Schema.colTotalAmount: 8500000,
      Schema.colRemainingAmount: 6200000,
      Schema.colEmi: 65000,
      Schema.colInterestRate: 8.4,
      Schema.colDueDate: '5th',
      Schema.colDate: now.toIso8601String()
    });
    batch.insert(Schema.loansTable, {
      Schema.colName: 'Personal Loan',
      Schema.colLoanType: 'Bank',
      Schema.colTotalAmount: 500000,
      Schema.colRemainingAmount: 220000,
      Schema.colEmi: 18500,
      Schema.colInterestRate: 11.5,
      Schema.colDueDate: '12th',
      Schema.colDate: now.toIso8601String()
    });

    // Individual Borrowing (Personal Liability)
    batch.insert(Schema.loansTable, {
      Schema.colName: 'Borrowed from Amit',
      Schema.colLoanType: 'Individual',
      Schema.colTotalAmount: 25000,
      Schema.colRemainingAmount: 15000,
      Schema.colEmi: 2000,
      Schema.colInterestRate: 0.0,
      Schema.colDueDate: '1st',
      Schema.colDate: now.toIso8601String()
    });

    // Credit Cards
    batch.insert(Schema.creditCardsTable, {
      Schema.colBank: 'HDFC Infinia',
      Schema.colCreditLimit: 1500000,
      Schema.colStatementBalance: 87000,
      Schema.colMinDue: 0,
      Schema.colDueDate: DateFormat('dd-MM-yyyy')
          .format(DateTime(now.year, now.month + 1, 12)),
      Schema.colStatementDate: 'Day 18'
    });
    batch.insert(Schema.creditCardsTable, {
      Schema.colBank: 'Amex Platinum',
      Schema.colCreditLimit: 1000000,
      Schema.colStatementBalance: 12500,
      Schema.colMinDue: 0,
      Schema.colDueDate: DateFormat('dd-MM-yyyy')
          .format(DateTime(now.year, now.month + 1, 24)),
      Schema.colStatementDate: 'Day 2'
    });

    // Subscriptions (Active List)
    final subs = [
      {'name': 'Netflix Premium', 'amt': 649, 'day': 2},
      {'name': 'ChatGPT Plus', 'amt': 1950, 'day': 8},
      {'name': 'Spotify Family', 'amt': 199, 'day': 15},
      {'name': 'AWS Cloud Hosting', 'amt': 12500, 'day': 5},
      {'name': 'Bloomberg Terminal', 'amt': 22000, 'day': 12},
    ];
    for (var s in subs) {
      batch.insert(Schema.subscriptionsTable, {
        Schema.colName: s['name'],
        Schema.colAmount: s['amt'],
        Schema.colActive: 1,
        Schema.colBillingDate: s['day'].toString(),
        Schema.colDate: now.toIso8601String()
      });
    }

    // 3. Historical & Future Data Generation
    // We will generate data for 3 months in the future and 24 months in the past
    final random = Random();
    final categories = [
      'Food',
      'Transport',
      'Shopping',
      'Utility',
      'Entertainment',
      'Travel',
      'Medical',
      'Education'
    ];

    for (int i = -3; i < 24; i++) {
      // Calculate reference date for this month (Start of month)
      // i=-3 is 3 months in future, i=0 is current month, i=1 is previous month...
      final monthDate = DateTime(now.year, now.month - i, 1);
      final isFuture = i < 0;

      // --- Income ---
      // Primary Salary (Steady)
      batch.insert(Schema.incomeSourcesTable, {
        Schema.colSource: 'Product Director Salary',
        Schema.colAmount: 450000,
        Schema.colDate:
            DateTime(monthDate.year, monthDate.month, 1).toIso8601String()
      });

      // Rental Income (Steady)
      batch.insert(Schema.incomeSourcesTable, {
        Schema.colSource: 'Rental Income',
        Schema.colAmount: 85000,
        Schema.colDate:
            DateTime(monthDate.year, monthDate.month, 5).toIso8601String()
      });

      // Dividends (Quarterly: Jan, Apr, Jul, Oct)
      if ([1, 4, 7, 10].contains(monthDate.month)) {
        batch.insert(Schema.incomeSourcesTable, {
          Schema.colSource: 'Quarterly Dividends',
          Schema.colAmount: 15000 + random.nextInt(5000), // Variable dividend
          Schema.colDate:
              DateTime(monthDate.year, monthDate.month, 10).toIso8601String()
        });
      }

      // Bonus (Yearly: March)
      if (monthDate.month == 3) {
        batch.insert(Schema.incomeSourcesTable, {
          Schema.colSource: 'Annual Performance Bonus',
          Schema.colAmount: 1200000,
          Schema.colDate:
              DateTime(monthDate.year, monthDate.month, 31).toIso8601String()
        });
      }

      // --- Fixed Expenses ---
      batch.insert(Schema.fixedExpensesTable, {
        Schema.colName: 'Penthouse Rent',
        Schema.colAmount: 65000,
        Schema.colCategory: 'Housing',
        Schema.colDate:
            DateTime(monthDate.year, monthDate.month, 1).toIso8601String()
      });
      batch.insert(Schema.fixedExpensesTable, {
        Schema.colName: 'Car Lease (BMW)',
        Schema.colAmount: 35000,
        Schema.colCategory: 'Transport',
        Schema.colDate:
            DateTime(monthDate.year, monthDate.month, 5).toIso8601String()
      });
      batch.insert(Schema.fixedExpensesTable, {
        Schema.colName: 'Maid & Cook',
        Schema.colAmount: 12000,
        Schema.colCategory: 'Service',
        Schema.colDate:
            DateTime(monthDate.year, monthDate.month, 2).toIso8601String()
      });

      // Subscription Entries (Historical)
      for (var s in subs) {
        // Only if billing day exists in this month (simplified logic)
        batch.insert(Schema.fixedExpensesTable, {
          Schema.colName: s['name'],
          Schema.colAmount: s['amt'],
          Schema.colCategory: 'Subscription',
          Schema.colDate:
              DateTime(monthDate.year, monthDate.month, s['day'] as int)
                  .toIso8601String()
        });
      }

      // --- Variable Expenses ---
      // Distribute ~40-60 variable expenses per month
      int txCount = 40 + random.nextInt(20);

      // Inflate newer months slightly (lifestyle creep)
      double inflationFactor =
          1.0 - (i * 0.01); // 1% less spending per month back

      for (int j = 0; j < txCount; j++) {
        final day = 1 + random.nextInt(28); // Keep it safe within 1-28
        final cat = categories[random.nextInt(categories.length)];

        int baseAmount = 0;
        switch (cat) {
          case 'Food':
            baseAmount = 200 + random.nextInt(1500);
            break;
          case 'Transport':
            baseAmount = 100 + random.nextInt(800);
            break;
          case 'Shopping':
            baseAmount = 1000 + random.nextInt(8000);
            break;
          case 'Utility':
            baseAmount = 500 + random.nextInt(3000);
            break;
          case 'Entertainment':
            baseAmount = 800 + random.nextInt(4000);
            break;
          case 'Travel':
            baseAmount = 2000 + random.nextInt(15000);
            break;
          default:
            baseAmount = 500 + random.nextInt(1000);
        }

        // Apply "weekend splurge" logic roughly
        final txDate = DateTime(monthDate.year, monthDate.month, day);
        if (txDate.weekday == DateTime.saturday ||
            txDate.weekday == DateTime.sunday) {
          baseAmount = (baseAmount * 1.5).toInt();
        }

        batch.insert(Schema.variableExpensesTable, {
          Schema.colDate: txDate.toIso8601String(),
          Schema.colAmount: (baseAmount * inflationFactor).toInt(),
          Schema.colCategory: cat,
          Schema.colNote:
              '$cat at Place #${random.nextInt(99)}${isFuture ? " [PLANNED]" : ""}'
        });
      }
    }

    await batch.commit(noResult: true);
    debugPrint("Seeded 2 years of financial data successfully.");
  }

  static Future<void> seedHealthyProfile() async {
    if (!kDebugMode) return;
    await clearData();
    final database = await db;
    final now = DateTime.now();
    final batch = database.batch();

    // 1. High Income Profile
    batch.insert(Schema.incomeSourcesTable, {
      Schema.colSource: 'High Tech Salary',
      Schema.colAmount: 850000, // Very High Income
      Schema.colDate: now.toIso8601String()
    });
    batch.insert(Schema.incomeSourcesTable, {
      Schema.colSource: 'Side Business',
      Schema.colAmount: 120000,
      Schema.colDate: now.toIso8601String()
    });

    // 2. Controlled Expenses
    // Fixed
    batch.insert(Schema.fixedExpensesTable, {
      Schema.colName: 'Rent',
      Schema.colAmount: 45000,
      Schema.colCategory: 'Housing',
      Schema.colDate: now.toIso8601String()
    });

    // Some variable expenses
    for (int i = 0; i < 15; i++) {
      batch.insert(Schema.variableExpensesTable, {
        Schema.colDate: now.subtract(Duration(days: i * 2)).toIso8601String(),
        Schema.colAmount: 500 + (i * 100),
        Schema.colCategory: 'Food',
        Schema.colNote: 'Meal $i',
      });
    }

    // 3. Wealth Assets (Net Worth Builders)
    batch.insert(Schema.investmentsTable, {
      Schema.colName: 'Growth Fund',
      Schema.colAmount: 5000000, // 50L
      Schema.colActive: 1,
      Schema.colType: 'Mutual Fund',
      Schema.colDate: now.toIso8601String()
    });
    batch.insert(Schema.investmentsTable, {
      Schema.colName: 'Tech Stocks',
      Schema.colAmount: 2500000, // 25L
      Schema.colActive: 1,
      Schema.colType: 'Equity',
      Schema.colDate: now.toIso8601String()
    });

    // 4. Retirement
    batch.insert(Schema.retirementContributionsTable, {
      Schema.colType: 'EPF',
      Schema.colAmount: 1500000,
      Schema.colDate: now.toIso8601String()
    });

    await batch.commit(noResult: true);
  }

  static Future<void> seedAtRiskProfile() async {
    if (!kDebugMode) return;
    await clearData();
    final database = await db;
    final now = DateTime.now();
    final batch = database.batch();

    // 1. Low Income Profile
    batch.insert(Schema.incomeSourcesTable, {
      Schema.colSource: 'Freelance Gig',
      Schema.colAmount: 25000, // Loow Income
      Schema.colDate: now.toIso8601String()
    });

    // 2. High Expenses
    // Fixed
    batch.insert(Schema.fixedExpensesTable, {
      Schema.colName: 'Rent',
      Schema.colAmount: 35000,
      Schema.colCategory: 'Housing',
      Schema.colDate: now.toIso8601String()
    });

    batch.insert(Schema.fixedExpensesTable, {
      Schema.colName: 'Loan EMI',
      Schema.colAmount: 22000,
      Schema.colCategory: 'Loan',
      Schema.colDate: now.toIso8601String()
    });

    // Many variable expenses
    for (int i = 0; i < 30; i++) {
      batch.insert(Schema.variableExpensesTable, {
        Schema.colDate: now.subtract(Duration(days: i)).toIso8601String(),
        Schema.colAmount: 2000 + (i * 50),
        Schema.colCategory: 'Shopping',
        Schema.colNote: 'Splurge $i',
      });
    }

    // 3. Huge Liabilities (Debt Crisis)
    batch.insert(Schema.loansTable, {
      Schema.colName: 'Personal Loan',
      Schema.colLoanType: 'Bank',
      Schema.colTotalAmount: 1500000,
      Schema.colRemainingAmount: 1400000, // 14L Pending
      Schema.colEmi: 35000,
      Schema.colInterestRate: 14.5,
      Schema.colDueDate: '10th',
      Schema.colDate: now.toIso8601String()
    });

    batch.insert(Schema.creditCardsTable, {
      Schema.colBank: 'HDFC MoneyBack',
      Schema.colCreditLimit: 200000,
      Schema.colStatementBalance: 195000, // Maxed out
      Schema.colMinDue: 15000,
      Schema.colDueDate: '15th',
    });

    await batch.commit(noResult: true);
  }

  static Future<void> seedLargeData({int count = 5000}) async {
    if (!kDebugMode) return;
    await clearData();
    final database = await db;
    final now = DateTime.now();

    // 1. Basic Setup (Income etc)
    await database.insert(Schema.incomeSourcesTable, {
      Schema.colSource: 'Salary',
      Schema.colAmount: 300000,
      Schema.colDate: now.toIso8601String()
    });

    final categories = [
      'Food',
      'Transport',
      'Shopping',
      'Utility',
      'Entertainment',
      'Travel'
    ];

    final batch = database.batch();

    // 2. Generate large count of variable expenses
    final random = Random();
    for (int i = 0; i < count; i++) {
      // Spread over last 24 months
      final daysRandom = random.nextInt(365 * 2);
      final date = now.subtract(Duration(days: daysRandom));
      final cat = categories[random.nextInt(categories.length)];
      final amount = 100 + random.nextInt(5000);

      batch.insert(Schema.variableExpensesTable, {
        Schema.colDate: date.toIso8601String(),
        Schema.colAmount: amount,
        Schema.colCategory: cat,
        Schema.colNote: 'Large scale entry #$i',
      });

      // Execute in chunks to avoid memory issues with batch
      if (i % 500 == 0 && i > 0) {
        await batch.commit(noResult: true);
      }
    }
    await batch.commit(noResult: true);
    debugPrint("Seeded $count records for performance test.");
  }

  static Future<void> seedRoadmapData() async {
    if (!kDebugMode) return;
    await seedDummyData(); // Start with a rich base
    final database = await db;
    final now = DateTime.now();
    final batch = database.batch();

    // Ensure a 5-day streak (Today, Yesterday, ..., -4 days)
    for (int i = 0; i < 5; i++) {
      final date = now.subtract(Duration(days: i));
      batch.insert(Schema.variableExpensesTable, {
        Schema.colDate: date.toIso8601String(),
        Schema.colAmount: 500 + i * 100,
        Schema.colCategory: 'Food',
        Schema.colNote: 'Streak Builder Day ${5 - i}',
      });
    }

    // Add specific Budget statuses
    // 1. Safe (e.g., 20% used)
    batch.insert(Schema.budgetsTable, {
      Schema.colCategory: 'Services',
      Schema.colMonthlyLimit: 10000,
    });
    batch.insert(Schema.variableExpensesTable, {
      Schema.colDate: now.toIso8601String(),
      Schema.colAmount: 2000,
      Schema.colCategory: 'Services',
      Schema.colNote: 'Safe budget example',
    });

    // 2. Warning (>75%, e.g., 80%)
    batch.insert(Schema.budgetsTable, {
      Schema.colCategory: 'Medical',
      Schema.colMonthlyLimit: 5000,
    });
    batch.insert(Schema.variableExpensesTable, {
      Schema.colDate: now.toIso8601String(),
      Schema.colAmount: 4000,
      Schema.colCategory: 'Medical',
      Schema.colNote: 'Warning budget example',
    });

    // 3. Overspent (>100%, e.g., 120%)
    batch.insert(Schema.budgetsTable, {
      Schema.colCategory: 'Education',
      Schema.colMonthlyLimit: 2000,
    });
    batch.insert(Schema.variableExpensesTable, {
      Schema.colDate: now.toIso8601String(),
      Schema.colAmount: 2400,
      Schema.colCategory: 'Education',
      Schema.colNote: 'Overspent budget example',
    });

    // Searchable data for Phase 2
    batch.insert(Schema.variableExpensesTable, {
      Schema.colDate: now.toIso8601String(),
      Schema.colAmount: 9999,
      Schema.colCategory: 'Others',
      Schema.colNote: 'SECRET_CODE_SEARCH',
    });

    await batch.commit(noResult: true);
    debugPrint("Roadmap sample data seeded successfully.");
  }
}
