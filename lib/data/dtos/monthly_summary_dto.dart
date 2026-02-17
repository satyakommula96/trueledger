import 'package:json_annotation/json_annotation.dart';
import 'package:trueledger/domain/models/monthly_summary.dart';

part 'monthly_summary_dto.g.dart';

@JsonSerializable()
class MonthlySummaryDto {
  final double totalIncome;
  final double totalFixed;
  final double totalVariable;
  final double totalSubscriptions;
  final double totalInvestments;
  final double netWorth;
  final double creditCardDebt;
  final double loansTotal;
  final double totalMonthlyEMI;

  MonthlySummaryDto({
    required this.totalIncome,
    required this.totalFixed,
    required this.totalVariable,
    required this.totalSubscriptions,
    required this.totalInvestments,
    required this.netWorth,
    required this.creditCardDebt,
    required this.loansTotal,
    required this.totalMonthlyEMI,
  });

  factory MonthlySummaryDto.fromJson(Map<String, dynamic> json) =>
      _$MonthlySummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MonthlySummaryDtoToJson(this);

  factory MonthlySummaryDto.fromDomain(MonthlySummary domain) {
    return MonthlySummaryDto(
      totalIncome: domain.totalIncome,
      totalFixed: domain.totalFixed,
      totalVariable: domain.totalVariable,
      totalSubscriptions: domain.totalSubscriptions,
      totalInvestments: domain.totalInvestments,
      netWorth: domain.netWorth,
      creditCardDebt: domain.creditCardDebt,
      loansTotal: domain.loansTotal,
      totalMonthlyEMI: domain.totalMonthlyEMI,
    );
  }

  MonthlySummary toDomain() {
    return MonthlySummary(
      totalIncome: totalIncome,
      totalFixed: totalFixed,
      totalVariable: totalVariable,
      totalSubscriptions: totalSubscriptions,
      totalInvestments: totalInvestments,
      netWorth: netWorth,
      creditCardDebt: creditCardDebt,
      loansTotal: loansTotal,
      totalMonthlyEMI: totalMonthlyEMI,
    );
  }
}
