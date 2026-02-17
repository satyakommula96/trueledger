class CreditCard {
  final int id;
  final String bank;
  final double creditLimit;
  final double statementBalance;
  final double currentBalance;
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
    this.currentBalance = 0.0,
  });

  CreditCard copyWith({
    int? id,
    String? bank,
    double? creditLimit,
    double? statementBalance,
    double? currentBalance,
    double? minDue,
    String? dueDate,
    String? statementDate,
  }) {
    return CreditCard(
      id: id ?? this.id,
      bank: bank ?? this.bank,
      creditLimit: creditLimit ?? this.creditLimit,
      statementBalance: statementBalance ?? this.statementBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      minDue: minDue ?? this.minDue,
      dueDate: dueDate ?? this.dueDate,
      statementDate: statementDate ?? this.statementDate,
    );
  }
}
