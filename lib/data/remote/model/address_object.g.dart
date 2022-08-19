// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressObject _$AddressObjectFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['json_object']);
  return AddressObject(
    jsonObject: json['json_object'] == null
        ? null
        : Address.fromJson(json['json_object'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$AddressObjectToJson(AddressObject instance) =>
    <String, dynamic>{
      'json_object': instance.jsonObject,
    };
