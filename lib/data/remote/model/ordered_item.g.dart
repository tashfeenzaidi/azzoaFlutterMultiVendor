// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ordered_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderedItem _$OrderedItemFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'order_id', 'product_id']);
  return OrderedItem()
    ..id = json['id'] as int
    ..orderId = json['order_id'] as int
    ..productId = json['product_id'] as int
    ..variationId = json['variation_id'] as int
    ..productTitle = json['product_title'] as String ?? ''
    ..quantity = json['quantity'] as int ?? 0
    ..price = (json['price'] as num)?.toDouble() ?? 0.0
    ..tax = (json['tax'] as num)?.toDouble() ?? 0.0
    ..createdAt = json['created_at'] as String ?? '';
}

Map<String, dynamic> _$OrderedItemToJson(OrderedItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.orderId,
      'product_id': instance.productId,
      'variation_id': instance.variationId,
      'product_title': instance.productTitle,
      'quantity': instance.quantity,
      'price': instance.price,
      'tax': instance.tax,
      'created_at': instance.createdAt,
    };
