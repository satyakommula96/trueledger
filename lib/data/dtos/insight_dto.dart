import 'package:json_annotation/json_annotation.dart';
import 'package:trueledger/domain/models/insight_model.dart';

part 'insight_dto.g.dart';

@JsonSerializable()
class AIInsightDto {
  final String id;
  final String title;
  final String body;
  final String type;
  final String priority;
  final String surface;
  final String value;
  final num? currencyValue;
  final double confidence;
  final String group;
  @JsonKey(name: 'cooldown_ms')
  final int cooldownMs;
  final String? lastShownAt;

  AIInsightDto({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.priority,
    required this.surface,
    required this.value,
    this.currencyValue,
    required this.confidence,
    required this.group,
    required this.cooldownMs,
    this.lastShownAt,
  });

  factory AIInsightDto.fromJson(Map<String, dynamic> json) =>
      _$AIInsightDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AIInsightDtoToJson(this);

  factory AIInsightDto.fromDomain(AIInsight domain) {
    return AIInsightDto(
      id: domain.id,
      title: domain.title,
      body: domain.body,
      type: domain.type.name,
      priority: domain.priority.name,
      surface: domain.surface.name,
      value: domain.value,
      currencyValue: domain.currencyValue,
      confidence: domain.confidence,
      group: domain.group.name,
      cooldownMs: domain.cooldown.inMilliseconds,
      lastShownAt: domain.lastShownAt?.toUtc().toIso8601String(),
    );
  }

  AIInsight toDomain() {
    return AIInsight(
      id: id,
      title: title,
      body: body,
      type: InsightType.values.byName(type),
      priority: InsightPriority.values.byName(priority),
      surface: InsightSurface.values.byName(surface),
      value: value,
      currencyValue: currencyValue,
      confidence: confidence,
      group: InsightGroup.values.byName(group),
      cooldown: Duration(milliseconds: cooldownMs),
      lastShownAt:
          lastShownAt != null ? DateTime.parse(lastShownAt!).toLocal() : null,
    );
  }
}
