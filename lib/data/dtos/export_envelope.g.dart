// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_envelope.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExportEnvelopeDto _$ExportEnvelopeDtoFromJson(Map<String, dynamic> json) =>
    ExportEnvelopeDto(
      schemaVersion: (json['schemaVersion'] as num).toInt(),
      appVersion: json['appVersion'] as String,
      exportedAt: json['exportedAt'] as String,
      deviceId: json['deviceId'] as String?,
      payload: json['payload'] as Map<String, dynamic>,
      checksum: json['checksum'] as String?,
    );

Map<String, dynamic> _$ExportEnvelopeDtoToJson(ExportEnvelopeDto instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'appVersion': instance.appVersion,
      'exportedAt': instance.exportedAt,
      'deviceId': instance.deviceId,
      'payload': instance.payload,
      'checksum': instance.checksum,
    };
