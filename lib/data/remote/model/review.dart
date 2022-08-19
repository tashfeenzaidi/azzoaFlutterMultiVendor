import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/profile.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Review {
  @JsonKey(required: true)
  int id;

  @JsonKey(required: true)
  String reviewableType;

  @JsonKey(required: true)
  int reviewableId;

  @JsonKey(required: true)
  int userId;

  @JsonKey(required: true)
  double rating;

  @JsonKey(defaultValue: kDefaultString)
  String content;

  @JsonKey(defaultValue: null)
  Profile user;

  @JsonKey(defaultValue: kDefaultString)
  String createdAt;

  Review({
    this.id,
    this.reviewableType,
    this.reviewableId,
    this.userId,
    this.rating,
    this.content,
    this.user,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}
