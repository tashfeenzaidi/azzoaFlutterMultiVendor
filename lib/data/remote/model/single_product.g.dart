// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'single_product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SingleProduct _$SingleProductFromJson(Map<String, dynamic> json) {
  return SingleProduct(
    jsonObject: json['json_object'] == null
        ? null
        : Product.fromJson(json['json_object'] as Map<String, dynamic>) ?? [],
  );
}

Map<String, dynamic> _$SingleProductToJson(SingleProduct instance) =>
    <String, dynamic>{
      'json_object': instance.jsonObject,
    };
