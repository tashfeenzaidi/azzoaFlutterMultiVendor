// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_color.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppColor _$AppColorFromJson(Map<String, dynamic> json) {
  return AppColor()
    ..colorPrimary = json['color_primary'] as String
    ..colorPrimaryDark = json['color_primary_dark'] as String
    ..colorAccent = json['color_accent'] as String
    ..buttonColor_1 = json['button_color_1'] as String
    ..buttonColor_2 = json['button_color_2'] as String;
}

Map<String, dynamic> _$AppColorToJson(AppColor instance) => <String, dynamic>{
      'color_primary': instance.colorPrimary,
      'color_primary_dark': instance.colorPrimaryDark,
      'color_accent': instance.colorAccent,
      'button_color_1': instance.buttonColor_1,
      'button_color_2': instance.buttonColor_2,
    };
