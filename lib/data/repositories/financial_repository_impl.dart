import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:trueledger/data/datasources/database.dart';
import 'package:trueledger/data/datasources/schema.dart';
import 'package:trueledger/domain/models/models.dart';
import '../../domain/repositories/i_financial_repository.dart';
import 'package:flutter/foundation.dart';

class FinancialRepositoryImpl implements IFinancialRepository {
  FinancialRepositoryImpl();

  @override
  Future<MonthlySummary> getMonthlySummary() async {
    final db = await AppDatabase.db;
    final nowStr = DateTime.now().toIso8601String().substring(0, 7); // YYYY-MM

    double getSum(List<Map<String, dynamic>> res) =>
        (res.first.values.first as num? ?? 0).toDouble();

    final income = getSum(await db.rawQuery(
        'SELECT SUM(amount) FROM income_sources WHERE substr(date, 1, 7) = ?',
        [nowStr]));
    final fixed = getSum(await db.rawQuery(
        'SELECT SUM(amount) FROM fixed_expenses WHERE substr(date, 1, 7) = ?',
        [nowStr]));
    final variable = getSum(await db.rawQuery(
        'SELECT SUM(amount) FROM variable_expenses WHERE substr(date, 1, 7) = ?',
        [nowStr]));
    final subs = getSum(await db
        .rawQuery('SELECT SUM(amount) FROM subscriptions WHERE active=1'));

    final investmentsTotal = getSum(await db
        .rawQuery('SELECT SUM(amount) FROM investments WHERE active=1'));

    // Net worth calc elements (Global snapshots)
    final npsTotal = getSum(await db.rawQuery(
        "SELECT SUM(amount) FROM retirement_contributions WHERE type = 'NPS'"));
    final pfTotal = getSum(await db.rawQuery(
        "SELECT SUM(amount) FROM retirement_contributions WHERE type = 'EPF'"));
    final otherRetirement = getSum(await db.rawQuery(
        "SELECT SUM(amount) FROM retirement_contributions WHERE type NOT IN ('NPS', 'EPF')"));
    final creditCardDebt = getSum(
        await db.rawQuery("SELECT SUM(statement_balance) FROM credit_cards"));
    final loansTotal =
        getSum(await db.rawQuery("SELECT SUM(remaining_amount) FROM loans"));

    final totalEMI = getSum(await db.rawQuery("SELECT SUM(emi) FROM loans"));

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
    final recurringTx =
        await db.query('recurring_transactions', where: 'active = 1');

    final now = DateTime.now();
    final currentMonth = DateFormat('yyyy-MM').format(now);

    // Get all transactions for current month to check for matching payments
    final currentMonthTx = await db.rawQuery('''
      SELECT note as label FROM variable_expenses WHERE substr(date, 1, 7) = ?
      UNION ALL
      SELECT name as label FROM fixed_expenses WHERE substr(date, 1, 7) = ?
    ''', [currentMonth, currentMonth]);

    bool checkPaid(String name) {
      final n = name.toLowerCase();
      return currentMonthTx.any((tx) {
        final label = (tx['label'] ?? '').toString().toLowerCase();
        return label.contains(n) || n.contains(label);
      });
    }

    return [
      ...subBills.map((s) {
        final name = s['name'] as String;
        final isSIP = name.toUpperCase().contains('SIP') ||
            name.toUpperCase().contains('FUND');
        return {
          'id': 'sub_${s['id']}',
          'name': name,
          'title': name,
          'amount': s['amount'],
          'type': isSIP ? 'INVESTMENT DUE' : 'SUBSCRIPTION',
          'due': s['billing_date'],
          'isRecurring': true,
          'isPaid': checkPaid(name),
        };
      }),
      ...ccBills
          .where((c) => (c['statement_balance'] as num? ?? 0) > 0)
          .map((c) => {
                'id': 'cc_${c['id']}',
                'name': c['bank'],
                'title': c['bank'],
                'amount': c['statement_balance'],
                'type': 'CREDIT DUE',
                'due': c['due_date'],
                'isRecurring': true,
                'isPaid': false,
              }),
      ...loanBills.map((l) => {
            'id': 'loan_${l['id']}',
            'name': l['name'],
            'title': l['name'],
            'amount': l['loan_type'] == 'Individual'
                ? l['remaining_amount']
                : l['emi'],
            'type':
                l['loan_type'] == 'Individual' ? 'BORROWING DUE' : 'LOAN EMI',
            'due': l['due_date'],
            'isRecurring': true,
            'isPaid': checkPaid(l['name'] as String? ?? ''),
          }),
      ...recurringTx.map((r) {
        // Format due date based on frequency
        String dueDate;
        final dayOfMonth = r['day_of_month'] as int?;
        if (dayOfMonth != null) {
          // For monthly recurring, use day of month
          dueDate =
              '${now.year}-${now.month.toString().padLeft(2, '0')}-${dayOfMonth.toString().padLeft(2, '0')}';
        } else {
          // For other frequencies, use current date as placeholder
          dueDate = DateFormat('yyyy-MM-dd').format(now);
        }

        return {
          'id': 'recurring_${r['id']}',
          'name': r['name'],
          'title': r['name'],
          'amount': r['amount'],
          'type':
              r['type'] == 'INCOME' ? 'RECURRING INCOME' : 'RECURRING EXPENSE',
          'due': dueDate,
          'isRecurring': true,
          'isPaid': checkPaid(r['name'] as String? ?? ''),
        };
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
    final now = DateTime.now();
    final nowStr = now.toIso8601String().substring(0, 7);

    // Calculate stability over last 3 completed months
    final last3Months = List.generate(3, (i) {
      final d = DateTime(now.year, now.month - (i + 1), 1);
      return d.toIso8601String().substring(0, 7);
    });

    final res = await db.rawQuery('''
      SELECT b.*, 
             COALESCE(SUM(ve.amount), 0) as spent
      FROM budgets b
      LEFT JOIN variable_expenses ve ON b.category = ve.category AND substr(ve.date, 1, 7) = ?
      GROUP BY b.id
    ''', [nowStr]);

    final List<Budget> budgets = [];
    for (var row in res) {
      final category = row['category'] as String;
      final limit = (row['monthly_limit'] as num).toInt();

      // Check stability: Did we overspend in any of the last 3 months?
      bool isStable = true;
      for (var month in last3Months) {
        final res = await db.rawQuery(
            'SELECT SUM(amount) FROM variable_expenses WHERE category = ? AND substr(date, 1, 7) = ?',
            [category, month]);
        final monthSpend = (res.first.values.first as num? ?? 0).toDouble();
        if (monthSpend > limit) {
          isStable = false;
          break;
        }
      }

      final budgetMap = Map<String, dynamic>.from(row);
      budgetMap['is_stable'] = isStable ? 1 : 0;
      budgets.add(Budget.fromMap(budgetMap));
    }

    return budgets;
  }

  @override
  Future<void> markBudgetAsReviewed(int id) async {
    final db = await AppDatabase.db;
    await db.update(
        'budgets', {'last_reviewed_at': DateTime.now().toIso8601String()},
        where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> addEntry(
      String type, double amount, String category, String note, String date,
      {String? paymentMethod, Set<TransactionTag>? tags}) async {
    final db = await AppDatabase.db;
    final tagStr = tags?.map((t) => t.name).join(',');

    // Handle credit card balance update if payment method matches a card name
    if (paymentMethod != null && type != 'Income') {
      final cardList = await db
          .query('credit_cards', where: 'bank = ?', whereArgs: [paymentMethod]);
      if (cardList.isNotEmpty) {
        final card = cardList.first;
        final currentBal = (card['current_balance'] as num?)?.toDouble() ?? 0.0;
        await db.update(
            'credit_cards', {'current_balance': currentBal + amount},
            where: 'id = ?', whereArgs: [card['id']]);
      }
    }

    switch (type) {
      case 'Income':
        await db.insert('income_sources', {
          'source': category,
          'amount': amount,
          'date': date,
          'tags': tagStr ?? 'income'
        });
        break;
      case 'Fixed':
        await db.insert('fixed_expenses', {
          'name': category,
          'amount': amount,
          'category': type,
          'date': date,
          'tags': tagStr ?? 'transfer'
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
          'date': date,
          'tags': tagStr ?? 'transfer'
        });
        break;
      default:
        await db.insert('variable_expenses', {
          'date': date,
          'amount': amount,
          'category': category,
          'note': note,
          'tags': tagStr ?? 'transfer'
        });
    }
  }

  @override
  Future<void> checkAndProcessRecurring() async {
    final db = await AppDatabase.db;
    final now = DateTime.now();
    final todayDay = now.day;
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    // 1. Check Credit Card Statement Generation
    final cards = await db.query('credit_cards');
    for (final c in cards) {
      final stmtStr = c['statement_date'] as String? ?? '';
      final match = RegExp(r'^(\d+)').firstMatch(stmtStr);
      if (match != null) {
        final stmtDay = int.tryParse(match.group(1)!);
        if (stmtDay == todayDay) {
          final currentBal = (c['current_balance'] as num?)?.toDouble() ?? 0.0;
          await db.update('credit_cards', {'statement_balance': currentBal},
              where: 'id = ?', whereArgs: [c['id']]);
        }
      }
    }

    // 2. Process User-Defined Recurring Transactions
    final recurring = await db.query(Schema.recurringTransactionsTable,
        where: '${Schema.colActive} = ?', whereArgs: [1]);

    for (final r in recurring) {
      final item = RecurringTransaction.fromMap(r);
      final lastProcessed = item.lastProcessed;

      // Skip if already processed today
      if (lastProcessed != null && lastProcessed.startsWith(todayStr)) continue;

      bool shouldProcess = false;

      switch (item.frequency) {
        case 'DAILY':
          shouldProcess = true;
          break;
        case 'WEEKLY':
          if (now.weekday == item.dayOfWeek) {
            shouldProcess = true;
          }
          break;
        case 'MONTHLY':
          if (todayDay == item.dayOfMonth) {
            shouldProcess = true;
          } else if (item.dayOfMonth != null &&
              item.dayOfMonth! > 28 &&
              todayDay == DateTime(now.year, now.month + 1, 0).day) {
            // Handle last day of month
            shouldProcess = true;
          }
          break;
      }

      if (shouldProcess) {
        await addEntry(
          item.type == 'INCOME' ? 'Income' : 'Variable',
          item.amount,
          item.category,
          "${item.name} (Auto)",
          todayStr,
        );

        await db.update(
          Schema.recurringTransactionsTable,
          {Schema.colLastProcessed: now.toIso8601String()},
          where: 'id = ?',
          whereArgs: [item.id],
        );
      }
    }
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
      final income = (row['income'] as num? ?? 0).toDouble();
      final expenses = (row['expenses'] as num? ?? 0).toDouble();
      final invested = (row['invested'] as num? ?? 0).toDouble();
      return {
        'month': row['month'],
        'income': income,
        'expenses': expenses,
        'invested': invested,
        'net': income - (expenses + invested),
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
  Future<void> addBudget(String category, double monthlyLimit) async {
    final db = await AppDatabase.db;
    await db.insert(
        'budgets', {'category': category, 'monthly_limit': monthlyLimit});
  }

  @override
  Future<void> updateBudget(int id, double monthlyLimit) async {
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
  Future<void> addCreditCard(
      String bank,
      double creditLimit,
      double statementBalance,
      double minDue,
      String dueDate,
      String statementDate,
      [double currentBalance = 0.0]) async {
    final db = await AppDatabase.db;
    await db.insert('credit_cards', {
      'bank': bank,
      'credit_limit': creditLimit,
      'statement_balance': statementBalance,
      'current_balance': currentBalance,
      'min_due': minDue,
      'due_date': dueDate,
      'statement_date': statementDate,
    });
  }

  @override
  Future<void> updateCreditCard(
      int id,
      String bank,
      double creditLimit,
      double statementBalance,
      double minDue,
      String dueDate,
      String statementDate,
      [double? currentBalance]) async {
    final db = await AppDatabase.db;
    final Map<String, dynamic> values = {
      'bank': bank,
      'credit_limit': creditLimit,
      'statement_balance': statementBalance,
      'min_due': minDue,
      'due_date': dueDate,
      'statement_date': statementDate,
    };

    if (currentBalance != null) {
      values['current_balance'] = currentBalance;
    }

    await db.update(
      'credit_cards',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> payCreditCardBill(int id, double amount) async {
    final db = await AppDatabase.db;
    final cardList =
        await db.query('credit_cards', where: 'id = ?', whereArgs: [id]);
    if (cardList.isNotEmpty) {
      final card = cardList.first;
      final bank = card['bank'] as String;
      double stmtBal = (card['statement_balance'] as num).toDouble();
      double currentBal =
          (card['current_balance'] as num?)?.toDouble() ?? stmtBal;
      double currentMin = (card['min_due'] as num).toDouble();

      double newStmtBal = stmtBal - amount;
      if (newStmtBal < 0) newStmtBal = 0;

      double newCurrentBal = currentBal - amount;
      if (newCurrentBal < 0) newCurrentBal = 0;

      double newMin = currentMin - amount;
      if (newMin < 0) newMin = 0;

      await db.update(
          'credit_cards',
          {
            'statement_balance': newStmtBal,
            'current_balance': newCurrentBal,
            'min_due': newMin
          },
          where: 'id = ?',
          whereArgs: [id]);

      // Record transaction
      await addEntry(
        'Fixed',
        amount,
        'Card Payment: $bank',
        'Payment for $bank credit card',
        DateTime.now().toIso8601String(),
        tags: {TransactionTag.creditCardPayment},
      );
    }
  }

  @override
  Future<void> addGoal(String name, double targetAmount) async {
    final db = await AppDatabase.db;
    await db.insert('saving_goals',
        {'name': name, 'target_amount': targetAmount, 'current_amount': 0});
  }

  @override
  Future<void> updateGoal(
      int id, String name, double targetAmount, double currentAmount) async {
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
  Future<void> addLoan(String name, String type, double total, double remaining,
      double emi, double rate, String due, String date) async {
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
  Future<void> updateLoan(int id, String name, String type, double total,
      double remaining, double emi, double rate, String due,
      [String? lastPaymentDate]) async {
    final db = await AppDatabase.db;
    final data = {
      'name': name,
      'loan_type': type,
      'total_amount': total,
      'remaining_amount': remaining,
      'emi': emi,
      'interest_rate': rate,
      'due_date': due,
    };
    if (lastPaymentDate != null) {
      data['last_payment_date'] = lastPaymentDate;
    }
    await db.update('loans', data, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> addSubscription(
      String name, double amount, String billingDate) async {
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
  Future<double> getTodaySpend() async {
    final db = await AppDatabase.db;
    final todayStr =
        DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD
    final result = await db.rawQuery(
        'SELECT SUM(amount) FROM variable_expenses WHERE substr(date, 1, 10) = ?',
        [todayStr]);
    return (result.first.values.first as num? ?? 0).toDouble();
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
  Future<Map<String, double>> getWeeklySummary() async {
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
      'thisWeek': (thisWeekResult.first.values.first as num? ?? 0).toDouble(),
      'lastWeek': (lastWeekResult.first.values.first as num? ?? 0).toDouble(),
    };
  }

  @override

  /// Calculates the active daily streak of "tracking" events.
  /// Definition: A tracking event is ANY entry in [variable_expenses], [fixed_expenses], or [income_sources].
  /// This ensures that logging rent, EMI, or salary also counts as "tracking".
  @override
  Future<int> getActiveStreak() async {
    final db = await AppDatabase.db;
    final results = await db.rawQuery('''
      SELECT substr(date, 1, 10) as day FROM variable_expenses
      UNION
      SELECT substr(date, 1, 10) as day FROM fixed_expenses
      UNION
      SELECT substr(date, 1, 10) as day FROM income_sources
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
    var list = await db.query('custom_categories',
        where: 'type = ?',
        whereArgs: [type],
        orderBy: '${Schema.colOrderIndex} ASC, ${Schema.colId} ASC');

    // If this specific type is empty, seed its defaults
    if (list.isEmpty) {
      final typeDefaults = _defaultCategories[type];
      if (typeDefaults != null) {
        final batch = db.batch();
        int index = 0;

        // Get current max index for this type to be safe, though it's empty
        for (var cat in typeDefaults) {
          batch.insert('custom_categories', {
            'name': cat,
            'type': type,
            Schema.colOrderIndex: index++,
          });
        }
        await batch.commit(noResult: true);

        // Fetch again after seeding
        list = await db.query('custom_categories',
            where: 'type = ?',
            whereArgs: [type],
            orderBy: '${Schema.colOrderIndex} ASC, ${Schema.colId} ASC');
      }
    }

    return list.map((e) => TransactionCategory.fromMap(e)).toList();
  }

  @override
  Future<void> addCategory(String name, String type) async {
    final db = await AppDatabase.db;

    // Get the current max order index for this type
    final maxRes = await db.rawQuery(
        'SELECT MAX(${Schema.colOrderIndex}) as max_idx FROM custom_categories WHERE type = ?',
        [type]);
    final maxIdx = (maxRes.first['max_idx'] as int? ?? -1) + 1;

    await db.insert('custom_categories', {
      'name': name,
      'type': type,
      Schema.colOrderIndex: maxIdx,
    });
  }

  @override
  Future<void> deleteCategory(int id) async {
    final db = await AppDatabase.db;
    await db.delete('custom_categories', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> reorderCategories(List<TransactionCategory> categories) async {
    final db = await AppDatabase.db;
    final batch = db.batch();

    for (int i = 0; i < categories.length; i++) {
      batch.update(
        'custom_categories',
        {Schema.colOrderIndex: i},
        where: 'id = ?',
        whereArgs: [categories[i].id],
      );
    }

    await batch.commit(noResult: true);
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
    'Variable': [
      'Food',
      'Groceries',
      'Transport',
      'Medical',
      'Shopping',
      'Entertainment',
      'Others'
    ],
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

  @override
  Future<List<String>> getPaidBillLabels(String monthStr) async {
    final db = await AppDatabase.db;
    final result = await db.rawQuery('''
      SELECT note as label FROM variable_expenses WHERE substr(date, 1, 7) = ?
      UNION ALL
      SELECT name as label FROM fixed_expenses WHERE substr(date, 1, 7) = ?
    ''', [monthStr, monthStr]);

    return result.map((e) => (e['label'] ?? '').toString()).toList();
  }

  @override
  Future<void> recordLoanAudit({
    required int loanId,
    required String date,
    required double openingBalance,
    required double interestRate,
    required double paymentAmount,
    required int daysAccrued,
    required double interestAccrued,
    required double principalApplied,
    required double closingBalance,
    required int engineVersion,
    required String type,
  }) async {
    final db = await AppDatabase.db;
    await db.insert('loan_audit_log', {
      'loan_id': loanId,
      'date': date,
      'opening_balance': openingBalance,
      'interest_rate': interestRate,
      'payment_amount': paymentAmount,
      'days_accrued': daysAccrued,
      'interest_accrued': interestAccrued,
      'principal_applied': principalApplied,
      'closing_balance': closingBalance,
      'engine_version': engineVersion,
      'type': type,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getLoanAuditLog(int loanId) async {
    final db = await AppDatabase.db;
    return await db.query('loan_audit_log',
        where: 'loan_id = ?', whereArgs: [loanId], orderBy: 'date DESC');
  }

  @override
  Future<void> updateEntryTags(
      String type, int id, Set<TransactionTag> tags) async {
    final db = await AppDatabase.db;
    String table;
    switch (type) {
      case 'Variable':
        table = 'variable_expenses';
        break;
      case 'Fixed':
        table = 'fixed_expenses';
        break;
      case 'Income':
        table = 'income_sources';
        break;
      case 'Investment':
        table = 'investments';
        break;
      default:
        return;
    }
    await db.update(table, {'tags': tags.map((t) => t.name).join(',')},
        where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<RetirementAccount>> getRetirementAccounts() async {
    final db = await AppDatabase.db;
    final list = await db.query('retirement_contributions');
    return list.map((e) => RetirementAccount.fromMap(e)).toList();
  }

  @override
  Future<void> updateRetirementAccount(
      int id, double amount, String date) async {
    final db = await AppDatabase.db;
    await db.update(
        'retirement_contributions', {'amount': amount, 'date': date},
        where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Asset>> getInvestments() async {
    final db = await AppDatabase.db;
    final list = await db.query('investments', where: 'active = 1');
    return list.map((e) => Asset.fromMap(e)).toList();
  }

  @override
  Future<void> addInvestment(
      String name, double amount, String type, String date) async {
    final db = await AppDatabase.db;
    await db.insert('investments', {
      'name': name,
      'amount': amount,
      'type': type,
      'date': date,
      'active': 1,
    });
  }

  @override
  Future<List<RecurringTransaction>> getRecurringTransactions() async {
    final db = await AppDatabase.db;
    final list = await db.query(Schema.recurringTransactionsTable);
    return list.map((e) => RecurringTransaction.fromMap(e)).toList();
  }

  @override
  Future<void> addRecurringTransaction({
    required String name,
    required double amount,
    required String category,
    required String type,
    required String frequency,
    int? dayOfMonth,
    int? dayOfWeek,
  }) async {
    final db = await AppDatabase.db;
    await db.insert(Schema.recurringTransactionsTable, {
      Schema.colName: name,
      Schema.colAmount: amount,
      Schema.colCategory: category,
      Schema.colType: type,
      Schema.colFrequency: frequency,
      Schema.colDayOfMonth: dayOfMonth,
      Schema.colDayOfWeek: dayOfWeek,
      Schema.colActive: 1,
    });
  }
}
