// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillSummaryDto _$BillSummaryDtoFromJson(Map<String, dynamic> json) =>
    BillSummaryDto(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      dueDate: json['due'] as String?,
      type: json['type'] as String,
      isPaid: json['isPaid'] as bool? ?? false,
    );

Map<String, dynamic> _$BillSummaryDtoToJson(BillSummaryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'amount': instance.amount,
      'due': instance.dueDate,
      'type': instance.type,
      'isPaid': instance.isPaid,
    };
