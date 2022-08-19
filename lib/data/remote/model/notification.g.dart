// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InAppNotification _$InAppNotificationFromJson(Map<String, dynamic> json) {
  return InAppNotification()
    ..id = json['id'] as String ?? ''
    ..type = json['type'] as String ?? ''
    ..notifiableType = json['notifiable_type'] as String ?? ''
    ..notifiableId = json['notifiable_id'] as int ?? 0
    ..readAt = json['read_at'] as String
    ..data = json['data'] == null
        ? null
        : NotificationData.fromJson(json['data'] as Map<String, dynamic>)
    ..createdAt = json['created_at'] as String ?? '';
}

Map<String, dynamic> _$InAppNotificationToJson(InAppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'notifiable_type': instance.notifiableType,
      'notifiable_id': instance.notifiableId,
      'read_at': instance.readAt,
      'data': instance.data,
      'created_at': instance.createdAt,
    };
