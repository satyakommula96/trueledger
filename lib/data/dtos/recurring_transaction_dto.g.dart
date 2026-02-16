// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_transaction_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecurringTransactionDto _$RecurringTransactionDtoFromJson(
        Map<String, dynamic> json) =>
    RecurringTransactionDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      type: json['type'] as String,
      frequency: json['frequency'] as String,
      dayOfMonth: (json['day_of_month'] as num?)?.toInt(),
      dayOfWeek: (json['day_of_week'] as num?)?.toInt(),
      lastProcessed: json['last_processed'] as String?,
      isActive: (json['active'] as num).toInt(),
    );

Map<String, dynamic> _$RecurringTransactionDtoToJson(
        RecurringTransactionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'amount': instance.amount,
      'category': instance.category,
      'type': instance.type,
      'frequency': instance.frequency,
      'day_of_month': instance.dayOfMonth,
      'day_of_week': instance.dayOfWeek,
      'last_processed': instance.lastProcessed,
      'active': instance.isActive,
    };
