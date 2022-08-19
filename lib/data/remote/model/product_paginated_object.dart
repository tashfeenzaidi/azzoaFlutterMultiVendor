import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/product.dart';
import 'package:azzoa_grocery/data/remote/model/product_paginated_list.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_paginated_object.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ProductPaginatedObject {
  @JsonKey(defaultValue: [])
  ProductPaginatedList jsonObject;

  ProductPaginatedObject({
    this.jsonObject,
  });

  factory ProductPaginatedObject.fromJson(Map<String, dynamic> json) =>
      _$ProductPaginatedObjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProductPaginatedObjectToJson(this);
}
