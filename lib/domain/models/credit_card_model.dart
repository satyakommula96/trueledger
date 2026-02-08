class CreditCard {
  final int id;
  final String bank;
  final double creditLimit;
  final double statementBalance;
  final double minDue;
  final String dueDate;
  final String statementDate;

  CreditCard({
    required this.id,
    required this.bank,
    required this.creditLimit,
    required this.statementBalance,
    required this.minDue,
    required this.dueDate,
    this.statementDate = '',
  });

  factory CreditCard.fromMap(Map<String, dynamic> map) {
    return CreditCard(
      id: map['id'] as int,
      bank: map['bank'] as String,
      creditLimit: (map['credit_limit'] as num).toDouble(),
      statementBalance: (map['statement_balance'] as num).toDouble(),
      minDue: (map['min_due'] as num).toDouble(),
      dueDate: map['due_date'] as String,
      statementDate: map['statement_date'] as String? ?? '',
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
      'statement_date': statementDate,
    };
  }
}
