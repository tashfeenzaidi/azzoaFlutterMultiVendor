// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_paginated_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductPaginatedObject _$ProductPaginatedObjectFromJson(
    Map<String, dynamic> json) {
  return ProductPaginatedObject(
    jsonObject: json['json_object'] == null
        ? null
        : ProductPaginatedList.fromJson(
                json['json_object'] as Map<String, dynamic>) ??
            [],
  );
}

Map<String, dynamic> _$ProductPaginatedObjectToJson(
        ProductPaginatedObject instance) =>
    <String, dynamic>{
      'json_object': instance.jsonObject,
    };
