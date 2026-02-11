// WARNING: Do not rename enum values; names are persisted in DB as a comma-separated string.
enum TransactionTag {
  loanEmi,
  loanPrepayment,
  loanDisbursement,
  loanFee,
  interest,
  income,
  transfer,
  creditCardPayment,
}

extension TransactionTagHelper on TransactionTag {
  String get name => toString().split('.').last;

  static TransactionTag fromString(String val) {
    return TransactionTag.values.firstWhere(
      (e) => e.name == val,
      orElse: () => TransactionTag.transfer,
    );
  }
}
