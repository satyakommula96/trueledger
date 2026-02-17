// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetDto _$AssetDtoFromJson(Map<String, dynamic> json) => AssetDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      date: json['date'] as String,
      isActive: (json['active'] as num).toInt(),
    );

Map<String, dynamic> _$AssetDtoToJson(AssetDto instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'amount': instance.amount,
      'type': instance.type,
      'date': instance.date,
      'active': instance.isActive,
    };
