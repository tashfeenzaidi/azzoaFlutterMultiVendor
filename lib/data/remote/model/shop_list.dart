import 'package:azzoa_grocery/data/remote/model/shop.dart';
import 'package:json_annotation/json_annotation.dart';

part 'shop_list.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ShopList {
  @JsonKey(defaultValue: [])
  List<Shop> jsonArray;

  ShopList({
    this.jsonArray,
  });

  factory ShopList.fromJson(Map<String, dynamic> json) =>
      _$ShopListFromJson(json);

  Map<String, dynamic> toJson() => _$ShopListToJson(this);
}
