// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonthlySummaryDto _$MonthlySummaryDtoFromJson(Map<String, dynamic> json) =>
    MonthlySummaryDto(
      totalIncome: (json['totalIncome'] as num).toDouble(),
      totalFixed: (json['totalFixed'] as num).toDouble(),
      totalVariable: (json['totalVariable'] as num).toDouble(),
      totalSubscriptions: (json['totalSubscriptions'] as num).toDouble(),
      totalInvestments: (json['totalInvestments'] as num).toDouble(),
      netWorth: (json['netWorth'] as num).toDouble(),
      creditCardDebt: (json['creditCardDebt'] as num).toDouble(),
      loansTotal: (json['loansTotal'] as num).toDouble(),
      totalMonthlyEMI: (json['totalMonthlyEMI'] as num).toDouble(),
    );

Map<String, dynamic> _$MonthlySummaryDtoToJson(MonthlySummaryDto instance) =>
    <String, dynamic>{
      'totalIncome': instance.totalIncome,
      'totalFixed': instance.totalFixed,
      'totalVariable': instance.totalVariable,
      'totalSubscriptions': instance.totalSubscriptions,
      'totalInvestments': instance.totalInvestments,
      'netWorth': instance.netWorth,
      'creditCardDebt': instance.creditCardDebt,
      'loansTotal': instance.loansTotal,
      'totalMonthlyEMI': instance.totalMonthlyEMI,
    };
