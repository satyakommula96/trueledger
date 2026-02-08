class Loan {
  final int id;
  final String name;
  final String loanType;
  final double totalAmount;
  final double remainingAmount;
  final double emi;
  final double interestRate;
  final String dueDate;
  final String? date;
  final String? lastPaymentDate;
  final int interestEngineVersion;

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
    this.lastPaymentDate,
    this.interestEngineVersion = 1,
  });

  factory Loan.fromMap(Map<String, dynamic> map) {
    return Loan(
      id: map['id'] as int,
      name: map['name'] as String,
      loanType: map['loan_type'] as String,
      totalAmount: (map['total_amount'] as num).toDouble(),
      remainingAmount: (map['remaining_amount'] as num).toDouble(),
      emi: (map['emi'] as num).toDouble(),
      interestRate: (map['interest_rate'] as num).toDouble(),
      dueDate: map['due_date'] as String,
      date: map['date'] as String?,
      lastPaymentDate: map['last_payment_date'] as String?,
      interestEngineVersion: map['interest_engine_version'] as int? ?? 1,
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
      'last_payment_date': lastPaymentDate,
      'interest_engine_version': interestEngineVersion,
    };
  }
}
