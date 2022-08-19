// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_summary_paginated_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderSummaryPaginatedObject _$OrderSummaryPaginatedObjectFromJson(
    Map<String, dynamic> json) {
  return OrderSummaryPaginatedObject(
    jsonObject: json['json_object'] == null
        ? null
        : OrderSummaryPaginatedList.fromJson(
                json['json_object'] as Map<String, dynamic>) ??
            [],
  );
}

Map<String, dynamic> _$OrderSummaryPaginatedObjectToJson(
        OrderSummaryPaginatedObject instance) =>
    <String, dynamic>{
      'json_object': instance.jsonObject,
    };
