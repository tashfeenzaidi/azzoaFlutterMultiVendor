// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_non_paginated_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationNonPaginatedList _$NotificationNonPaginatedListFromJson(
    Map<String, dynamic> json) {
  return NotificationNonPaginatedList(
    jsonArray: (json['json_array'] as List)
            ?.map((e) => e == null
                ? null
                : InAppNotification.fromJson(e as Map<String, dynamic>))
            ?.toList() ??
        [],
  );
}

Map<String, dynamic> _$NotificationNonPaginatedListToJson(
        NotificationNonPaginatedList instance) =>
    <String, dynamic>{
      'json_array': instance.jsonArray,
    };
