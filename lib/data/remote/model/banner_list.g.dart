// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BannerList _$BannerListFromJson(Map<String, dynamic> json) {
  return BannerList(
    jsonArray: (json['json_array'] as List)
            ?.map((e) => e == null
                ? null
                : PromoBanner.fromJson(e as Map<String, dynamic>))
            ?.toList() ??
        [],
  );
}

Map<String, dynamic> _$BannerListToJson(BannerList instance) =>
    <String, dynamic>{
      'json_array': instance.jsonArray,
    };
