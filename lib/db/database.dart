import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'schema.dart';
import '../config/version.dart';

class AppDatabase {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'tracker_v11.db');

    return openDatabase(
      path,
      version: AppVersion.databaseVersion,
      onCreate: (db, _) async {
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
        await db.execute(
            'CREATE TABLE sys_config (key TEXT PRIMARY KEY, value TEXT)');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Handle database migrations here
        // Example:
        // if (oldVersion < 2) {
        //   await db.execute("ALTER TABLE some_table ADD COLUMN new_col TEXT");
        // }
        // Ensure you increase the version number in openDatabase arguments whenever you change schema.

        // For now, since we bumped to v2, we ensure all tables are created if missing
        // (This acts as a safety net if a user skpped a version or if tables were added in v2)
        if (oldVersion < 3) {
          try {
            await db.execute(
                "ALTER TABLE ${Schema.creditCardsTable} ADD COLUMN ${Schema.colGenerationDate} TEXT");
          } catch (_) {
            // Column might already exist if dev reset failed
          }
        }

        if (oldVersion < 4) {
          try {
            await db.execute(
                "ALTER TABLE ${Schema.variableExpensesTable} ADD COLUMN ${Schema.colTags} TEXT");
            await db.execute(
                'CREATE TABLE IF NOT EXISTS sys_config (key TEXT PRIMARY KEY, value TEXT)');
          } catch (_) {}
        }
      },
    );
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
    final database = await db;
    final now = DateTime.now();
    final nowStr = now.toIso8601String();

    // 1. Income (High income to trigger Wealth Projection)
    await database.insert(Schema.incomeSourcesTable, {
      Schema.colSource: 'Product Director Salary',
      Schema.colAmount: 450000,
      Schema.colDate: nowStr
    });
    await database.insert(Schema.incomeSourcesTable, {
      Schema.colSource: 'Rental Income',
      Schema.colAmount: 85000,
      Schema.colDate: nowStr
    });
    await database.insert(Schema.incomeSourcesTable, {
      Schema.colSource: 'Dividends',
      Schema.colAmount: 12000,
      Schema.colDate: nowStr
    });

    // 2. Fixed Expenses
    await database.insert(Schema.fixedExpensesTable, {
      Schema.colName: 'Penthouse Rent',
      Schema.colAmount: 65000,
      Schema.colCategory: 'Housing',
      Schema.colDate: nowStr
    });
    await database.insert(Schema.fixedExpensesTable, {
      Schema.colName: 'Car Lease (BMW)',
      Schema.colAmount: 35000,
      Schema.colCategory: 'Transport',
      Schema.colDate: nowStr
    });
    await database.insert(Schema.fixedExpensesTable, {
      Schema.colName: 'Maid & Cook',
      Schema.colAmount: 12000,
      Schema.colCategory: 'Service',
      Schema.colDate: nowStr
    });

    // 3. Subscriptions
    await database.insert(Schema.subscriptionsTable, {
      Schema.colName: 'Netflix Premium',
      Schema.colAmount: 649,
      Schema.colActive: 1,
      Schema.colBillingDate:
          now.add(const Duration(days: 2)).day.toString(), // Due soon
      Schema.colDate: nowStr
    });
    await database.insert(Schema.subscriptionsTable, {
      Schema.colName: 'ChatGPT Plus',
      Schema.colAmount: 1950,
      Schema.colActive: 1,
      Schema.colBillingDate: now.add(const Duration(days: 8)).day.toString(),
      Schema.colDate: nowStr
    });
    await database.insert(Schema.subscriptionsTable, {
      Schema.colName: 'Spotify Family',
      Schema.colAmount: 199,
      Schema.colActive: 1,
      Schema.colBillingDate: now.add(const Duration(days: 15)).day.toString(),
      Schema.colDate: nowStr
    });
    await database.insert(Schema.subscriptionsTable, {
      Schema.colName: 'AWS Cloud Hosting',
      Schema.colAmount: 12500,
      Schema.colActive: 1,
      Schema.colBillingDate: now.add(const Duration(days: 5)).day.toString(),
      Schema.colDate: nowStr
    });
    await database.insert(Schema.subscriptionsTable, {
      Schema.colName: 'Bloomberg Terminal',
      Schema.colAmount: 22000,
      Schema.colActive: 1,
      Schema.colBillingDate: now.add(const Duration(days: 12)).day.toString(),
      Schema.colDate: nowStr
    });

    // 4. Investments & Assets
    await database.insert(Schema.investmentsTable, {
      Schema.colName: 'Reliance Industries',
      Schema.colAmount: 520000,
      Schema.colActive: 1,
      Schema.colType: 'Equity / Stocks',
      Schema.colDate: nowStr
    });
    await database.insert(Schema.investmentsTable, {
      Schema.colName: 'HDFC Mid Cap Fund',
      Schema.colAmount: 350000,
      Schema.colActive: 1,
      Schema.colType: 'Mutual Fund',
      Schema.colDate: nowStr
    });
    await database.insert(Schema.investmentsTable, {
      Schema.colName: 'Sovereign Gold Bond',
      Schema.colAmount: 210000,
      Schema.colActive: 1,
      Schema.colType: 'Gold / Commodity',
      Schema.colDate: nowStr
    });

    // 5. Retirement
    await database.insert(Schema.retirementContributionsTable, {
      Schema.colType: 'NPS',
      Schema.colAmount: 150000,
      Schema.colDate: nowStr
    });
    await database.insert(Schema.retirementContributionsTable, {
      Schema.colType: 'EPF',
      Schema.colAmount: 850000,
      Schema.colDate: nowStr
    });

    // 6. Loans
    await database.insert(Schema.loansTable, {
      Schema.colName: 'Home Loan (SBI)',
      Schema.colLoanType: 'Home',
      Schema.colTotalAmount: 8500000,
      Schema.colRemainingAmount: 6200000,
      Schema.colEmi: 65000,
      Schema.colInterestRate: 8.4,
      Schema.colDueDate: '5th',
      Schema.colDate: nowStr
    });
    await database.insert(Schema.loansTable, {
      Schema.colName: 'Personal Loan',
      Schema.colLoanType: 'Bank',
      Schema.colTotalAmount: 500000,
      Schema.colRemainingAmount: 220000,
      Schema.colEmi: 18500,
      Schema.colInterestRate: 11.5,
      Schema.colDueDate: '12th',
      Schema.colDate: nowStr
    });
    await database.insert(Schema.loansTable, {
      Schema.colName: 'Loan from Dad',
      Schema.colLoanType: 'Individual',
      Schema.colTotalAmount: 100000,
      Schema.colRemainingAmount: 50000,
      Schema.colEmi: 0,
      Schema.colInterestRate: 0.0,
      Schema.colDueDate: 'Flexible',
      Schema.colDate: nowStr
    });

    // 7. Credit Cards
    await database.insert(Schema.creditCardsTable, {
      Schema.colBank: 'HDFC Infinia',
      Schema.colCreditLimit: 1500000,
      Schema.colStatementBalance: 87000,
      Schema.colMinDue: 0,
      Schema.colDueDate: '12 Feb 2026',
      Schema.colGenerationDate: '23 Jan 2026'
    });
    await database.insert(Schema.creditCardsTable, {
      Schema.colBank: 'Amex Platinum',
      Schema.colCreditLimit: 1000000,
      Schema.colStatementBalance: 12500,
      Schema.colMinDue: 0,
      Schema.colDueDate: '24 Feb 2026',
      Schema.colGenerationDate: '05 Jan 2026'
    });

    // 8. Variable Expenses (Historical & Current)
    final categories = [
      'Food',
      'Transport',
      'Shopping',
      'Utility',
      'Entertainment',
      'Travel'
    ];

    // Generate data for last 6 months including current
    for (int i = 0; i < 6; i++) {
      final monthDate = DateTime(now.year, now.month - i, 1);

      // Higher spending in current month for "Insight" calculation comparison
      // If i=0 (current), let's make it HIGH. i=1 (last month) LOW.
      // This ensures "Spending increased" warning.

      double multiplier = 1.0;
      if (i == 0) multiplier = 1.3; // High current
      if (i == 1) multiplier = 0.8; // Low previous

      for (var cat in categories) {
        // Create 2-3 entries per category per month
        int entries = 2;
        if (cat == 'Food') entries = 4;

        for (int j = 0; j < entries; j++) {
          int base = 500;
          if (cat == 'Shopping') base = 2500;
          if (cat == 'Travel') base = 5000;
          if (cat == 'Food') base = 800;

          final amount = (base * (0.8 + (0.4 * (j % 2))) * multiplier).toInt();

          // Random-ish date within that month
          final entryDate =
              DateTime(monthDate.year, monthDate.month, 1 + (j * 5));

          await database.insert(Schema.variableExpensesTable, {
            Schema.colDate: entryDate.toIso8601String(),
            Schema.colAmount: amount,
            Schema.colCategory: cat,
            Schema.colNote: '$cat expense #$j'
          });
        }
      }
    }

    // 9. Budgets
    await database.insert(Schema.budgetsTable,
        {Schema.colCategory: 'Food', Schema.colMonthlyLimit: 25000});
    await database.insert(Schema.budgetsTable,
        {Schema.colCategory: 'Transport', Schema.colMonthlyLimit: 15000});
    await database.insert(Schema.budgetsTable, {
      Schema.colCategory: 'Shopping',
      Schema.colMonthlyLimit: 30000 // Likely to be overspent
    });
    await database.insert(Schema.budgetsTable,
        {Schema.colCategory: 'Entertainment', Schema.colMonthlyLimit: 10000});

    // 10. Goals
    await database.insert(Schema.savingGoalsTable, {
      Schema.colName: 'Europe Trip',
      Schema.colTargetAmount: 800000,
      Schema.colCurrentAmount: 350000
    });
    await database.insert(Schema.savingGoalsTable, {
      Schema.colName: 'Emergency Fund',
      Schema.colTargetAmount: 1000000,
      Schema.colCurrentAmount: 600000
    });
  }
}
