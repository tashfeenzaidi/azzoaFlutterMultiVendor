import 'package:azzoa_grocery/data/remote/model/cart.dart';
import 'package:azzoa_grocery/data/remote/model/shop.dart';
import 'package:azzoa_grocery/data/remote/model/wish_list.dart';
import 'package:json_annotation/json_annotation.dart';

part 'my_wish_list.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class MyWishList {
  @JsonKey(defaultValue: [])
  WishList jsonObject;

  MyWishList({
    this.jsonObject,
  });

  factory MyWishList.fromJson(Map<String, dynamic> json) =>
      _$MyWishListFromJson(json);

  Map<String, dynamic> toJson() => _$MyWishListToJson(this);
}
