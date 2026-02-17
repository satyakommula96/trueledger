import 'package:json_annotation/json_annotation.dart';
import 'package:trueledger/domain/models/retirement_account.dart';

part 'retirement_dto.g.dart';

@JsonSerializable()
class RetirementAccountDto {
  final int id;
  @JsonKey(name: 'type')
  final String name;
  @JsonKey(name: 'amount')
  final double balance;
  @JsonKey(name: 'date')
  final String lastUpdated;

  RetirementAccountDto({
    required this.id,
    required this.name,
    required this.balance,
    required this.lastUpdated,
  });

  factory RetirementAccountDto.fromJson(Map<String, dynamic> json) =>
      _$RetirementAccountDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RetirementAccountDtoToJson(this);

  factory RetirementAccountDto.fromDomain(RetirementAccount domain) {
    return RetirementAccountDto(
      id: domain.id,
      name: domain.name,
      balance: domain.balance,
      lastUpdated: domain.lastUpdated.toUtc().toIso8601String(),
    );
  }

  RetirementAccount toDomain() {
    return RetirementAccount(
      id: id,
      name: name,
      balance: balance,
      lastUpdated: DateTime.parse(lastUpdated).toLocal(),
    );
  }
}

@JsonSerializable()
class RetirementSettingsDto {
  final int currentAge;
  final int retirementAge;
  final double annualReturnRate;

  RetirementSettingsDto({
    required this.currentAge,
    required this.retirementAge,
    required this.annualReturnRate,
  });

  factory RetirementSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$RetirementSettingsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RetirementSettingsDtoToJson(this);

  factory RetirementSettingsDto.fromDomain(RetirementSettings domain) {
    return RetirementSettingsDto(
      currentAge: domain.currentAge,
      retirementAge: domain.retirementAge,
      annualReturnRate: domain.annualReturnRate,
    );
  }

  RetirementSettings toDomain() {
    return RetirementSettings(
      currentAge: currentAge,
      retirementAge: retirementAge,
      annualReturnRate: annualReturnRate,
    );
  }
}
