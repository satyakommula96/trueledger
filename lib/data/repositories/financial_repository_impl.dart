import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:trueledger/data/datasources/database.dart';
import 'package:trueledger/domain/models/models.dart';
import '../../domain/repositories/i_financial_repository.dart';
import 'package:flutter/foundation.dart';

class FinancialRepositoryImpl implements IFinancialRepository {
  FinancialRepositoryImpl();

  @override
  Future<MonthlySummary> getMonthlySummary() async {
    final db = await AppDatabase.db;
    final nowStr = DateTime.now().toIso8601String().substring(0, 7); // YYYY-MM

    final income = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT SUM(amount) FROM income_sources WHERE substr(date, 1, 7) = ?',
            [nowStr])) ??
        0;
    final fixed = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT SUM(amount) FROM fixed_expenses WHERE substr(date, 1, 7) = ?',
            [nowStr])) ??
        0;
    final variable = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT SUM(amount) FROM variable_expenses WHERE substr(date, 1, 7) = ?',
            [nowStr])) ??
        0;
    final subs = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT SUM(amount) FROM subscriptions WHERE active=1')) ??
        0;

    final investmentsTotal = Sqflite.firstIntValue(await db
            .rawQuery('SELECT SUM(amount) FROM investments WHERE active=1')) ??
        0;

    // Net worth calc elements (Global snapshots)
    final npsTotal = Sqflite.firstIntValue(await db.rawQuery(
            "SELECT SUM(amount) FROM retirement_contributions WHERE type = 'NPS'")) ??
        0;
    final pfTotal = Sqflite.firstIntValue(await db.rawQuery(
            "SELECT SUM(amount) FROM retirement_contributions WHERE type = 'EPF'")) ??
        0;
    final otherRetirement = Sqflite.firstIntValue(await db.rawQuery(
            "SELECT SUM(amount) FROM retirement_contributions WHERE type NOT IN ('NPS', 'EPF')")) ??
        0;
    final creditCardDebt = Sqflite.firstIntValue(await db
            .rawQuery("SELECT SUM(statement_balance) FROM credit_cards")) ??
        0;
    final loansTotal = Sqflite.firstIntValue(
            await db.rawQuery("SELECT SUM(remaining_amount) FROM loans")) ??
        0;

    final totalEMI = Sqflite.firstIntValue(
            await db.rawQuery("SELECT SUM(emi) FROM loans")) ??
        0;

    final netWorth = (investmentsTotal + npsTotal + pfTotal + otherRetirement) -
        (creditCardDebt + loansTotal);

    return MonthlySummary(
      totalIncome: income,
      totalFixed: fixed,
      totalVariable: variable,
      totalSubscriptions: subs,
      totalInvestments: investmentsTotal,
      netWorth: netWorth,
      creditCardDebt: creditCardDebt,
      loansTotal: loansTotal,
      totalMonthlyEMI: totalEMI,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getSpendingTrend() async {
    final db = await AppDatabase.db;
    // Get spending trend (variable expenses)
    final spendRaw = await db.rawQuery(
        'SELECT substr(date, 1, 7) as month, SUM(amount) as total FROM variable_expenses GROUP BY month ORDER BY month DESC LIMIT 6');

    // Get income trend
    final incomeRaw = await db.rawQuery(
        'SELECT substr(date, 1, 7) as month, SUM(amount) as total FROM income_sources GROUP BY month ORDER BY month DESC LIMIT 6');

    final months = <String>{
      ...spendRaw.map((e) => e['month'] as String),
      ...incomeRaw.map((e) => e['month'] as String),
    }.toList()
      ..sort((a, b) {
        final dateA = _parseStepMonth(a);
        final dateB = _parseStepMonth(b);
        return dateA.compareTo(dateB);
      });

    // Limit to last 6 months
    final lastMonths =
        months.length > 6 ? months.sublist(months.length - 6) : months;

    return lastMonths.map((m) {
      final s = spendRaw.firstWhere((e) => e['month'] == m,
          orElse: () => {'total': 0});
      final i = incomeRaw.firstWhere((e) => e['month'] == m,
          orElse: () => {'total': 0});
      return {
        'month': m,
        'spending': s['total'],
        'income': i['total'],
        'total':
            s['total'], // Keep 'total' for backward compatibility in widgets
      };
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getUpcomingBills() async {
    final db = await AppDatabase.db;
    final subBills = await db.query('subscriptions', where: 'active = 1');
    final ccBills = await db.query('credit_cards');
    final loanBills = await db.query('loans');

    return [
      ...subBills.map((s) => {
            'title': s['name'],
            'amount': s['amount'],
            'type': 'SUBSCRIPTION',
            'due': 'RECURRING'
          }),
      ...ccBills.map((c) => {
            'title': c['bank'],
            'amount': c['min_due'],
            'type': 'CREDIT DUE',
            'due': c['due_date']
          }),
      ...loanBills.map((l) => {
            'title': l['name'],
            'amount': l['emi'],
            'type': 'LOAN EMI',
            'due': l['due_date']
          }),
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getCategorySpending() async {
    final db = await AppDatabase.db;
    final nowStr = DateTime.now().toIso8601String().substring(0, 7);
    return await db.rawQuery(
        'SELECT category, SUM(amount) as total FROM variable_expenses WHERE substr(date, 1, 7) = ? GROUP BY category ORDER BY total DESC',
        [nowStr]);
  }

  @override
  Future<List<SavingGoal>> getSavingGoals() async {
    final db = await AppDatabase.db;
    final list = await db.query('saving_goals');
    return list.map((e) => SavingGoal.fromMap(e)).toList();
  }

  @override
  Future<List<Budget>> getBudgets() async {
    final db = await AppDatabase.db;
    final nowStr = DateTime.now().toIso8601String().substring(0, 7);
    final res = await db.rawQuery('''
      SELECT b.*, COALESCE(SUM(ve.amount), 0) as spent
      FROM budgets b
      LEFT JOIN variable_expenses ve ON b.category = ve.category AND substr(ve.date, 1, 7) = ?
      GROUP BY b.id
    ''', [nowStr]);
    return res.map((e) => Budget.fromMap(e)).toList();
  }

  @override
  Future<void> addEntry(String type, int amount, String category, String note,
      String date) async {
    final db = await AppDatabase.db;
    switch (type) {
      case 'Income':
        await db.insert('income_sources',
            {'source': category, 'amount': amount, 'date': date});
        break;
      case 'Fixed':
        await db.insert('fixed_expenses', {
          'name': category,
          'amount': amount,
          'category': type,
          'date': date
        });
        break;
      case 'Subscription':
        await db.insert('subscriptions', {
          'name': category,
          'amount': amount,
          'active': 1,
          'billing_date': '1',
          'date': date
        });
        break;
      case 'Investment':
        await db.insert('investments', {
          'name': note.isNotEmpty ? note : category,
          'amount': amount,
          'active': 1,
          'type': category,
          'date': date
        });
        break;
      default:
        await db.insert('variable_expenses', {
          'date': date,
          'amount': amount,
          'category': category,
          'note': note
        });
    }
  }

  @override
  Future<void> checkAndProcessRecurring() async {
    // Reverted to empty for V1 start
  }

  @override
  Future<List<int>> getAvailableYears() async {
    final db = await AppDatabase.db;
    final res = await db.rawQuery('''
      SELECT DISTINCT substr(date, 1, 4) as year FROM variable_expenses
      UNION SELECT DISTINCT substr(date, 1, 4) as year FROM income_sources
      UNION SELECT DISTINCT substr(date, 1, 4) as year FROM fixed_expenses
      UNION SELECT DISTINCT substr(date, 1, 4) as year FROM investments
      ORDER BY year DESC
    ''');
    return res.map((e) => int.parse(e['year'].toString())).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getMonthlyHistory([int? year]) async {
    final db = await AppDatabase.db;
    final yearStr = year?.toString() ?? "";

    final query = '''
      SELECT 
        month,
        SUM(income) as income,
        SUM(expenses) as expenses,
        SUM(invested) as invested
      FROM (
        SELECT substr(date, 1, 7) as month, amount as income, 0 as expenses, 0 as invested FROM income_sources WHERE ? = '' OR substr(date, 1, 4) = ?
        UNION ALL
        SELECT substr(date, 1, 7) as month, 0 as income, amount as expenses, 0 as invested FROM variable_expenses WHERE ? = '' OR substr(date, 1, 4) = ?
        UNION ALL
        SELECT substr(date, 1, 7) as month, 0 as income, amount as expenses, 0 as invested FROM fixed_expenses WHERE ? = '' OR substr(date, 1, 4) = ?
        UNION ALL
        SELECT substr(date, 1, 7) as month, 0 as income, 0 as expenses, amount as invested FROM investments WHERE ? = '' OR substr(date, 1, 4) = ?
      )
      GROUP BY month
    ''';

    final res = await db.rawQuery(query, [
      yearStr,
      yearStr,
      yearStr,
      yearStr,
      yearStr,
      yearStr,
      yearStr,
      yearStr
    ]);

    return res.map((row) {
      final income = row['income'] as num? ?? 0;
      final expenses = row['expenses'] as num? ?? 0;
      final invested = row['invested'] as num? ?? 0;
      return {
        'month': row['month'],
        'income': income.toInt(),
        'expenses': expenses.toInt(),
        'invested': invested.toInt(),
        'net': (income - (expenses + invested)).toInt(),
      };
    }).toList()
      ..sort((a, b) {
        final dateA = _parseStepMonth(a['month'] as String);
        final dateB = _parseStepMonth(b['month'] as String);
        return dateB.compareTo(dateA); // History is usually newest first
      });
  }

  /// Helper to parse "YYYY-MM" or "YYYY-MM-DD" into a DateTime safely
  DateTime _parseStepMonth(String input) {
    try {
      if (input.length == 7) {
        return DateTime.parse('$input-01');
      }
      return DateTime.parse(input);
    } catch (e) {
      debugPrint("INVALID DATE DETECTED: $input. Error: $e");
      if (kDebugMode) {
        throw FormatException("Expected YYYY-MM or ISO date but got: $input");
      }
      return DateTime(1900);
    }
  }

  @override
  Future<List<Loan>> getLoans() async {
    final db = await AppDatabase.db;
    final list = await db.query('loans');
    return list.map((e) => Loan.fromMap(e)).toList();
  }

  @override
  Future<List<Subscription>> getSubscriptions() async {
    final db = await AppDatabase.db;
    final list = await db.query('subscriptions');
    return list.map((e) => Subscription.fromMap(e)).toList();
  }

  @override
  Future<List<CreditCard>> getCreditCards() async {
    final db = await AppDatabase.db;
    final list = await db.query('credit_cards');
    return list.map((e) => CreditCard.fromMap(e)).toList();
  }

  @override
  Future<void> deleteItem(String table, int id) async {
    final db = await AppDatabase.db;
    await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> addBudget(String category, int monthlyLimit) async {
    final db = await AppDatabase.db;
    await db.insert(
        'budgets', {'category': category, 'monthly_limit': monthlyLimit});
  }

  @override
  Future<void> updateBudget(int id, int monthlyLimit) async {
    final db = await AppDatabase.db;
    await db.update('budgets', {'monthly_limit': monthlyLimit},
        where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Map<String, dynamic>>> getAllValues(String table) async {
    final db = await AppDatabase.db;
    return await db.query(table);
  }

  @override
  Future<void> seedRoadmapData() async {
    if (!kDebugMode) return;
    await AppDatabase.seedRoadmapData();
  }

  @override
  Future<void> seedHealthyProfile() async {
    if (!kDebugMode) return;
    await AppDatabase.seedHealthyProfile();
  }

  @override
  Future<void> seedAtRiskProfile() async {
    if (!kDebugMode) return;
    await AppDatabase.seedAtRiskProfile();
  }

  @override
  Future<void> seedLargeData(int count) async {
    if (!kDebugMode) return;
    await AppDatabase.seedLargeData(count: count);
  }

  @override
  Future<void> clearData() async {
    await AppDatabase.clearData();
  }

  @override
  Future<void> addCreditCard(String bank, int creditLimit, int statementBalance,
      int minDue, String dueDate, String statementDate) async {
    final db = await AppDatabase.db;
    await db.insert('credit_cards', {
      'bank': bank,
      'credit_limit': creditLimit,
      'statement_balance': statementBalance,
      'min_due': minDue,
      'due_date': dueDate,
      'statement_date': statementDate,
    });
  }

  @override
  Future<void> updateCreditCard(
      int id,
      String bank,
      int creditLimit,
      int statementBalance,
      int minDue,
      String dueDate,
      String statementDate) async {
    final db = await AppDatabase.db;
    await db.update(
      'credit_cards',
      {
        'bank': bank,
        'credit_limit': creditLimit,
        'statement_balance': statementBalance,
        'min_due': minDue,
        'due_date': dueDate,
        'statement_date': statementDate,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> payCreditCardBill(int id, int amount) async {
    final db = await AppDatabase.db;
    final cardList =
        await db.query('credit_cards', where: 'id = ?', whereArgs: [id]);
    if (cardList.isNotEmpty) {
      final card = cardList.first;
      int currentBal = card['statement_balance'] as int;
      int currentMin = card['min_due'] as int;

      int newBal = currentBal - amount;
      if (newBal < 0) newBal = 0;

      int newMin = currentMin - amount;
      if (newMin < 0) newMin = 0;

      await db.update(
          'credit_cards', {'statement_balance': newBal, 'min_due': newMin},
          where: 'id = ?', whereArgs: [id]);
    }
  }

  @override
  Future<void> addGoal(String name, int targetAmount) async {
    final db = await AppDatabase.db;
    await db.insert('saving_goals',
        {'name': name, 'target_amount': targetAmount, 'current_amount': 0});
  }

  @override
  Future<void> updateGoal(
      int id, String name, int targetAmount, int currentAmount) async {
    final db = await AppDatabase.db;
    await db.update(
        'saving_goals',
        {
          'name': name,
          'target_amount': targetAmount,
          'current_amount': currentAmount
        },
        where: 'id = ?',
        whereArgs: [id]);
  }

  @override
  Future<void> addLoan(String name, String type, int total, int remaining,
      int emi, double rate, String due, String date) async {
    final db = await AppDatabase.db;
    await db.insert('loans', {
      'name': name,
      'loan_type': type,
      'total_amount': total,
      'remaining_amount': remaining,
      'emi': emi,
      'interest_rate': rate,
      'due_date': due,
      'date': date,
    });
  }

  @override
  Future<void> updateLoan(int id, String name, String type, int total,
      int remaining, int emi, double rate, String due) async {
    final db = await AppDatabase.db;
    await db.update(
        'loans',
        {
          'name': name,
          'loan_type': type,
          'total_amount': total,
          'remaining_amount': remaining,
          'emi': emi,
          'interest_rate': rate,
          'due_date': due,
        },
        where: 'id = ?',
        whereArgs: [id]);
  }

  @override
  Future<void> addSubscription(
      String name, int amount, String billingDate) async {
    final db = await AppDatabase.db;
    await db.insert('subscriptions', {
      'name': name,
      'amount': amount,
      'billing_date': billingDate,
      'active': 1
    });
  }

  @override
  Future<void> updateEntry(
      String type, int id, Map<String, dynamic> values) async {
    final db = await AppDatabase.db;
    String table = "";
    switch (type) {
      case 'Variable':
        table = 'variable_expenses';
        break;
      case 'Income':
        table = 'income_sources';
        break;
      case 'Fixed':
        table = 'fixed_expenses';
        break;
      case 'Investment':
        table = 'investments';
        break;
      case 'Subscription':
        table = 'subscriptions';
        break;
    }
    await db.update(table, values, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<LedgerItem>> getMonthDetails(String month) async {
    final db = await AppDatabase.db;
    List<Map<String, dynamic>> allItems = [];
    final vars = await db.rawQuery(
        "SELECT *, 'Variable' as entryType FROM variable_expenses WHERE substr(date, 1, 7) = ?",
        [month]);
    allItems.addAll(vars);
    final income = await db.rawQuery(
        "SELECT *, 'Income' as entryType FROM income_sources WHERE substr(date, 1, 7) = ?",
        [month]);
    allItems.addAll(income);
    final fixed = await db.rawQuery(
        "SELECT *, 'Fixed' as entryType FROM fixed_expenses WHERE substr(date, 1, 7) = ?",
        [month]);
    allItems.addAll(fixed);
    final invs = await db.rawQuery(
        "SELECT *, 'Investment' as entryType FROM investments WHERE substr(date, 1, 7) = ?",
        [month]);
    allItems.addAll(invs);

    // Sort desc by Date, then ID
    // Note: ISO8601 strings sort correctly via string comparison and is significantly faster for large lists.
    allItems.sort((a, b) {
      final dateCmp = (b['date'] as String).compareTo(a['date'] as String);
      if (dateCmp != 0) return dateCmp;
      return (b['id'] as int).compareTo(a['id'] as int);
    });
    return allItems.map((e) => LedgerItem.fromMap(e)).toList();
  }

  @override
  Future<List<LedgerItem>> getTransactionsForRange(
      DateTime start, DateTime end) async {
    final db = await AppDatabase.db;
    final startStr = start.toIso8601String().substring(0, 10);
    final endStr = end.toIso8601String().substring(0, 10);

    List<Map<String, dynamic>> allItems = [];

    final tables = [
      {'name': 'variable_expenses', 'type': 'Variable'},
      {'name': 'income_sources', 'type': 'Income'},
      {'name': 'fixed_expenses', 'type': 'Fixed'},
      {'name': 'investments', 'type': 'Investment'},
    ];

    for (var table in tables) {
      final data = await db.rawQuery(
          "SELECT *, '${table['type']}' as entryType FROM ${table['name']} WHERE substr(date, 1, 10) >= ? AND substr(date, 1, 10) <= ?",
          [startStr, endStr]);
      allItems.addAll(data);
    }

    allItems.sort((a, b) {
      final dateCmp = (b['date'] as String).compareTo(a['date'] as String);
      if (dateCmp != 0) return dateCmp;
      return (b['id'] as int).compareTo(a['id'] as int);
    });

    return allItems.map((e) => LedgerItem.fromMap(e)).toList();
  }

  @override
  Future<Map<String, dynamic>> generateBackup() async {
    final db = await AppDatabase.db;
    final Map<String, dynamic> backup = {};

    final tableMap = {
      'variable_expenses': 'vars',
      'income_sources': 'income',
      'fixed_expenses': 'fixed',
      'investments': 'invs',
      'subscriptions': 'subs',
      'credit_cards': 'cards',
      'loans': 'loans',
      'saving_goals': 'goals',
      'budgets': 'budgets',
    };

    for (var entry in tableMap.entries) {
      final tableName = entry.key;
      final backupKey = entry.value;
      final data = await db.query(tableName);
      backup[backupKey] = data;
    }

    return backup;
  }

  @override
  Future<void> restoreBackup(Map<String, dynamic> data) async {
    final db = await AppDatabase.db;
    final batch = db.batch();

    // Mapping table names to backup keys
    final tableMap = {
      'variable_expenses': 'vars',
      'income_sources': 'income',
      'fixed_expenses': 'fixed',
      'investments': 'invs',
      'subscriptions': 'subs',
      'credit_cards': 'cards',
      'loans': 'loans',
      'saving_goals': 'goals',
      'budgets': 'budgets',
    };

    // Clear existing data first
    for (var entry in tableMap.entries) {
      batch.delete(entry.key);
    }

    for (var entry in tableMap.entries) {
      final tableName = entry.key;
      final backupKey = entry.value;
      if (data[backupKey] != null && data[backupKey] is List) {
        for (var item in (data[backupKey] as List)) {
          batch.insert(tableName, item as Map<String, dynamic>);
        }
      }
    }

    await batch.commit(noResult: true);
  }

  @override
  Future<int> getTodaySpend() async {
    final db = await AppDatabase.db;
    final todayStr =
        DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD
    final result = await db.rawQuery(
        'SELECT SUM(amount) FROM variable_expenses WHERE substr(date, 1, 10) = ?',
        [todayStr]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<int> getTodayTransactionCount() async {
    final db = await AppDatabase.db;
    final todayStr =
        DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD
    final result = await db.rawQuery(
        'SELECT COUNT(*) FROM variable_expenses WHERE substr(date, 1, 10) = ?',
        [todayStr]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<Map<String, int>> getWeeklySummary() async {
    final db = await AppDatabase.db;
    final now = DateTime.now();

    // This week: Monday to today
    final thisMondayOffset = now.weekday - 1;
    final thisWeekStart =
        DateTime(now.year, now.month, now.day - thisMondayOffset);

    // Last week same period: Previous Monday to (now - 7 days)
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final lastWeekEnd = now.subtract(const Duration(days: 7));

    final thisWeekResult = await db.rawQuery('''
      SELECT SUM(amount) FROM variable_expenses
      WHERE substr(date, 1, 10) >= ? AND substr(date, 1, 10) <= ?
    ''', [
      thisWeekStart.toIso8601String().substring(0, 10),
      now.toIso8601String().substring(0, 10)
    ]);

    final lastWeekResult = await db.rawQuery('''
      SELECT SUM(amount) FROM variable_expenses
      WHERE substr(date, 1, 10) >= ? AND substr(date, 1, 10) <= ?
    ''', [
      lastWeekStart.toIso8601String().substring(0, 10),
      lastWeekEnd.toIso8601String().substring(0, 10)
    ]);

    return {
      'thisWeek': Sqflite.firstIntValue(thisWeekResult) ?? 0,
      'lastWeek': Sqflite.firstIntValue(lastWeekResult) ?? 0,
    };
  }

  @override

  /// Calculates the active daily streak of "tracking" events.
  /// Definition: A tracking event is a manual entry in the [variable_expenses] table.
  /// Fixed expenses (like rent), one-off Income, or Investments do not count
  /// toward the "habitual tracking" streak.
  @override
  Future<int> getActiveStreak() async {
    final db = await AppDatabase.db;
    final results = await db.rawQuery('''
      SELECT DISTINCT substr(date, 1, 10) as day FROM variable_expenses
      ORDER BY day DESC
    ''');

    if (results.isEmpty) return 0;

    final daysSet = results.map((e) => e['day'] as String).toSet();

    DateTime checkDate = DateTime.now();
    String todayStr = DateFormat('yyyy-MM-dd').format(checkDate);
    String yesterdayStr = DateFormat('yyyy-MM-dd')
        .format(checkDate.subtract(const Duration(days: 1)));

    // If no transaction today or yesterday, streak is broken
    if (!daysSet.contains(todayStr) && !daysSet.contains(yesterdayStr)) {
      return 0;
    }

    int streak = 0;
    // Start from either today or yesterday (whichever has the most recent tx)
    if (daysSet.contains(todayStr)) {
      streak = 1;
    } else {
      streak = 1;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (true) {
      checkDate = checkDate.subtract(const Duration(days: 1));
      String nextDayStr = DateFormat('yyyy-MM-dd').format(checkDate);
      if (daysSet.contains(nextDayStr)) {
        streak++;
      } else {
        break;
      }
    }
    return streak > 1 ? streak : 0;
  }

  @override
  Future<List<TransactionCategory>> getCategories(String type) async {
    final db = await AppDatabase.db;
    var list = await db
        .query('custom_categories', where: 'type = ?', whereArgs: [type]);

    if (list.isEmpty) {
      final allCount = Sqflite.firstIntValue(
              await db.rawQuery('SELECT COUNT(*) FROM custom_categories')) ??
          0;
      // If the specific type is empty, and the table is entirely empty, seed all.
      if (allCount == 0) {
        final batch = db.batch();
        for (var entry in _defaultCategories.entries) {
          for (var cat in entry.value) {
            batch.insert('custom_categories', {
              'name': cat,
              'type': entry.key,
            });
          }
        }
        await batch.commit(noResult: true);
        list = await db
            .query('custom_categories', where: 'type = ?', whereArgs: [type]);
      }
    }

    return list.map((e) => TransactionCategory.fromMap(e)).toList();
  }

  @override
  Future<void> addCategory(String name, String type) async {
    final db = await AppDatabase.db;
    await db.insert('custom_categories', {
      'name': name,
      'type': type,
    });
  }

  @override
  Future<void> deleteCategory(int id) async {
    final db = await AppDatabase.db;
    await db.delete('custom_categories', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Map<String, dynamic>>> getCategorySpendingForRange(
      DateTime start, DateTime end) async {
    final db = await AppDatabase.db;
    final startStr = start.toIso8601String().substring(0, 10);
    final endStr = end.toIso8601String().substring(0, 10);

    return await db.rawQuery(
        'SELECT category, SUM(amount) as total FROM variable_expenses WHERE substr(date, 1, 10) >= ? AND substr(date, 1, 10) <= ? GROUP BY category ORDER BY total DESC',
        [startStr, endStr]);
  }

  static const Map<String, List<String>> _defaultCategories = {
    'Variable': ['Food', 'Transport', 'Shopping', 'Entertainment', 'Others'],
    'Fixed': ['Rent', 'Utility', 'Insurance', 'EMI'],
    'Investment': [
      'Stocks',
      'Mutual Funds',
      'SIP',
      'Crypto',
      'Gold',
      'Lending',
      'Retirement',
      'Other'
    ],
    'Income': ['Salary', 'Freelance', 'Dividends'],
    'Subscription': ['OTT', 'Software', 'Gym'],
  };

  @override
  Future<String?> getRecommendedCategory(String note) async {
    final db = await AppDatabase.db;
    final result = await db.rawQuery(
        'SELECT category FROM variable_expenses WHERE note LIKE ? ORDER BY date DESC LIMIT 1',
        ['%$note%']);
    if (result.isNotEmpty) {
      return result.first['category'] as String?;
    }
    return null;
  }

  @override
  Future<Map<String, int>> getDatabaseStats() async {
    final db = await AppDatabase.db;
    final variableCount = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM variable_expenses')) ??
        0;
    final fixedCount = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM fixed_expenses')) ??
        0;
    final incomeCount = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM income_sources')) ??
        0;
    final budgetsCount = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM budgets')) ??
        0;

    return {
      'variable': variableCount,
      'fixed': fixedCount,
      'income': incomeCount,
      'budgets': budgetsCount,
      'total_records': variableCount + fixedCount + incomeCount + budgetsCount,
    };
  }
}
