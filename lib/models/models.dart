
class Loan {
  final int id;
  final String name;
  final String loanType;
  final int totalAmount;
  final int remainingAmount;
  final int emi;
  final double interestRate;
  final String dueDate;
  final String? date;

  Loan({
    required this.id,
    required this.name,
    required this.loanType,
    required this.totalAmount,
    required this.remainingAmount,
    required this.emi,
    required this.interestRate,
    required this.dueDate,
    this.date,
  });

  factory Loan.fromMap(Map<String, dynamic> map) {
    return Loan(
      id: map['id'] as int,
      name: map['name'] as String,
      loanType: map['loan_type'] as String,
      totalAmount: map['total_amount'] as int,
      remainingAmount: map['remaining_amount'] as int,
      emi: map['emi'] as int,
      interestRate: (map['interest_rate'] as num).toDouble(),
      dueDate: map['due_date'] as String,
      date: map['date'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'loan_type': loanType,
      'total_amount': totalAmount,
      'remaining_amount': remainingAmount,
      'emi': emi,
      'interest_rate': interestRate,
      'due_date': dueDate,
      'date': date,
    };
  }
}

class Subscription {
  final int id;
  final String name;
  final int amount;
  final String billingDate;
  final int active;
  final String? date;

  Subscription({
    required this.id,
    required this.name,
    required this.amount,
    required this.billingDate,
    required this.active,
    this.date,
  });

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'] as int,
      name: map['name'] as String,
      amount: map['amount'] as int,
      billingDate: map['billing_date'] as String,
      active: map['active'] as int,
      date: map['date'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'billing_date': billingDate,
      'active': active,
      'date': date,
    };
  }
}

class CreditCard {
  final int id;
  final String bank;
  final int creditLimit;
  final int statementBalance;
  final int minDue;
  final String dueDate;

  CreditCard({
    required this.id,
    required this.bank,
    required this.creditLimit,
    required this.statementBalance,
    required this.minDue,
    required this.dueDate,
  });

  factory CreditCard.fromMap(Map<String, dynamic> map) {
    return CreditCard(
      id: map['id'] as int,
      bank: map['bank'] as String,
      creditLimit: map['credit_limit'] as int,
      statementBalance: map['statement_balance'] as int,
      minDue: map['min_due'] as int,
      dueDate: map['due_date'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bank': bank,
      'credit_limit': creditLimit,
      'statement_balance': statementBalance,
      'min_due': minDue,
      'due_date': dueDate,
    };
  }
}

class SavingGoal {
  final int id;
  final String name;
  final int targetAmount;
  final int currentAmount;

  SavingGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
  });

  factory SavingGoal.fromMap(Map<String, dynamic> map) {
    return SavingGoal(
      id: map['id'] as int,
      name: map['name'] as String,
      targetAmount: map['target_amount'] as int,
      currentAmount: map['current_amount'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
    };
  }
}

class Budget {
  final int id;
  final String category;
  final int monthlyLimit;
  final int spent; // Not in DB table, calculated field

  Budget({
    required this.id,
    required this.category,
    required this.monthlyLimit,
    this.spent = 0,
  });

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as int,
      category: map['category'] as String,
      monthlyLimit: map['monthly_limit'] as int,
      spent: map['spent'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'monthly_limit': monthlyLimit,
      // spent is usually excluded from DB writes
    };
  }
}

class LedgerItem {
  final int id;
  final String label; // Unifies name, category, source
  final int amount;
  final String date;
  final String type; // 'Variable', 'Income', 'Fixed', 'Investment'
  final String? note;

  LedgerItem({
    required this.id,
    required this.label,
    required this.amount,
    required this.date,
    required this.type,
    this.note,
  });

  factory LedgerItem.fromMap(Map<String, dynamic> map) {
    // Logic to determine label based on available fields
    String label = "Unknown";
    if (map['category'] != null) {
      label = map['category'];
    } else if (map['source'] != null) label = map['source'];
    else if (map['name'] != null) label = map['name'];

    return LedgerItem(
      id: map['id'] as int,
      label: label,
      amount: map['amount'] as int,
      date: map['date'] as String? ?? '',
      type: map['entryType'] as String? ?? 'Unknown',
      note: map['note'] as String?,
    );
  }

  // Helper to convert back to map if needed for editing logic that expects specific keys
  Map<String, dynamic> toOriginalMap() {
    final map = <String, dynamic>{
      'id': id,
      'amount': amount,
      'date': date,
      'entryType': type,
      'note': note,
    };
    // Reconstruct specific keys based on type
    if (type == 'Income') {
      map['source'] = label;
    } else if (type == 'Variable') map['category'] = label;
    else map['name'] = label;
    
    return map;
  }
}
