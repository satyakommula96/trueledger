import 'package:json_annotation/json_annotation.dart';
import 'package:trueledger/domain/models/personalization_models.dart';

part 'personalization_dto.g.dart';

@JsonSerializable()
class QuickAddPresetDto {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String? note;
  final String? paymentMethod;

  QuickAddPresetDto({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    this.note,
    this.paymentMethod,
  });

  factory QuickAddPresetDto.fromJson(Map<String, dynamic> json) =>
      _$QuickAddPresetDtoFromJson(json);

  Map<String, dynamic> toJson() => _$QuickAddPresetDtoToJson(this);

  factory QuickAddPresetDto.fromDomain(QuickAddPreset domain) {
    return QuickAddPresetDto(
      id: domain.id,
      title: domain.title,
      amount: domain.amount,
      category: domain.category,
      note: domain.note,
      paymentMethod: domain.paymentMethod,
    );
  }

  QuickAddPreset toDomain() {
    return QuickAddPreset(
      id: id,
      title: title,
      amount: amount,
      category: category,
      note: note,
      paymentMethod: paymentMethod,
    );
  }
}

@JsonSerializable()
class PersonalizationSettingsDto {
  final bool personalizationEnabled;
  final bool rememberLastUsed;
  final bool timeOfDaySuggestions;
  final bool shortcutSuggestions;
  final bool baselineReflections;
  final String? preferredReminderTime;
  final int? payDay;

  PersonalizationSettingsDto({
    this.personalizationEnabled = true,
    this.rememberLastUsed = true,
    this.timeOfDaySuggestions = true,
    this.shortcutSuggestions = true,
    this.baselineReflections = true,
    this.preferredReminderTime,
    this.payDay,
  });

  factory PersonalizationSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$PersonalizationSettingsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PersonalizationSettingsDtoToJson(this);

  factory PersonalizationSettingsDto.fromDomain(
      PersonalizationSettings domain) {
    return PersonalizationSettingsDto(
      personalizationEnabled: domain.personalizationEnabled,
      rememberLastUsed: domain.rememberLastUsed,
      timeOfDaySuggestions: domain.timeOfDaySuggestions,
      shortcutSuggestions: domain.shortcutSuggestions,
      baselineReflections: domain.baselineReflections,
      preferredReminderTime: domain.preferredReminderTime,
      payDay: domain.payDay,
    );
  }

  PersonalizationSettings toDomain() {
    return PersonalizationSettings(
      personalizationEnabled: personalizationEnabled,
      rememberLastUsed: rememberLastUsed,
      timeOfDaySuggestions: timeOfDaySuggestions,
      shortcutSuggestions: shortcutSuggestions,
      baselineReflections: baselineReflections,
      preferredReminderTime: preferredReminderTime,
      payDay: payDay,
    );
  }
}

@JsonSerializable()
class PersonalizationSignalDto {
  final String key;
  final String reason;
  final String timestamp;
  final Map<String, dynamic> meta;

  PersonalizationSignalDto({
    required this.key,
    required this.reason,
    required this.timestamp,
    this.meta = const {},
  });

  factory PersonalizationSignalDto.fromJson(Map<String, dynamic> json) =>
      _$PersonalizationSignalDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PersonalizationSignalDtoToJson(this);

  factory PersonalizationSignalDto.fromDomain(PersonalizationSignal domain) {
    return PersonalizationSignalDto(
      key: domain.key,
      reason: domain.reason,
      timestamp: domain.timestamp.toUtc().toIso8601String(),
      meta: domain.meta,
    );
  }

  PersonalizationSignal toDomain() {
    return PersonalizationSignal(
      key: key,
      reason: reason,
      timestamp: DateTime.parse(timestamp).toLocal(),
      meta: meta,
    );
  }
}
