// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'retirement_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RetirementAccountDto _$RetirementAccountDtoFromJson(
        Map<String, dynamic> json) =>
    RetirementAccountDto(
      id: (json['id'] as num).toInt(),
      name: json['type'] as String,
      balance: (json['amount'] as num).toDouble(),
      lastUpdated: json['date'] as String,
    );

Map<String, dynamic> _$RetirementAccountDtoToJson(
        RetirementAccountDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.name,
      'amount': instance.balance,
      'date': instance.lastUpdated,
    };

RetirementSettingsDto _$RetirementSettingsDtoFromJson(
        Map<String, dynamic> json) =>
    RetirementSettingsDto(
      currentAge: (json['currentAge'] as num).toInt(),
      retirementAge: (json['retirementAge'] as num).toInt(),
      annualReturnRate: (json['annualReturnRate'] as num).toDouble(),
    );

Map<String, dynamic> _$RetirementSettingsDtoToJson(
        RetirementSettingsDto instance) =>
    <String, dynamic>{
      'currentAge': instance.currentAge,
      'retirementAge': instance.retirementAge,
      'annualReturnRate': instance.annualReturnRate,
    };
