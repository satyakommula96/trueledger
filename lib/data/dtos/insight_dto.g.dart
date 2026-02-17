// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insight_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AIInsightDto _$AIInsightDtoFromJson(Map<String, dynamic> json) => AIInsightDto(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      priority: json['priority'] as String,
      surface: json['surface'] as String,
      value: json['value'] as String,
      currencyValue: json['currencyValue'] as num?,
      confidence: (json['confidence'] as num).toDouble(),
      group: json['group'] as String,
      cooldownMs: (json['cooldown_ms'] as num).toInt(),
      lastShownAt: json['lastShownAt'] as String?,
    );

Map<String, dynamic> _$AIInsightDtoToJson(AIInsightDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'type': instance.type,
      'priority': instance.priority,
      'surface': instance.surface,
      'value': instance.value,
      'currencyValue': instance.currencyValue,
      'confidence': instance.confidence,
      'group': instance.group,
      'cooldown_ms': instance.cooldownMs,
      'lastShownAt': instance.lastShownAt,
    };
