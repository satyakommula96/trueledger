class RetirementAccount {
  final int id;
  final String name; // e.g., "EPF", "NPS", "PPF"
  final double balance;
  final DateTime lastUpdated;

  RetirementAccount({
    required this.id,
    required this.name,
    required this.balance,
    required this.lastUpdated,
  });

  RetirementAccount copyWith({
    int? id,
    String? name,
    double? balance,
    DateTime? lastUpdated,
  }) {
    return RetirementAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class RetirementSettings {
  final int currentAge;
  final int retirementAge;
  final double annualReturnRate;

  RetirementSettings({
    this.currentAge = 30,
    this.retirementAge = 60,
    this.annualReturnRate = 8.0,
  });

  RetirementSettings copyWith({
    int? currentAge,
    int? retirementAge,
    double? annualReturnRate,
  }) {
    return RetirementSettings(
      currentAge: currentAge ?? this.currentAge,
      retirementAge: retirementAge ?? this.retirementAge,
      annualReturnRate: annualReturnRate ?? this.annualReturnRate,
    );
  }
}
