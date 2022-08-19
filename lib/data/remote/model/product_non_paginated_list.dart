import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/product.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_non_paginated_list.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ProductNonPaginatedList {
  @JsonKey(defaultValue: [])
  List<Product> jsonArray;

  ProductNonPaginatedList({
    this.jsonArray,
  });

  factory ProductNonPaginatedList.fromJson(Map<String, dynamic> json) =>
      _$ProductNonPaginatedListFromJson(json);

  Map<String, dynamic> toJson() => _$ProductNonPaginatedListToJson(this);
}
