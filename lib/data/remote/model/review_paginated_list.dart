import 'package:azzoa_grocery/data/remote/model/product.dart';
import 'package:azzoa_grocery/data/remote/model/review.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review_paginated_list.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ReviewPaginatedList {
  @JsonKey(defaultValue: 1)
  int currentPage;

  @JsonKey(defaultValue: "1")
  String perPage;

  @JsonKey(defaultValue: 1)
  int lastPage;

  @JsonKey(defaultValue: [])
  List<Review> data;

  ReviewPaginatedList({
    this.data,
  });

  factory ReviewPaginatedList.fromJson(Map<String, dynamic> json) =>
      _$ReviewPaginatedListFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewPaginatedListToJson(this);
}
