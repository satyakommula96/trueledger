import 'package:flutter/material.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:truecash/data/datasources/database.dart';
import 'package:truecash/domain/models/models.dart';
import '../../domain/repositories/i_financial_repository.dart';

class FinancialRepositoryImpl implements IFinancialRepository {
  @override
  Future<MonthlySummary> getMonthlySummary() async {
    final db = await AppDatabase.db;
    final income = Sqflite.firstIntValue(
            await db.rawQuery('SELECT SUM(amount) FROM income_sources')) ??
        0;
    final fixed = Sqflite.firstIntValue(
            await db.rawQuery('SELECT SUM(amount) FROM fixed_expenses')) ??
        0;
    final variable = Sqflite.firstIntValue(
            await db.rawQuery('SELECT SUM(amount) FROM variable_expenses')) ??
        0;
    final subs = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT SUM(amount) FROM subscriptions WHERE active=1')) ??
        0;

    final investmentsTotal = Sqflite.firstIntValue(await db
            .rawQuery('SELECT SUM(amount) FROM investments WHERE active=1')) ??
        0;

    // Net worth calc elements
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
    final trendRaw = await db.rawQuery(
        'SELECT substr(date, 1, 7) as month, SUM(amount) as total FROM variable_expenses GROUP BY month ORDER BY month DESC LIMIT 6');
    return trendRaw.reversed.toList();
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
    return await db.rawQuery(
        'SELECT category, SUM(amount) as total FROM variable_expenses GROUP BY category ORDER BY total DESC');
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
    final budgetData = await db.query('budgets');
    List<Budget> processedBudgets = [];
    for (var b in budgetData) {
      final spent = Sqflite.firstIntValue(await db.rawQuery(
              'SELECT SUM(amount) FROM variable_expenses WHERE category = ?',
              [b['category']])) ??
          0;
      processedBudgets.add(Budget.fromMap({...b, 'spent': spent}));
    }
    return processedBudgets;
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
          'note': note,
          'tags': note.contains('#') ? _extractTags(note) : null
        });
    }
  }

  String _extractTags(String note) {
    final regex = RegExp(r'\#\w+');
    final matches = regex.allMatches(note);
    if (matches.isEmpty) return "";
    return matches.map((m) => m.group(0)).join(',');
  }

  @override
  Future<void> checkAndProcessRecurring() async {
    final db = await AppDatabase.db;
    final now = DateTime.now();
    final today = now.day;
    final monthStr = now.toIso8601String().substring(0, 7); // YYYY-MM

    // Check if we already processed today
    final config =
        await db.query('sys_config', where: 'key = ?', whereArgs: ['last_run']);
    String lastRun = "";
    if (config.isNotEmpty) {
      lastRun = config.first['value'].toString();
    }

    final todayStr = now.toIso8601String().substring(0, 10);
    if (lastRun == todayStr) return; // Already ran today

    // Fetch active subscriptions
    final subs = await db.query('subscriptions', where: 'active = 1');

    for (var s in subs) {
      int billingDay = int.tryParse(s['billing_date'].toString()) ?? 1;

      // If billing day matches today OR we missed it (and haven't added it for this month)
      if (today >= billingDay) {
        // Check if this specific subscription has been added for this month
        final existing = await db.rawQuery(
            "SELECT id FROM fixed_expenses WHERE category = 'Subscription' AND name = ? AND substr(date, 1, 7) = ?",
            [s['name'], monthStr]);

        if (existing.isEmpty) {
          await db.insert('fixed_expenses', {
            'name': s['name'],
            'amount': s['amount'],
            'category': 'Subscription',
            'date': now.toIso8601String()
          });
          debugPrint("Auto-processed subscription: ${s['name']}");
        }
      }
    }

    // Update last run
    await db.insert('sys_config', {'key': 'last_run', 'value': todayStr},
        conflictAlgorithm: ConflictAlgorithm.replace);
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

    // Construct query dynamically to filter efficiently
    final tables = [
      'variable_expenses',
      'income_sources',
      'fixed_expenses',
      'investments'
    ];
    List<String> parts = [];
    List<dynamic> args = [];
    String yearStr = year?.toString() ?? "";

    for (var t in tables) {
      if (year != null) {
        parts.add(
            "SELECT DISTINCT substr(date, 1, 7) as month FROM $t WHERE substr(date, 1, 4) = ?");
        args.add(yearStr);
      } else {
        parts.add("SELECT DISTINCT substr(date, 1, 7) as month FROM $t");
      }
    }

    final fullQuery = "${parts.join(' UNION ')} ORDER BY month DESC";
    final monthsQuery = await db.rawQuery(fullQuery, args);

    List<Map<String, dynamic>> summaries = [];
    for (var m in monthsQuery) {
      final month = m['month'].toString();
      final income = Sqflite.firstIntValue(await db.rawQuery(
              'SELECT SUM(amount) FROM income_sources WHERE substr(date, 1, 7) = ?',
              [month])) ??
          0;
      final variable = Sqflite.firstIntValue(await db.rawQuery(
              'SELECT SUM(amount) FROM variable_expenses WHERE substr(date, 1, 7) = ?',
              [month])) ??
          0;
      final fixed = Sqflite.firstIntValue(await db.rawQuery(
              'SELECT SUM(amount) FROM fixed_expenses WHERE substr(date, 1, 7) = ?',
              [month])) ??
          0;
      final invested = Sqflite.firstIntValue(await db.rawQuery(
              'SELECT SUM(amount) FROM investments WHERE substr(date, 1, 7) = ?',
              [month])) ??
          0;
      summaries.add({
        'month': month,
        'income': income,
        'expenses': variable + fixed,
        'invested': invested,
        'net': income - (variable + fixed + invested)
      });
    }
    return summaries;
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
  Future<void> seedData() async {
    await AppDatabase.seedDummyData();
  }

  @override
  Future<void> seedLargeData(int count) async {
    await AppDatabase.seedLargeData(count: count);
  }

  @override
  Future<void> clearData() async {
    await AppDatabase.clearData();
  }

  @override
  Future<void> addCreditCard(String bank, int creditLimit, int statementBalance,
      int minDue, String dueDate, String generationDate) async {
    final db = await AppDatabase.db;
    await db.insert('credit_cards', {
      'bank': bank,
      'credit_limit': creditLimit,
      'statement_balance': statementBalance,
      'min_due': minDue,
      'due_date': dueDate,
      'generation_date': generationDate,
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
      String generationDate) async {
    final db = await AppDatabase.db;
    await db.update(
      'credit_cards',
      {
        'bank': bank,
        'credit_limit': creditLimit,
        'statement_balance': statementBalance,
        'min_due': minDue,
        'due_date': dueDate,
        'generation_date': generationDate,
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

    // Sort desc by ID (implicitly time)
    allItems.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
    return allItems.map((e) => LedgerItem.fromMap(e)).toList();
  }
}
