// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_card_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreditCardDto _$CreditCardDtoFromJson(Map<String, dynamic> json) =>
    CreditCardDto(
      id: (json['id'] as num).toInt(),
      bank: json['bank'] as String,
      creditLimit: (json['credit_limit'] as num).toDouble(),
      statementBalance: (json['statement_balance'] as num).toDouble(),
      currentBalance: (json['current_balance'] as num).toDouble(),
      minDue: (json['min_due'] as num).toDouble(),
      dueDate: json['due_date'] as String,
      statementDate: json['statement_date'] as String,
    );

Map<String, dynamic> _$CreditCardDtoToJson(CreditCardDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bank': instance.bank,
      'credit_limit': instance.creditLimit,
      'statement_balance': instance.statementBalance,
      'current_balance': instance.currentBalance,
      'min_due': instance.minDue,
      'due_date': instance.dueDate,
      'statement_date': instance.statementDate,
    };
