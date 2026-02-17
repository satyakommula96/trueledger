import 'package:json_annotation/json_annotation.dart';

part 'export_envelope.g.dart';

@JsonSerializable()
class ExportEnvelopeDto {
  final int schemaVersion;
  final String appVersion;
  final String exportedAt;
  final String? deviceId;
  final Map<String, dynamic> payload;
  final String? checksum;

  ExportEnvelopeDto({
    required this.schemaVersion,
    required this.appVersion,
    required this.exportedAt,
    this.deviceId,
    required this.payload,
    this.checksum,
  });

  factory ExportEnvelopeDto.fromJson(Map<String, dynamic> json) =>
      _$ExportEnvelopeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExportEnvelopeDtoToJson(this);
}
