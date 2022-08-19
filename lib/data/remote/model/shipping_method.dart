import 'package:azzoa_grocery/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'shipping_method.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ShippingMethod {
  @JsonKey(required: true)
  int id;

  @JsonKey(defaultValue: kDefaultString)
  String name;

  @JsonKey(defaultValue: kDefaultString)
  String description;

  @JsonKey(defaultValue: null)
  double charge;

  @JsonKey(defaultValue: null)
  int status;

  @JsonKey(defaultValue: kDefaultString)
  String createdAt;

  @JsonKey(ignore: true)
  bool isSelected = false;

  ShippingMethod({
    this.id,
    this.name,
    this.description,
    this.charge,
    this.status,
    this.createdAt,
  });

  factory ShippingMethod.fromJson(Map<String, dynamic> json) =>
      _$ShippingMethodFromJson(json);

  Map<String, dynamic> toJson() => _$ShippingMethodToJson(this);
}
