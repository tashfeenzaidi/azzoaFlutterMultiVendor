// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wish_list_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WishListItem _$WishListItemFromJson(Map<String, dynamic> json) {
  $checkKeys(json,
      requiredKeys: const ['id', 'cart_id', 'product_id', 'quantity', 'price']);
  return WishListItem(
    id: json['id'] as int,
    cartId: json['cart_id'] as int,
    productId: json['product_id'] as int,
    variationId: json['variation_id'] as int,
    attrs: (json['attrs'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    ),
    price: (json['price'] as num)?.toDouble(),
    grossTotal: (json['gross_total'] as num)?.toDouble() ?? '',
    netTotal: (json['net_total'] as num)?.toDouble() ?? '',
    taxTotal: (json['tax_total'] as num)?.toDouble() ?? '',
    quantity: json['quantity'] as int,
    tax: (json['tax'] as num)?.toDouble() ?? 0.0,
    createdAt: json['created_at'] as String ?? '',
  );
}

Map<String, dynamic> _$WishListItemToJson(WishListItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cart_id': instance.cartId,
      'product_id': instance.productId,
      'variation_id': instance.variationId,
      'quantity': instance.quantity,
      'price': instance.price,
      'tax': instance.tax,
      'attrs': instance.attrs,
      'created_at': instance.createdAt,
      'gross_total': instance.grossTotal,
      'net_total': instance.netTotal,
      'tax_total': instance.taxTotal,
    };
