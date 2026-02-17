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

  Loan copyWith({
    int? id,
    String? name,
    String? loanType,
    double? totalAmount,
    double? remainingAmount,
    double? emi,
    double? interestRate,
    String? dueDate,
    String? date,
    String? lastPaymentDate,
    int? interestEngineVersion,
  }) {
    return Loan(
      id: id ?? this.id,
      name: name ?? this.name,
      loanType: loanType ?? this.loanType,
      totalAmount: totalAmount ?? this.totalAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      emi: emi ?? this.emi,
      interestRate: interestRate ?? this.interestRate,
      dueDate: dueDate ?? this.dueDate,
      date: date ?? this.date,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      interestEngineVersion:
          interestEngineVersion ?? this.interestEngineVersion,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Loan &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          loanType == other.loanType &&
          totalAmount == other.totalAmount &&
          remainingAmount == other.remainingAmount &&
          emi == other.emi &&
          interestRate == other.interestRate &&
          dueDate == other.dueDate &&
          date == other.date &&
          lastPaymentDate == other.lastPaymentDate &&
          interestEngineVersion == other.interestEngineVersion;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      loanType.hashCode ^
      totalAmount.hashCode ^
      remainingAmount.hashCode ^
      emi.hashCode ^
      interestRate.hashCode ^
      dueDate.hashCode ^
      date.hashCode ^
      lastPaymentDate.hashCode ^
      interestEngineVersion.hashCode;
}
