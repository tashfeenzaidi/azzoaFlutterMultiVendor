// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyProfile _$MyProfileFromJson(Map<String, dynamic> json) {
  return MyProfile(
    jsonObject: json['json_object'] == null
        ? null
        : Profile.fromJson(json['json_object'] as Map<String, dynamic>) ?? [],
  );
}

Map<String, dynamic> _$MyProfileToJson(MyProfile instance) => <String, dynamic>{
      'json_object': instance.jsonObject,
    };
