import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      version: 1,
      onCreate: (db, _) async {
        await db.execute('CREATE TABLE income_sources (id INTEGER PRIMARY KEY AUTOINCREMENT, source TEXT, amount INTEGER, date TEXT)');
        await db.execute('CREATE TABLE fixed_expenses (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, amount INTEGER, category TEXT, date TEXT)');
        await db.execute('CREATE TABLE variable_expenses (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, amount INTEGER, category TEXT, note TEXT)');
        await db.execute('CREATE TABLE investments (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, amount INTEGER, active INTEGER, type TEXT, date TEXT)');
        await db.execute('CREATE TABLE subscriptions (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, amount INTEGER, billing_date TEXT, active INTEGER, date TEXT)');
        await db.execute('CREATE TABLE retirement_contributions (id INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT, amount INTEGER, date TEXT)');
        await db.execute('''
          CREATE TABLE credit_cards (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            bank TEXT,
            credit_limit INTEGER,
            statement_balance INTEGER,
            min_due INTEGER,
            due_date TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE loans (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            loan_type TEXT,
            total_amount INTEGER,
            remaining_amount INTEGER,
            emi INTEGER,
            interest_rate REAL,
            due_date TEXT,
            date TEXT
          )
        ''');
        await db.execute('CREATE TABLE saving_goals (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, target_amount INTEGER, current_amount INTEGER)');
        await db.execute('CREATE TABLE budgets (id INTEGER PRIMARY KEY AUTOINCREMENT, category TEXT, monthly_limit INTEGER)');
      },
    );
  }

  static Future<void> clearData() async {
    final database = await db;
    await database.delete('income_sources');
    await database.delete('fixed_expenses');
    await database.delete('variable_expenses');
    await database.delete('investments');
    await database.delete('subscriptions');
    await database.delete('retirement_contributions');
    await database.delete('credit_cards');
    await database.delete('loans');
    await database.delete('saving_goals');
    await database.delete('budgets');
  }

  static Future<void> seedDummyData() async {
    final database = await db;
    final now = DateTime.now();
    final nowStr = now.toIso8601String();
    
    await database.insert('income_sources', {'source': 'Main Salary', 'amount': 167000, 'date': nowStr});
    await database.insert('income_sources', {'source': 'Freelance Project', 'amount': 25000, 'date': nowStr});

    await database.insert('fixed_expenses', {'name': 'Luxury Apartment Rent', 'amount': 45000, 'category': 'Housing', 'date': nowStr});
    await database.insert('fixed_expenses', {'name': 'Car EMI', 'amount': 18500, 'category': 'Transport', 'date': nowStr});

    await database.insert('retirement_contributions', {'type': 'NPS', 'amount': 50000, 'date': nowStr});
    await database.insert('retirement_contributions', {'type': 'EPF', 'amount': 145000, 'date': nowStr});

    await database.insert('loans', {
      'name': 'Gold Loan (Sovereign)',
      'loan_type': 'Gold',
      'total_amount': 200000,
      'remaining_amount': 185000,
      'emi': 5200,
      'interest_rate': 8.5,
      'due_date': '5th',
      'date': nowStr
    });
    await database.insert('loans', {
      'name': 'Car Finance (Tata)',
      'loan_type': 'Car',
      'total_amount': 800000,
      'remaining_amount': 620000,
      'emi': 18500,
      'interest_rate': 9.2,
      'due_date': '10th',
      'date': nowStr
    });
    await database.insert('loans', {
      'name': 'In-Person Borrowing (Friend)',
      'loan_type': 'Person',
      'total_amount': 50000,
      'remaining_amount': 45000,
      'emi': 5000,
      'interest_rate': 0.0,
      'due_date': '1st',
      'date': nowStr
    });

    for (int i = 0; i < 6; i++) {
      final monthDate = DateTime(now.year, now.month - i, 15);
      final monthStr = monthDate.toIso8601String();
      final baseAmount = 20000 + (i * 3500);
      
      await database.insert('variable_expenses', {'date': monthStr, 'amount': baseAmount + 500, 'category': 'Food', 'note': 'Groceries & Dining'});
      await database.insert('variable_expenses', {'date': monthStr, 'amount': (baseAmount * 0.4).toInt(), 'category': 'Transport', 'note': 'Fuel & Uber'});
      await database.insert('variable_expenses', {'date': monthStr, 'amount': (baseAmount * 0.6).toInt(), 'category': 'Shopping', 'note': 'Amazon/Myntra'});
    }

    await database.insert('investments', {'name': 'Nifty 50 Index Fund', 'amount': 250000, 'active': 1, 'type': 'Equity', 'date': nowStr});
    await database.insert('investments', {'name': 'Gold Bonds', 'amount': 50000, 'active': 1, 'type': 'Commodity', 'date': nowStr});

    await database.insert('subscriptions', {'name': 'Netflix 4K', 'amount': 649, 'active': 1, 'billing_date': '5', 'date': nowStr});
    await database.insert('subscriptions', {'name': 'Youtube Premium', 'amount': 189, 'active': 1, 'billing_date': '12', 'date': nowStr});

    await database.insert('credit_cards', {'bank': 'Amex Platinum', 'credit_limit': 1000000, 'statement_balance': 125000, 'min_due': 6250, 'due_date': '20th Jan'});
    await database.insert('credit_cards', {'bank': 'HDFC Infinia', 'credit_limit': 800000, 'statement_balance': 45000, 'min_due': 2250, 'due_date': '15th Feb'});

    await database.insert('saving_goals', {'name': 'Tesla Model 3', 'target_amount': 4500000, 'current_amount': 850000});
    await database.insert('saving_goals', {'name': 'Switzerland Trip', 'target_amount': 600000, 'current_amount': 320000});

    await database.insert('budgets', {'category': 'Food', 'monthly_limit': 15000});
    await database.insert('budgets', {'category': 'Shopping', 'monthly_limit': 10000});
  }
}