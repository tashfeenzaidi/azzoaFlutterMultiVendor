// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_wish_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyWishList _$MyWishListFromJson(Map<String, dynamic> json) {
  return MyWishList(
    jsonObject: json['json_object'] == null
        ? null
        : WishList.fromJson(json['json_object'] as Map<String, dynamic>) ?? [],
  );
}

Map<String, dynamic> _$MyWishListToJson(MyWishList instance) =>
    <String, dynamic>{
      'json_object': instance.jsonObject,
    };
