// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saving_goal_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SavingGoalDto _$SavingGoalDtoFromJson(Map<String, dynamic> json) =>
    SavingGoalDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      targetAmount: (json['target_amount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (json['current_amount'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$SavingGoalDtoToJson(SavingGoalDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'target_amount': instance.targetAmount,
      'current_amount': instance.currentAmount,
    };
