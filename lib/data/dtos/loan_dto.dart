import 'package:json_annotation/json_annotation.dart';
import 'package:trueledger/domain/models/loan_model.dart';

part 'loan_dto.g.dart';

@JsonSerializable()
class LoanDto {
  final int id;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(name: 'loan_type', defaultValue: 'Personal')
  final String loanType;
  @JsonKey(name: 'total_amount', defaultValue: 0.0)
  final double totalAmount;
  @JsonKey(name: 'remaining_amount', defaultValue: 0.0)
  final double remainingAmount;
  @JsonKey(defaultValue: 0.0)
  final double emi;
  @JsonKey(name: 'interest_rate', defaultValue: 0.0)
  final double interestRate;
  @JsonKey(name: 'due_date', defaultValue: '')
  final String dueDate;
  final String? date;
  @JsonKey(name: 'last_payment_date')
  final String? lastPaymentDate;
  @JsonKey(name: 'interest_engine_version', defaultValue: 1)
  final int interestEngineVersion;

  LoanDto({
    required this.id,
    required this.name,
    required this.loanType,
    required this.totalAmount,
    required this.remainingAmount,
    required this.emi,
    required this.interestRate,
    required this.dueDate,
    this.date,
    this.lastPaymentDate,
    required this.interestEngineVersion,
  });

  factory LoanDto.fromJson(Map<String, dynamic> json) =>
      _$LoanDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LoanDtoToJson(this);

  factory LoanDto.fromDomain(Loan domain) {
    return LoanDto(
      id: domain.id,
      name: domain.name,
      loanType: domain.loanType,
      totalAmount: domain.totalAmount,
      remainingAmount: domain.remainingAmount,
      emi: domain.emi,
      interestRate: domain.interestRate,
      dueDate: domain.dueDate,
      date: domain.date,
      lastPaymentDate: domain.lastPaymentDate,
      interestEngineVersion: domain.interestEngineVersion,
    );
  }

  Loan toDomain() {
    return Loan(
      id: id,
      name: name,
      loanType: loanType,
      totalAmount: totalAmount,
      remainingAmount: remainingAmount,
      emi: emi,
      interestRate: interestRate,
      dueDate: dueDate,
      date: date,
      lastPaymentDate: lastPaymentDate,
      interestEngineVersion: interestEngineVersion,
    );
  }
}
