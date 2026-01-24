class CreditCard {
  final int id;
  final String bank;
  final int creditLimit;
  final int statementBalance;
  final int minDue;
  final String dueDate;
  final String generationDate;

  CreditCard({
    required this.id,
    required this.bank,
    required this.creditLimit,
    required this.statementBalance,
    required this.minDue,
    required this.dueDate,
    required this.generationDate,
  });

  factory CreditCard.fromMap(Map<String, dynamic> map) {
    return CreditCard(
      id: map['id'] as int,
      bank: map['bank'] as String,
      creditLimit: map['credit_limit'] as int,
      statementBalance: map['statement_balance'] as int,
      minDue: map['min_due'] as int,
      dueDate: map['due_date'] as String,
      generationDate: map['generation_date'] as String? ?? '',
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
      'generation_date': generationDate,
    };
  }
}
