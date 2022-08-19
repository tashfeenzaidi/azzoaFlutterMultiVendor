// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_type_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationTypeData _$NotificationTypeDataFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'type']);
  return NotificationTypeData()
    ..id = json['id'] as int
    ..type = json['type'] as String;
}

Map<String, dynamic> _$NotificationTypeDataToJson(
        NotificationTypeData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
    };
