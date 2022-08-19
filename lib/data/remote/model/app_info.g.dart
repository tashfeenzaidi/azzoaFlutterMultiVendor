// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppConfig _$AppConfigFromJson(Map<String, dynamic> json) {
  return AppConfig()
    ..appVersion = json['app_version'] == null
        ? null
        : AppVersion.fromJson(json['app_version'] as Map<String, dynamic>)
    ..color = json['color'] == null
        ? null
        : AppColor.fromJson(json['color'] as Map<String, dynamic>)
    ..apiKey = json['api_key'] == null
        ? null
        : AppApiKey.fromJson(json['api_key'] as Map<String, dynamic>)
    ..logo = json['logo'] as String ?? ''
    ..name = json['name'] as String ?? '';
}

Map<String, dynamic> _$AppConfigToJson(AppConfig instance) => <String, dynamic>{
      'app_version': instance.appVersion,
      'color': instance.color,
      'api_key': instance.apiKey,
      'logo': instance.logo,
      'name': instance.name,
    };
