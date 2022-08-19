// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShopList _$ShopListFromJson(Map<String, dynamic> json) {
  return ShopList(
    jsonArray: (json['json_array'] as List)
            ?.map((e) =>
                e == null ? null : Shop.fromJson(e as Map<String, dynamic>))
            ?.toList() ??
        [],
  );
}

Map<String, dynamic> _$ShopListToJson(ShopList instance) => <String, dynamic>{
      'json_array': instance.jsonArray,
    };
