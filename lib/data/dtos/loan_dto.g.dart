// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoanDto _$LoanDtoFromJson(Map<String, dynamic> json) => LoanDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      loanType: json['loan_type'] as String? ?? 'Personal',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (json['remaining_amount'] as num?)?.toDouble() ?? 0.0,
      emi: (json['emi'] as num?)?.toDouble() ?? 0.0,
      interestRate: (json['interest_rate'] as num?)?.toDouble() ?? 0.0,
      dueDate: json['due_date'] as String? ?? '',
      date: json['date'] as String?,
      lastPaymentDate: json['last_payment_date'] as String?,
      interestEngineVersion:
          (json['interest_engine_version'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$LoanDtoToJson(LoanDto instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'loan_type': instance.loanType,
      'total_amount': instance.totalAmount,
      'remaining_amount': instance.remainingAmount,
      'emi': instance.emi,
      'interest_rate': instance.interestRate,
      'due_date': instance.dueDate,
      'date': instance.date,
      'last_payment_date': instance.lastPaymentDate,
      'interest_engine_version': instance.interestEngineVersion,
    };
