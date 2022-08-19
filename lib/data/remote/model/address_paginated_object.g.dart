// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_paginated_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressPaginatedObject _$AddressPaginatedObjectFromJson(
    Map<String, dynamic> json) {
  return AddressPaginatedObject(
    jsonObject: json['json_object'] == null
        ? null
        : AddressPaginatedList.fromJson(
                json['json_object'] as Map<String, dynamic>) ??
            [],
  );
}

Map<String, dynamic> _$AddressPaginatedObjectToJson(
        AddressPaginatedObject instance) =>
    <String, dynamic>{
      'json_object': instance.jsonObject,
    };
