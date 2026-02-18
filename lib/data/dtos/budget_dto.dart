import 'package:json_annotation/json_annotation.dart';
import 'package:trueledger/domain/models/budget_model.dart';

part 'budget_dto.g.dart';

@JsonSerializable()
class BudgetDto {
  final int id;
  @JsonKey(defaultValue: '')
  final String category;
  @JsonKey(name: 'monthly_limit', defaultValue: 0.0)
  final double monthlyLimit;
  final double? spent;
  @JsonKey(name: 'last_reviewed_at')
  final String? lastReviewedAt;
  @JsonKey(name: 'is_stable')
  final int? isStable;

  BudgetDto({
    required this.id,
    required this.category,
    required this.monthlyLimit,
    this.spent,
    this.lastReviewedAt,
    this.isStable,
  });

  factory BudgetDto.fromJson(Map<String, dynamic> json) =>
      _$BudgetDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BudgetDtoToJson(this);

  factory BudgetDto.fromDomain(Budget domain) {
    return BudgetDto(
      id: domain.id,
      category: domain.category,
      monthlyLimit: domain.monthlyLimit,
      spent: domain.spent,
      lastReviewedAt: domain.lastReviewedAt?.toUtc().toIso8601String(),
      isStable: domain.isStable ? 1 : 0,
    );
  }

  Budget toDomain() {
    return Budget(
      id: id,
      category: category,
      monthlyLimit: monthlyLimit,
      spent: spent ?? 0,
      lastReviewedAt: lastReviewedAt != null
          ? DateTime.parse(lastReviewedAt!).toLocal()
          : null,
      isStable: isStable == 1,
    );
  }
}
