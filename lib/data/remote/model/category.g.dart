// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'name']);
  return Category(
    id: json['id'] as int,
    name: json['name'] as String,
    slug: json['slug'] as String ?? '',
    image: json['image'] as String ?? '',
    createdAt: json['created_at'] as String ?? '',
    status: json['status'] as int,
    parentId: json['parent_id'] as int,
  );
}

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'image': instance.image,
      'created_at': instance.createdAt,
      'status': instance.status,
      'parent_id': instance.parentId,
    };
