class RetirementAccount {
  final int id;
  final String name; // e.g., "EPF", "NPS", "PPF"
  final double balance;
  final String lastUpdated;

  RetirementAccount({
    required this.id,
    required this.name,
    required this.balance,
    required this.lastUpdated,
  });

  factory RetirementAccount.fromMap(Map<String, dynamic> map) {
    return RetirementAccount(
      id: map['id'] as int,
      name: map['type'] as String,
      balance: (map['amount'] as num).toDouble(),
      lastUpdated: map['date'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': name,
      'amount': balance,
      'date': lastUpdated,
    };
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

  Map<String, dynamic> toMap() {
    return {
      'currentAge': currentAge,
      'retirementAge': retirementAge,
      'annualReturnRate': annualReturnRate,
    };
  }

  factory RetirementSettings.fromMap(Map<String, dynamic> map) {
    return RetirementSettings(
      currentAge: map['currentAge'] ?? 30,
      retirementAge: map['retirementAge'] ?? 60,
      annualReturnRate: (map['annualReturnRate'] ?? 8.0).toDouble(),
    );
  }

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
