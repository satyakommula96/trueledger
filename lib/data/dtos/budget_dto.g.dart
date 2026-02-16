// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BudgetDto _$BudgetDtoFromJson(Map<String, dynamic> json) => BudgetDto(
      id: (json['id'] as num).toInt(),
      category: json['category'] as String,
      monthlyLimit: (json['monthly_limit'] as num).toDouble(),
      spent: (json['spent'] as num?)?.toDouble(),
      lastReviewedAt: json['last_reviewed_at'] as String?,
      isStable: (json['is_stable'] as num?)?.toInt(),
    );

Map<String, dynamic> _$BudgetDtoToJson(BudgetDto instance) => <String, dynamic>{
      'id': instance.id,
      'category': instance.category,
      'monthly_limit': instance.monthlyLimit,
      'spent': instance.spent,
      'last_reviewed_at': instance.lastReviewedAt,
      'is_stable': instance.isStable,
    };
