import 'package:azzoa_grocery/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment_method.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class PaymentMethod {
  @JsonKey(required: true)
  int id;

  @JsonKey(defaultValue: kDefaultString)
  String name;

  @JsonKey(defaultValue: kDefaultString)
  String description;

  @JsonKey(ignore: true)
  bool isSelected = false;

  PaymentMethod({
    this.id,
    this.name,
    this.description,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMethodToJson(this);
}
