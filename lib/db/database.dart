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
            ${Schema.colDueDate} TEXT
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
        if (oldVersion < 2) {
          // If we added specific tables in v2, strictly we should create them here.
          // For this initial setup, we assume v1 was clean or this is the first production ready database.
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

    await database.insert(Schema.incomeSourcesTable, {
      Schema.colSource: 'Main Salary',
      Schema.colAmount: 167000,
      Schema.colDate: nowStr
    });
    await database.insert(Schema.incomeSourcesTable, {
      Schema.colSource: 'Freelance Project',
      Schema.colAmount: 25000,
      Schema.colDate: nowStr
    });

    await database.insert(Schema.fixedExpensesTable, {
      Schema.colName: 'Luxury Apartment Rent',
      Schema.colAmount: 45000,
      Schema.colCategory: 'Housing',
      Schema.colDate: nowStr
    });
    await database.insert(Schema.fixedExpensesTable, {
      Schema.colName: 'Car EMI',
      Schema.colAmount: 18500,
      Schema.colCategory: 'Transport',
      Schema.colDate: nowStr
    });

    await database.insert(Schema.retirementContributionsTable, {
      Schema.colType: 'NPS',
      Schema.colAmount: 50000,
      Schema.colDate: nowStr
    });
    await database.insert(Schema.retirementContributionsTable, {
      Schema.colType: 'EPF',
      Schema.colAmount: 145000,
      Schema.colDate: nowStr
    });

    await database.insert(Schema.loansTable, {
      Schema.colName: 'Gold Loan (Sovereign)',
      Schema.colLoanType: 'Gold',
      Schema.colTotalAmount: 200000,
      Schema.colRemainingAmount: 185000,
      Schema.colEmi: 5200,
      Schema.colInterestRate: 8.5,
      Schema.colDueDate: '5th',
      Schema.colDate: nowStr
    });
    await database.insert(Schema.loansTable, {
      Schema.colName: 'Car Finance (Tata)',
      Schema.colLoanType: 'Car',
      Schema.colTotalAmount: 800000,
      Schema.colRemainingAmount: 620000,
      Schema.colEmi: 18500,
      Schema.colInterestRate: 9.2,
      Schema.colDueDate: '10th',
      Schema.colDate: nowStr
    });
    await database.insert(Schema.loansTable, {
      Schema.colName: 'In-Person Borrowing (Friend)',
      Schema.colLoanType: 'Person',
      Schema.colTotalAmount: 50000,
      Schema.colRemainingAmount: 45000,
      Schema.colEmi: 5000,
      Schema.colInterestRate: 0.0,
      Schema.colDueDate: '1st',
      Schema.colDate: nowStr
    });

    for (int i = 0; i < 6; i++) {
      final monthDate = DateTime(now.year, now.month - i, 15);
      final monthStr = monthDate.toIso8601String();
      final baseAmount = 20000 + (i * 3500);

      await database.insert(Schema.variableExpensesTable, {
        Schema.colDate: monthStr,
        Schema.colAmount: baseAmount + 500,
        Schema.colCategory: 'Food',
        Schema.colNote: 'Groceries & Dining'
      });
      await database.insert(Schema.variableExpensesTable, {
        Schema.colDate: monthStr,
        Schema.colAmount: (baseAmount * 0.4).toInt(),
        Schema.colCategory: 'Transport',
        Schema.colNote: 'Fuel & Uber'
      });
      await database.insert(Schema.variableExpensesTable, {
        Schema.colDate: monthStr,
        Schema.colAmount: (baseAmount * 0.6).toInt(),
        Schema.colCategory: 'Shopping',
        Schema.colNote: 'Amazon/Myntra'
      });
    }

    await database.insert(Schema.investmentsTable, {
      Schema.colName: 'Nifty 50 Index Fund',
      Schema.colAmount: 250000,
      Schema.colActive: 1,
      Schema.colType: 'Equity',
      Schema.colDate: nowStr
    });
    await database.insert(Schema.investmentsTable, {
      Schema.colName: 'Gold Bonds',
      Schema.colAmount: 50000,
      Schema.colActive: 1,
      Schema.colType: 'Commodity',
      Schema.colDate: nowStr
    });

    await database.insert(Schema.subscriptionsTable, {
      Schema.colName: 'Netflix 4K',
      Schema.colAmount: 649,
      Schema.colActive: 1,
      Schema.colBillingDate: '5',
      Schema.colDate: nowStr
    });
    await database.insert(Schema.subscriptionsTable, {
      Schema.colName: 'Youtube Premium',
      Schema.colAmount: 189,
      Schema.colActive: 1,
      Schema.colBillingDate: '12',
      Schema.colDate: nowStr
    });

    await database.insert(Schema.creditCardsTable, {
      Schema.colBank: 'Amex Platinum',
      Schema.colCreditLimit: 1000000,
      Schema.colStatementBalance: 125000,
      Schema.colMinDue: 6250,
      Schema.colDueDate: '20th Jan'
    });
    await database.insert(Schema.creditCardsTable, {
      Schema.colBank: 'HDFC Infinia',
      Schema.colCreditLimit: 800000,
      Schema.colStatementBalance: 45000,
      Schema.colMinDue: 2250,
      Schema.colDueDate: '15th Feb'
    });

    await database.insert(Schema.savingGoalsTable, {
      Schema.colName: 'Tesla Model 3',
      Schema.colTargetAmount: 4500000,
      Schema.colCurrentAmount: 850000
    });
    await database.insert(Schema.savingGoalsTable, {
      Schema.colName: 'Switzerland Trip',
      Schema.colTargetAmount: 600000,
      Schema.colCurrentAmount: 320000
    });

    await database.insert(Schema.budgetsTable,
        {Schema.colCategory: 'Food', Schema.colMonthlyLimit: 15000});
    await database.insert(Schema.budgetsTable,
        {Schema.colCategory: 'Shopping', Schema.colMonthlyLimit: 10000});
  }
}
