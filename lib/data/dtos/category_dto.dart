import 'package:json_annotation/json_annotation.dart';
import 'package:trueledger/domain/models/category_model.dart';

part 'category_dto.g.dart';

@JsonSerializable()
class TransactionCategoryDto {
  final int? id;
  final String name;
  final String type;
  @JsonKey(name: 'order_index')
  final int orderIndex;

  TransactionCategoryDto({
    this.id,
    required this.name,
    required this.type,
    this.orderIndex = 0,
  });

  factory TransactionCategoryDto.fromJson(Map<String, dynamic> json) =>
      _$TransactionCategoryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionCategoryDtoToJson(this);

  factory TransactionCategoryDto.fromDomain(TransactionCategory domain) {
    return TransactionCategoryDto(
      id: domain.id,
      name: domain.name,
      type: domain.type,
      orderIndex: domain.orderIndex,
    );
  }

  TransactionCategory toDomain() {
    return TransactionCategory(
      id: id,
      name: name,
      type: type,
      orderIndex: orderIndex,
    );
  }
}
