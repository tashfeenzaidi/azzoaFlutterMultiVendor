// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipping_method.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShippingMethod _$ShippingMethodFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id']);
  return ShippingMethod(
    id: json['id'] as int,
    name: json['name'] as String ?? '',
    description: json['description'] as String ?? '',
    charge: (json['charge'] as num)?.toDouble(),
    status: json['status'] as int,
    createdAt: json['created_at'] as String ?? '',
  );
}

Map<String, dynamic> _$ShippingMethodToJson(ShippingMethod instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'charge': instance.charge,
      'status': instance.status,
      'created_at': instance.createdAt,
    };
