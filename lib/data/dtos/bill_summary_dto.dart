import 'package:json_annotation/json_annotation.dart';
import 'package:trueledger/domain/models/bill_summary_model.dart';

part 'bill_summary_dto.g.dart';

@JsonSerializable()
class BillSummaryDto {
  final String id;
  final String name;
  final double amount;
  @JsonKey(name: 'due')
  final String? dueDate;
  final String type;
  @JsonKey(name: 'isPaid')
  final bool isPaid;

  BillSummaryDto({
    required this.id,
    required this.name,
    required this.amount,
    this.dueDate,
    required this.type,
    this.isPaid = false,
  });

  factory BillSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$BillSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BillSummaryDtoToJson(this);

  factory BillSummaryDto.fromDomain(BillSummary domain) {
    return BillSummaryDto(
      id: domain.id,
      name: domain.name,
      amount: domain.amount,
      dueDate: domain.dueDate?.toUtc().toIso8601String(),
      type: domain.type,
      isPaid: domain.isPaid,
    );
  }

  BillSummary toDomain() {
    return BillSummary(
      id: id,
      name: name,
      amount: amount,
      dueDate: dueDate != null ? DateTime.parse(dueDate!).toLocal() : null,
      type: type,
      isPaid: isPaid,
    );
  }
}
