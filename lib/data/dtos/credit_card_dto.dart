import 'package:json_annotation/json_annotation.dart';
import 'package:trueledger/domain/models/credit_card_model.dart';

part 'credit_card_dto.g.dart';

@JsonSerializable()
class CreditCardDto {
  final int id;
  final String bank;
  @JsonKey(name: 'credit_limit')
  final double creditLimit;
  @JsonKey(name: 'statement_balance')
  final double statementBalance;
  @JsonKey(name: 'current_balance')
  final double currentBalance;
  @JsonKey(name: 'min_due')
  final double minDue;
  @JsonKey(name: 'due_date')
  final String dueDate;
  @JsonKey(name: 'statement_date')
  final String statementDate;

  CreditCardDto({
    required this.id,
    required this.bank,
    required this.creditLimit,
    required this.statementBalance,
    required this.currentBalance,
    required this.minDue,
    required this.dueDate,
    required this.statementDate,
  });

  factory CreditCardDto.fromJson(Map<String, dynamic> json) =>
      _$CreditCardDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreditCardDtoToJson(this);

  factory CreditCardDto.fromDomain(CreditCard domain) {
    return CreditCardDto(
      id: domain.id,
      bank: domain.bank,
      creditLimit: domain.creditLimit,
      statementBalance: domain.statementBalance,
      currentBalance: domain.currentBalance,
      minDue: domain.minDue,
      dueDate: domain.dueDate,
      statementDate: domain.statementDate,
    );
  }

  CreditCard toDomain() {
    return CreditCard(
      id: id,
      bank: bank,
      creditLimit: creditLimit,
      statementBalance: statementBalance,
      currentBalance: currentBalance,
      minDue: minDue,
      dueDate: dueDate,
      statementDate: statementDate,
    );
  }
}
