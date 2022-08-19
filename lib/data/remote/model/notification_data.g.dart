// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationData _$NotificationDataFromJson(Map<String, dynamic> json) {
  return NotificationData()
    ..title = json['title'] as String ?? ''
    ..message = json['message'] as String ?? ''
    ..data = json['data'] == null
        ? null
        : NotificationTypeData.fromJson(json['data'] as Map<String, dynamic>);
}

Map<String, dynamic> _$NotificationDataToJson(NotificationData instance) =>
    <String, dynamic>{
      'title': instance.title,
      'message': instance.message,
      'data': instance.data,
    };
