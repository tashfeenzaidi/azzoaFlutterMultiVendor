import 'package:azzoa_grocery/data/remote/model/shop.dart';
import 'package:json_annotation/json_annotation.dart';

part 'single_shop.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SingleShop {
  @JsonKey(defaultValue: [])
  Shop jsonObject;

  SingleShop({
    this.jsonObject,
  });

  factory SingleShop.fromJson(Map<String, dynamic> json) =>
      _$SingleShopFromJson(json);

  Map<String, dynamic> toJson() => _$SingleShopToJson(this);
}
