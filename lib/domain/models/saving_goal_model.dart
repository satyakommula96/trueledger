class SavingGoal {
  final int id;
  final String name;
  final double targetAmount;
  final double currentAmount;

  SavingGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
  });

  SavingGoal copyWith({
    int? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
  }) {
    return SavingGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
    );
  }
}
