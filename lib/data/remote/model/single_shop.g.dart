// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'single_shop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SingleShop _$SingleShopFromJson(Map<String, dynamic> json) {
  return SingleShop(
    jsonObject: json['json_object'] == null
        ? null
        : Shop.fromJson(json['json_object'] as Map<String, dynamic>) ?? [],
  );
}

Map<String, dynamic> _$SingleShopToJson(SingleShop instance) =>
    <String, dynamic>{
      'json_object': instance.jsonObject,
    };
