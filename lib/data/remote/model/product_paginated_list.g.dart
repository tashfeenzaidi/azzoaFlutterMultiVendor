// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_paginated_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductPaginatedList _$ProductPaginatedListFromJson(Map<String, dynamic> json) {
  return ProductPaginatedList(
    data: (json['data'] as List)
            ?.map((e) =>
                e == null ? null : Product.fromJson(e as Map<String, dynamic>))
            ?.toList() ??
        [],
  )
    ..currentPage = json['current_page'] as int ?? 1
    ..perPage = json['per_page'] as String ?? '1'
    ..lastPage = json['last_page'] as int ?? 1;
}

Map<String, dynamic> _$ProductPaginatedListToJson(
        ProductPaginatedList instance) =>
    <String, dynamic>{
      'current_page': instance.currentPage,
      'per_page': instance.perPage,
      'last_page': instance.lastPage,
      'data': instance.data,
    };
