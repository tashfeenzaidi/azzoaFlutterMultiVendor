// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_details_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderDetailsObject _$OrderDetailsObjectFromJson(Map<String, dynamic> json) {
  return OrderDetailsObject(
    jsonObject: json['json_object'] == null
        ? null
        : OrderDetails.fromJson(json['json_object'] as Map<String, dynamic>) ??
            [],
  );
}

Map<String, dynamic> _$OrderDetailsObjectToJson(OrderDetailsObject instance) =>
    <String, dynamic>{
      'json_object': instance.jsonObject,
    };
