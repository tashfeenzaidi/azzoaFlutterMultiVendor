// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PromoBanner _$PromoBannerFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'title']);
  return PromoBanner(
    id: json['id'] as int,
    title: json['title'] as String,
    image: json['image'] as String ?? '',
    createdAt: json['created_at'] as String ?? '',
  )
    ..subtitle = json['subtitle'] as String
    ..shopId = json['shop_id'] as int;
}

Map<String, dynamic> _$PromoBannerToJson(PromoBanner instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'shop_id': instance.shopId,
      'image': instance.image,
      'created_at': instance.createdAt,
    };
