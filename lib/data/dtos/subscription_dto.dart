import 'package:json_annotation/json_annotation.dart';
import 'package:trueledger/domain/models/subscription_model.dart';

part 'subscription_dto.g.dart';

@JsonSerializable()
class SubscriptionDto {
  final int id;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: 0.0)
  final double amount;
  @JsonKey(name: 'billing_date', defaultValue: '1')
  final String billingDate;
  @JsonKey(name: 'active', defaultValue: 1)
  final int isActive;
  final String? date;

  SubscriptionDto({
    required this.id,
    required this.name,
    required this.amount,
    required this.billingDate,
    required this.isActive,
    this.date,
  });

  factory SubscriptionDto.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionDtoToJson(this);

  factory SubscriptionDto.fromDomain(Subscription domain) {
    return SubscriptionDto(
      id: domain.id,
      name: domain.name,
      amount: domain.amount,
      billingDate: domain.billingDate,
      isActive: domain.isActive ? 1 : 0,
      date: domain.date,
    );
  }

  Subscription toDomain() {
    return Subscription(
      id: id,
      name: name,
      amount: amount,
      billingDate: billingDate,
      isActive: isActive == 1,
      date: date,
    );
  }
}
