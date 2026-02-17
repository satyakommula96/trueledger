import 'package:json_annotation/json_annotation.dart';
import 'package:trueledger/domain/models/asset_model.dart';

part 'asset_dto.g.dart';

@JsonSerializable()
class AssetDto {
  final int id;
  final String name;
  final double amount;
  final String type;
  final String date;
  @JsonKey(name: 'active')
  final int isActive;

  AssetDto({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.date,
    required this.isActive,
  });

  factory AssetDto.fromJson(Map<String, dynamic> json) =>
      _$AssetDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AssetDtoToJson(this);

  /// Mapping from Domain to DTO
  factory AssetDto.fromDomain(Asset domain) {
    return AssetDto(
      id: domain.id,
      name: domain.name,
      amount: domain.amount,
      type: domain.type,
      date: domain.date.toUtc().toIso8601String(),
      isActive: domain.isActive ? 1 : 0,
    );
  }

  /// Mapping from DTO to Domain
  Asset toDomain() {
    return Asset(
      id: id,
      name: name,
      amount: amount,
      type: type,
      date: DateTime.parse(date),
      isActive: isActive == 1,
    );
  }
}
