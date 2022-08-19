import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/product.dart';
import 'package:azzoa_grocery/data/remote/model/product_paginated_list.dart';
import 'package:azzoa_grocery/data/remote/model/review_paginated_list.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review_paginated_object.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ReviewPaginatedObject {
  @JsonKey(defaultValue: [])
  ReviewPaginatedList jsonObject;

  ReviewPaginatedObject({
    this.jsonObject,
  });

  factory ReviewPaginatedObject.fromJson(Map<String, dynamic> json) =>
      _$ReviewPaginatedObjectFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewPaginatedObjectToJson(this);
}
