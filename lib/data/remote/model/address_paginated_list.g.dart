// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_paginated_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressPaginatedList _$AddressPaginatedListFromJson(Map<String, dynamic> json) {
  return AddressPaginatedList(
    data: (json['data'] as List)
            ?.map((e) =>
                e == null ? null : Address.fromJson(e as Map<String, dynamic>))
            ?.toList() ??
        [],
  )
    ..currentPage = json['current_page'] as int ?? 1
    ..perPage = json['per_page'] as int ?? '1'
    ..lastPage = json['last_page'] as int ?? 1;
}

Map<String, dynamic> _$AddressPaginatedListToJson(
        AddressPaginatedList instance) =>
    <String, dynamic>{
      'current_page': instance.currentPage,
      'per_page': instance.perPage,
      'last_page': instance.lastPage,
      'data': instance.data,
    };
