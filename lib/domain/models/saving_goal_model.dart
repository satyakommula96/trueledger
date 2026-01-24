class SavingGoal {
  final int id;
  final String name;
  final int targetAmount;
  final int currentAmount;

  SavingGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
  });

  factory SavingGoal.fromMap(Map<String, dynamic> map) {
    return SavingGoal(
      id: map['id'] as int,
      name: map['name'] as String,
      targetAmount: map['target_amount'] as int,
      currentAmount: map['current_amount'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
    };
  }
}
