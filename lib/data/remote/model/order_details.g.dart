// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderDetails _$OrderDetailsFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'user_id']);
  return OrderDetails()
    ..id = json['id'] as int
    ..userId = json['user_id'] as int
    ..track = json['track'] as String
    ..couponId = json['coupon_id'] as int
    ..couponCode = json['coupon_code'] as String
    ..discount = (json['discount'] as num)?.toDouble() ?? 0
    ..shippingMethodId = json['shipping_method_id'] as int
    ..shippingMethodName = json['shipping_method_name'] as String ?? ''
    ..shippingCharge = (json['shipping_charge'] as num)?.toDouble() ?? 0.0
    ..createdAt = json['created_at'] as String ?? ''
    ..status = json['status'] as int
    ..statusString = json['status_string'] as String ?? ''
    ..netTotal = (json['net_total'] as num)?.toDouble() ?? 0.0
    ..taxTotal = (json['tax_total'] as num)?.toDouble() ?? 0.0
    ..grossTotal = (json['gross_total'] as num)?.toDouble() ?? 0.0
    ..items = (json['items'] as List)
            ?.map((e) => e == null
                ? null
                : OrderedItem.fromJson(e as Map<String, dynamic>))
            ?.toList() ??
        []
    ..consignments = (json['consignments'] as List)
            ?.map((e) => e == null
                ? null
                : Consignment.fromJson(e as Map<String, dynamic>))
            ?.toList() ??
        []
    ..currencyCode = json['currency_code'] as String ?? '';
}

Map<String, dynamic> _$OrderDetailsToJson(OrderDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'track': instance.track,
      'coupon_id': instance.couponId,
      'coupon_code': instance.couponCode,
      'discount': instance.discount,
      'shipping_method_id': instance.shippingMethodId,
      'shipping_method_name': instance.shippingMethodName,
      'shipping_charge': instance.shippingCharge,
      'created_at': instance.createdAt,
      'status': instance.status,
      'status_string': instance.statusString,
      'net_total': instance.netTotal,
      'tax_total': instance.taxTotal,
      'gross_total': instance.grossTotal,
      'items': instance.items,
      'consignments': instance.consignments,
      'currency_code': instance.currencyCode,
    };
