import 'package:json_annotation/json_annotation.dart';
import 'package:trueledger/domain/models/saving_goal_model.dart';

part 'saving_goal_dto.g.dart';

@JsonSerializable()
class SavingGoalDto {
  final int id;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(name: 'target_amount', defaultValue: 0.0)
  final double targetAmount;
  @JsonKey(name: 'current_amount', defaultValue: 0.0)
  final double currentAmount;

  SavingGoalDto({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
  });

  factory SavingGoalDto.fromJson(Map<String, dynamic> json) =>
      _$SavingGoalDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SavingGoalDtoToJson(this);

  factory SavingGoalDto.fromDomain(SavingGoal domain) {
    return SavingGoalDto(
      id: domain.id,
      name: domain.name,
      targetAmount: domain.targetAmount,
      currentAmount: domain.currentAmount,
    );
  }

  SavingGoal toDomain() {
    return SavingGoal(
      id: id,
      name: name,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
    );
  }
}
