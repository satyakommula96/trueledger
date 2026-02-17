// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personalization_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuickAddPresetDto _$QuickAddPresetDtoFromJson(Map<String, dynamic> json) =>
    QuickAddPresetDto(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      note: json['note'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
    );

Map<String, dynamic> _$QuickAddPresetDtoToJson(QuickAddPresetDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'amount': instance.amount,
      'category': instance.category,
      'note': instance.note,
      'paymentMethod': instance.paymentMethod,
    };

PersonalizationSettingsDto _$PersonalizationSettingsDtoFromJson(
        Map<String, dynamic> json) =>
    PersonalizationSettingsDto(
      personalizationEnabled: json['personalizationEnabled'] as bool? ?? true,
      rememberLastUsed: json['rememberLastUsed'] as bool? ?? true,
      timeOfDaySuggestions: json['timeOfDaySuggestions'] as bool? ?? true,
      shortcutSuggestions: json['shortcutSuggestions'] as bool? ?? true,
      baselineReflections: json['baselineReflections'] as bool? ?? true,
      preferredReminderTime: json['preferredReminderTime'] as String?,
      payDay: (json['payDay'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PersonalizationSettingsDtoToJson(
        PersonalizationSettingsDto instance) =>
    <String, dynamic>{
      'personalizationEnabled': instance.personalizationEnabled,
      'rememberLastUsed': instance.rememberLastUsed,
      'timeOfDaySuggestions': instance.timeOfDaySuggestions,
      'shortcutSuggestions': instance.shortcutSuggestions,
      'baselineReflections': instance.baselineReflections,
      'preferredReminderTime': instance.preferredReminderTime,
      'payDay': instance.payDay,
    };

PersonalizationSignalDto _$PersonalizationSignalDtoFromJson(
        Map<String, dynamic> json) =>
    PersonalizationSignalDto(
      key: json['key'] as String,
      reason: json['reason'] as String,
      timestamp: json['timestamp'] as String,
      meta: json['meta'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$PersonalizationSignalDtoToJson(
        PersonalizationSignalDto instance) =>
    <String, dynamic>{
      'key': instance.key,
      'reason': instance.reason,
      'timestamp': instance.timestamp,
      'meta': instance.meta,
    };
