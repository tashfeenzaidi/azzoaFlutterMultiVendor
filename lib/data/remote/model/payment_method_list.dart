import 'package:azzoa_grocery/data/remote/model/payment_method.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment_method_list.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class PaymentMethodList {
  @JsonKey(defaultValue: [])
  List<PaymentMethod> jsonArray;

  PaymentMethodList({
    this.jsonArray,
  });

  factory PaymentMethodList.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodListFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMethodListToJson(this);
}
