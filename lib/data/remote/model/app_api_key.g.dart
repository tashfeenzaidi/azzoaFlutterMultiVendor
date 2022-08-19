// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_api_key.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppApiKey _$AppApiKeyFromJson(Map<String, dynamic> json) {
  return AppApiKey()
    ..googleMapApiKey = json['google_map_api_key'] as String
    ..directionApiKey = json['direction_api_key'] as String ?? '';
}

Map<String, dynamic> _$AppApiKeyToJson(AppApiKey instance) => <String, dynamic>{
      'google_map_api_key': instance.googleMapApiKey,
      'direction_api_key': instance.directionApiKey,
    };
