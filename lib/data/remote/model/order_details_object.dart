import 'package:azzoa_grocery/data/remote/model/order_details.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_details_object.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class OrderDetailsObject {
  @JsonKey(defaultValue: [])
  OrderDetails jsonObject;

  OrderDetailsObject({
    this.jsonObject,
  });

  factory OrderDetailsObject.fromJson(Map<String, dynamic> json) =>
      _$OrderDetailsObjectFromJson(json);

  Map<String, dynamic> toJson() => _$OrderDetailsObjectToJson(this);
}
