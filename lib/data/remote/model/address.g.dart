// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Address _$AddressFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'user_id', 'type']);
  return Address(
    id: json['id'] as int,
    userId: json['user_id'] as int,
    type: json['type'] as String,
    name: json['name'] as String ?? '',
    email: json['email'] as String ?? '',
    phone: json['phone'] as String ?? '',
    country: json['country'] as String ?? '',
    state: json['state'] as String ?? '',
    city: json['city'] as String ?? '',
    streetAddress_1: json['street_address_1'] as String ?? '',
    streetAddress_2: json['street_address_2'] as String ?? '',
    latitude: json['latitude'] as String ?? '',
    longitude: json['longitude'] as String ?? '',
    createdAt: json['created_at'] as String ?? '',
  );
}

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'type': instance.type,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'country': instance.country,
      'state': instance.state,
      'city': instance.city,
      'street_address_1': instance.streetAddress_1,
      'street_address_2': instance.streetAddress_2,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'created_at': instance.createdAt,
    };
