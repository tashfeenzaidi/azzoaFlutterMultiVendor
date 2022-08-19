// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'term.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Term _$TermFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'attribute_id', 'name']);
  return Term()
    ..id = json['id'] as int
    ..attributeId = json['attribute_id'] as int
    ..name = json['name'] as String
    ..slug = json['slug'] as String
    ..data = json['data'] as String
    ..createdAt = json['created_at'] as String ?? '';
}

Map<String, dynamic> _$TermToJson(Term instance) => <String, dynamic>{
      'id': instance.id,
      'attribute_id': instance.attributeId,
      'name': instance.name,
      'slug': instance.slug,
      'data': instance.data,
      'created_at': instance.createdAt,
    };
