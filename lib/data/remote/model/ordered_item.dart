import 'package:azzoa_grocery/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ordered_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class OrderedItem {
  @JsonKey(required: true)
  int id;

  @JsonKey(required: true)
  int orderId;

  @JsonKey(required: true)
  int productId;

  @JsonKey(required: null)
  int variationId;

  @JsonKey(defaultValue: kDefaultString)
  String productTitle;

  @JsonKey(defaultValue: kDefaultInt)
  int quantity;

  @JsonKey(defaultValue: kDefaultDouble)
  double price;

  @JsonKey(defaultValue: kDefaultDouble)
  double tax;

  @JsonKey(defaultValue: kDefaultString)
  String createdAt;

  OrderedItem();

  factory OrderedItem.fromJson(Map<String, dynamic> json) =>
      _$OrderedItemFromJson(json);

  Map<String, dynamic> toJson() => _$OrderedItemToJson(this);
}
