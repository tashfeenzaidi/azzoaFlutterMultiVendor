// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_paginated_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewPaginatedObject _$ReviewPaginatedObjectFromJson(
    Map<String, dynamic> json) {
  return ReviewPaginatedObject(
    jsonObject: json['json_object'] == null
        ? null
        : ReviewPaginatedList.fromJson(
                json['json_object'] as Map<String, dynamic>) ??
            [],
  );
}

Map<String, dynamic> _$ReviewPaginatedObjectToJson(
        ReviewPaginatedObject instance) =>
    <String, dynamic>{
      'json_object': instance.jsonObject,
    };
