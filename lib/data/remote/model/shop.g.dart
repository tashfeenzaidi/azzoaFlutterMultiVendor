// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Shop _$ShopFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'name']);
  return Shop(
    id: json['id'] as int,
    shopCategoryId: json['shop_category_id'] as int,
    name: json['name'] as String,
    slug: json['slug'] as String ?? '',
    logo: json['logo'] as String ?? '',
    cover: json['cover'] as String ?? '',
    address: json['address'] as String ?? '',
    latitude: json['latitude'] as String ?? '',
    longitude: json['longitude'] as String ?? '',
    openingAt: json['opening_at'] as String ?? '',
    closingAt: json['closing_at'] as String ?? '',
    details: json['details'] as String ?? '',
    vendorName: json['vendor_name'] as String ?? '',
    email: json['email'] as String ?? '',
    phone: json['phone'] as String ?? '',
    createdAt: json['created_at'] as String ?? '',
    status: json['status'] as int,
    openingStatus: json['opening_status'] as bool ?? false,
    star: (json['star'] as num)?.toDouble() ?? 0.0,
  )..isFollowing = json['is_following'] as bool ?? false;
}

Map<String, dynamic> _$ShopToJson(Shop instance) => <String, dynamic>{
      'id': instance.id,
      'shop_category_id': instance.shopCategoryId,
      'name': instance.name,
      'slug': instance.slug,
      'logo': instance.logo,
      'cover': instance.cover,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'opening_at': instance.openingAt,
      'closing_at': instance.closingAt,
      'details': instance.details,
      'vendor_name': instance.vendorName,
      'email': instance.email,
      'phone': instance.phone,
      'created_at': instance.createdAt,
      'opening_status': instance.openingStatus,
      'star': instance.star,
      'status': instance.status,
      'is_following': instance.isFollowing,
    };
