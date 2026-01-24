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
