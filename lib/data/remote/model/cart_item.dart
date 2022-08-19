import 'package:azzoa_grocery/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cart_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CartItem {
  @JsonKey(required: true)
  int id;

  @JsonKey(required: true)
  int cartId;

  @JsonKey(required: true)
  int productId;

  @JsonKey(defaultValue: null)
  int variationId;

  @JsonKey(required: true)
  int quantity;

  @JsonKey(required: true)
  double price;

  @JsonKey(defaultValue: kDefaultDouble)
  double tax;

  @JsonKey(defaultValue: null)
  Map<String, String> attrs;

  @JsonKey(defaultValue: kDefaultString)
  String createdAt;

  @JsonKey(defaultValue: kDefaultString)
  double grossTotal;

  @JsonKey(defaultValue: kDefaultString)
  double netTotal;

  @JsonKey(defaultValue: kDefaultString)
  double taxTotal;

  CartItem({
    this.id,
    this.cartId,
    this.productId,
    this.variationId,
    this.attrs,
    this.price,
    this.grossTotal,
    this.netTotal,
    this.taxTotal,
    this.quantity,
    this.tax,
    this.createdAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemToJson(this);
}
