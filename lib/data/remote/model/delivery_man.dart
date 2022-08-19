import 'package:azzoa_grocery/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'delivery_man.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class DeliveryMan {
  @JsonKey(required: true)
  int id;

  @JsonKey(defaultValue: kDefaultString)
  String username;

  @JsonKey(defaultValue: kDefaultString)
  String name;

  @JsonKey(defaultValue: kDefaultString)
  String email;

  @JsonKey(defaultValue: kDefaultString)
  String phone;

  @JsonKey(defaultValue: "https://www.w3schools.com/w3images/avatar2.png")
  String avatar;

  @JsonKey(defaultValue: kDefaultString)
  int status;

  @JsonKey(defaultValue: kDefaultString)
  String createdAt;

  DeliveryMan();

  factory DeliveryMan.fromJson(Map<String, dynamic> json) =>
      _$DeliveryManFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryManToJson(this);
}
