// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const [
    'id',
    'reviewable_type',
    'reviewable_id',
    'user_id',
    'rating'
  ]);
  return Review(
    id: json['id'] as int,
    reviewableType: json['reviewable_type'] as String,
    reviewableId: json['reviewable_id'] as int,
    userId: json['user_id'] as int,
    rating: (json['rating'] as num)?.toDouble(),
    content: json['content'] as String ?? '',
    user: json['user'] == null
        ? null
        : Profile.fromJson(json['user'] as Map<String, dynamic>),
    createdAt: json['created_at'] as String ?? '',
  );
}

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
      'id': instance.id,
      'reviewable_type': instance.reviewableType,
      'reviewable_id': instance.reviewableId,
      'user_id': instance.userId,
      'rating': instance.rating,
      'content': instance.content,
      'user': instance.user,
      'created_at': instance.createdAt,
    };
