// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyReview _$MyReviewFromJson(Map<String, dynamic> json) {
  return MyReview(
    jsonObject: json['json_object'] == null
        ? null
        : Review.fromJson(json['json_object'] as Map<String, dynamic>) ?? [],
  );
}

Map<String, dynamic> _$MyReviewToJson(MyReview instance) => <String, dynamic>{
      'json_object': instance.jsonObject,
    };
