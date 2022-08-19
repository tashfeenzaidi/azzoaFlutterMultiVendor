import 'package:azzoa_grocery/data/remote/model/cart.dart';
import 'package:azzoa_grocery/data/remote/model/review.dart';
import 'package:azzoa_grocery/data/remote/model/shop.dart';
import 'package:json_annotation/json_annotation.dart';

part 'my_review.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class MyReview {
  @JsonKey(defaultValue: [])
  Review jsonObject;

  MyReview({
    this.jsonObject,
  });

  factory MyReview.fromJson(Map<String, dynamic> json) =>
      _$MyReviewFromJson(json);

  Map<String, dynamic> toJson() => _$MyReviewToJson(this);
}
