import 'package:json_annotation/json_annotation.dart';
import 'package:trueledger/domain/models/recurring_transaction_model.dart';

part 'recurring_transaction_dto.g.dart';

@JsonSerializable()
class RecurringTransactionDto {
  final int id;
  final String name;
  final double amount;
  final String category;
  final String type;
  final String frequency;
  @JsonKey(name: 'day_of_month')
  final int? dayOfMonth;
  @JsonKey(name: 'day_of_week')
  final int? dayOfWeek;
  @JsonKey(name: 'last_processed')
  final String? lastProcessed;
  @JsonKey(name: 'active')
  final int isActive;

  RecurringTransactionDto({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.type,
    required this.frequency,
    this.dayOfMonth,
    this.dayOfWeek,
    this.lastProcessed,
    required this.isActive,
  });

  factory RecurringTransactionDto.fromJson(Map<String, dynamic> json) =>
      _$RecurringTransactionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RecurringTransactionDtoToJson(this);

  factory RecurringTransactionDto.fromDomain(RecurringTransaction domain) {
    return RecurringTransactionDto(
      id: domain.id,
      name: domain.name,
      amount: domain.amount,
      category: domain.category,
      type: domain.type,
      frequency: domain.frequency,
      dayOfMonth: domain.dayOfMonth,
      dayOfWeek: domain.dayOfWeek,
      lastProcessed: domain.lastProcessed?.toUtc().toIso8601String(),
      isActive: domain.isActive ? 1 : 0,
    );
  }

  RecurringTransaction toDomain() {
    return RecurringTransaction(
      id: id,
      name: name,
      amount: amount,
      category: category,
      type: type,
      frequency: frequency,
      dayOfMonth: dayOfMonth,
      dayOfWeek: dayOfWeek,
      lastProcessed: lastProcessed != null
          ? DateTime.parse(lastProcessed!).toLocal()
          : null,
      isActive: isActive == 1,
    );
  }
}
