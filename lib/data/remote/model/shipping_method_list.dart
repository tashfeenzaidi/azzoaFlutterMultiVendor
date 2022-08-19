import 'package:azzoa_grocery/data/remote/model/shipping_method.dart';
import 'package:json_annotation/json_annotation.dart';

part 'shipping_method_list.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ShippingMethodList {
  @JsonKey(defaultValue: [])
  List<ShippingMethod> jsonArray;

  ShippingMethodList({
    this.jsonArray,
  });

  factory ShippingMethodList.fromJson(Map<String, dynamic> json) =>
      _$ShippingMethodListFromJson(json);

  Map<String, dynamic> toJson() => _$ShippingMethodListToJson(this);
}
