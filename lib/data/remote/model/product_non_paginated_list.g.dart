// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_non_paginated_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductNonPaginatedList _$ProductNonPaginatedListFromJson(
    Map<String, dynamic> json) {
  return ProductNonPaginatedList(
    jsonArray: (json['json_array'] as List)
            ?.map((e) =>
                e == null ? null : Product.fromJson(e as Map<String, dynamic>))
            ?.toList() ??
        [],
  );
}

Map<String, dynamic> _$ProductNonPaginatedListToJson(
        ProductNonPaginatedList instance) =>
    <String, dynamic>{
      'json_array': instance.jsonArray,
    };
