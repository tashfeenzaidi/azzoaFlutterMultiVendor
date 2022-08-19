import 'package:azzoa_grocery/data/remote/model/product.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_paginated_list.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ProductPaginatedList {
  @JsonKey(defaultValue: 1)
  int currentPage;

  @JsonKey(defaultValue: "1")
  String perPage;

  @JsonKey(defaultValue: 1)
  int lastPage;

  @JsonKey(defaultValue: [])
  List<Product> data;

  ProductPaginatedList({
    this.data,
  });

  factory ProductPaginatedList.fromJson(Map<String, dynamic> json) =>
      _$ProductPaginatedListFromJson(json);

  Map<String, dynamic> toJson() => _$ProductPaginatedListToJson(this);
}
