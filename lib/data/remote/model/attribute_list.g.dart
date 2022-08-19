// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attribute_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttributeList _$AttributeListFromJson(Map<String, dynamic> json) {
  return AttributeList()
    ..jsonArray = (json['json_array'] as List)
            ?.map((e) => e == null
                ? null
                : Attribute.fromJson(e as Map<String, dynamic>))
            ?.toList() ??
        [];
}

Map<String, dynamic> _$AttributeListToJson(AttributeList instance) =>
    <String, dynamic>{
      'json_array': instance.jsonArray,
    };
