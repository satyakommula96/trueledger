// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ledger_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LedgerItemDto _$LedgerItemDtoFromJson(Map<String, dynamic> json) =>
    LedgerItemDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      category: json['category'] as String?,
      source: json['source'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] as String? ?? '',
      type: json['entryType'] as String? ?? 'Variable',
      note: json['note'] as String?,
      tags: json['tags'] as String?,
    );

Map<String, dynamic> _$LedgerItemDtoToJson(LedgerItemDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'source': instance.source,
      'amount': instance.amount,
      'date': instance.date,
      'entryType': instance.type,
      'note': instance.note,
      'tags': instance.tags,
    };
