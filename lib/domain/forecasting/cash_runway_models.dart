class Money {
  final int minorUnits;
  const Money(this.minorUnits);

  factory Money.fromCents(int cents) => Money(cents);
  factory Money.fromDouble(double value) => Money((value * 100).round());

  Money operator +(Money other) => Money(minorUnits + other.minorUnits);
  Money operator -(Money other) => Money(minorUnits - other.minorUnits);

  bool get isNegative => minorUnits < 0;
  bool get isZeroOrNegative => minorUnits <= 0;

  double toDouble() => minorUnits / 100.0;

  @override
  String toString() => minorUnits.toString();
}

class CashRunwayResult {
  final bool isSustainable;
  final int? monthsUntilDepletion;
  final DateTime? depletionDate;
  final Money endingBalanceAfterProjection;

  const CashRunwayResult({
    required this.isSustainable,
    required this.monthsUntilDepletion,
    required this.depletionDate,
    required this.endingBalanceAfterProjection,
  });
}
