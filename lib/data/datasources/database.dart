import 'dart:io';
import 'package:sqflite_sqlcipher/sqflite.dart' as sqlcipher;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import 'dart:convert';
import 'schema.dart';
import 'database_migrations.dart';
import 'package:truecash/core/config/version.dart';

class AppDatabase {
  static sqlcipher.Database? _db;
  static Future<sqlcipher.Database>? _initializationInstance;
  static const _storage = FlutterSecureStorage();
  static const _keyParams = 'db_key';

  static Future<sqlcipher.Database> get db async {
    if (_db != null) return _db!;
    _initializationInstance ??= _initDb();
    _db = await _initializationInstance;
    return _db!;
  }

  static Future<String> _getOrGenerateKey() async {
    try {
      String? key = await _storage.read(key: _keyParams);
      if (key == null) {
        final random = Random.secure();
        final values = List<int>.generate(32, (i) => random.nextInt(256));
        key = base64UrlEncode(values);
        await _storage.write(key: _keyParams, value: key);
      }
      return key;
    } catch (e) {
      // Fallback for dev environment if secure storage fails (NOT FOR PROD)
      // This allows the app to open even if keyring is broken.
      return 'fallback_dev_key_DO_NOT_USE_IN_PROD';
    }
  }

  static Future<sqlcipher.Database> _initDb() async {
    // Use Application Documents Directory for reliable storage on Linux/Desktop
    final docsDir = await getApplicationDocumentsDirectory();
    final path = join(docsDir.path, 'tracker_enc_v11.db');

    // Ensure FFI is initialized for Desktop (safe to call multiple times)
    if (kIsWeb) {
      // Handle web factory if needed
    } else if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      sqflite.databaseFactory = databaseFactoryFfi;
    }

    final key = await _getOrGenerateKey();

    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      debugPrint(
          'WARNING: Using unencrypted database on Desktop due to missing SQLCipher FFI support.');
      return sqflite.databaseFactory.openDatabase(
        path,
        options: sqflite.OpenDatabaseOptions(
            version: AppVersion.databaseVersion,
            onCreate: (db, version) async {
              await _createDb(db);
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              await _upgradeDb(db, oldVersion, newVersion);
            }),
      );
    } else {
      return sqlcipher.openDatabase(
        path,
        password: key, // ENCRYPTION ENABLED
        version: AppVersion.databaseVersion,
        onCreate: (db, _) => _createDb(db),
        onUpgrade: (db, old, newV) => _upgradeDb(db, old, newV),
      );
    }
  }

  static Future<void> _createDb(sqflite.DatabaseExecutor db) async {
    await db.execute(
        'CREATE TABLE ${Schema.incomeSourcesTable} (${Schema.colId} INTEGER PRIMARY KEY AUTOINCREMENT, ${Schema.colSource} TEXT, ${Schema.colAmount} INTEGER, ${Schema.colDate} TEXT)');
    await db.execute(
        'CREATE TABLE ${Schema.fixedExpensesTable} (${Schema.colId} INTEGER PRIMARY KEY AUTOINCREMENT, ${Schema.colName} TEXT, ${Schema.colAmount} INTEGER, ${Schema.colCategory} TEXT, ${Schema.colDate} TEXT)');
    await db.execute(
        'CREATE TABLE ${Schema.variableExpensesTable} (${Schema.colId} INTEGER PRIMARY KEY AUTOINCREMENT, ${Schema.colDate} TEXT, ${Schema.colAmount} INTEGER, ${Schema.colCategory} TEXT, ${Schema.colNote} TEXT, ${Schema.colTags} TEXT)');
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
            ${Schema.colGenerationDate} TEXT
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

    // Automation & Settings Table (v4)
    await db
        .execute('CREATE TABLE sys_config (key TEXT PRIMARY KEY, value TEXT)');
  }

  static Future<void> _upgradeDb(
      sqflite.DatabaseExecutor db, int oldVersion, int newVersion) async {
    final database = db as sqflite.Database;
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
  }

  static Future<void> seedDummyData() async {
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

    // Credit Cards
    batch.insert(Schema.creditCardsTable, {
      Schema.colBank: 'HDFC Infinia',
      Schema.colCreditLimit: 1500000,
      Schema.colStatementBalance: 87000,
      Schema.colMinDue: 0,
      Schema.colDueDate: '12 Feb 2026',
      Schema.colGenerationDate: '23 Jan 2026'
    });
    batch.insert(Schema.creditCardsTable, {
      Schema.colBank: 'Amex Platinum',
      Schema.colCreditLimit: 1000000,
      Schema.colStatementBalance: 12500,
      Schema.colMinDue: 0,
      Schema.colDueDate: '24 Feb 2026',
      Schema.colGenerationDate: '05 Jan 2026'
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

    // 3. Historical Data Generation (Last 24 Months)
    // We will generate monthly data going back 2 years
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

    for (int i = 0; i < 24; i++) {
      // Calculate reference date for this month (Start of month)
      // i=0 is current month, i=1 is previous month...
      final monthDate = DateTime(now.year, now.month - i, 1);

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
          Schema.colNote: '$cat at Place #${random.nextInt(99)}',
          Schema.colTags: (j % 5 == 0) ? '#creditcard' : null
        });
      }
    }

    await batch.commit(noResult: true);
    debugPrint("Seeded 2 years of financial data successfully.");
  }

  static Future<void> seedLargeData({int count = 5000}) async {
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
        Schema.colTags: '#automated,#performance'
      });

      // Execute in chunks to avoid memory issues with batch
      if (i % 500 == 0 && i > 0) {
        await batch.commit(noResult: true);
      }
    }
    await batch.commit(noResult: true);
    debugPrint("Seeded $count records for performance test.");
  }
}
