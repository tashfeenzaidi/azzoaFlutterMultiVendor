import 'package:azzoa_grocery/data/remote/model/product.dart';
import 'package:azzoa_grocery/data/remote/model/shop.dart';
import 'package:json_annotation/json_annotation.dart';

part 'single_product.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SingleProduct {
  @JsonKey(defaultValue: [])
  Product jsonObject;

  SingleProduct({
    this.jsonObject,
  });

  factory SingleProduct.fromJson(Map<String, dynamic> json) =>
      _$SingleProductFromJson(json);

  Map<String, dynamic> toJson() => _$SingleProductToJson(this);
}
