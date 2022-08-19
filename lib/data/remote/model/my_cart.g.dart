// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_cart.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyCart _$MyCartFromJson(Map<String, dynamic> json) {
  return MyCart(
    jsonObject: json['json_object'] == null
        ? null
        : Cart.fromJson(json['json_object'] as Map<String, dynamic>) ?? [],
  );
}

Map<String, dynamic> _$MyCartToJson(MyCart instance) => <String, dynamic>{
      'json_object': instance.jsonObject,
    };
